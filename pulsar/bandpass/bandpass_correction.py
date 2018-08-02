# coding: utf-8

# Basic setup:

import psrchive as psr
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from os.path import splitext
from os.path import split
from os.path import basename
import argparse

parser = argparse.ArgumentParser(description="This code will estimate the"
         " bandpass from the off-pulse data and apply the correction to all of"
         " data. Note that the baseline will be removed in the process.")

parser.add_argument('-P', dest='nopscr', action='store_true',
                    help="Detrmine correction for each pol seperately. "
                    + "WARNING: will only work as expected if you have a "
                    + "resonably strong signal in all pols")
parser.add_argument('-e', dest='ext',
                    help="Write new files with this extension")
parser.add_argument('-O', dest='outpath',
                    help="Write new files in this directory")
parser.add_argument('-p', dest='plot', action='store_true',
                    help="Save the plot of the bandpass")
parser.add_argument('-v', dest='verbose', action='store_true',
                    help="Verbose mode")

parser.add_argument('INPUT_ARCHIVE', nargs='+',
                    help="Archives for which the bandpass should be corrected")

args = parser.parse_args()

if not args.ext:
    args.ext = "bp"

# loop through the input files
for ar_name in args.INPUT_ARCHIVE:
    # setup the outpath based on the options and input name
    if not args.outpath:
        args.outpath = split(ar_name)[0]
        # deal with files in ./:
        if not args.outpath:
            args.outpath = "."
    # set up the output name
    outname = args.outpath+"/"+splitext(basename(ar_name))[0]+"."

    # Load the data and do some basic processing:
    if args.verbose:
        print "Loading and t- and p-scrunching the archive " + ar_name
    ar = psr.Archive_load(ar_name)
    if not args.nopscr:
        ar.pscrunch()
    ar.tscrunch()

    if args.verbose:
        print "Determining the bandpass from off-pulse data"
    subint = ar.get_Integration(0)
    (bl_mean, bl_var) = subint.baseline_stats()
    non_zeroes = np.where(bl_mean[0] != 0.0)[0]

    if args.plot:
        # Obtain the baseline statistics which we use to derive the bandpass
        # for this observation
        # Get the frequencies from the archive. Not terribly efficient,
        # is there a better way to do this?
        if args.verbose:
            print "Determining the frequency range for plotting purposes"
        min_freq = ar.get_Profile(0, 0, 0).get_centre_frequency()
        nchan = ar.get_nchan()
        max_freq = ar.get_Profile(0, 0, nchan-1).get_centre_frequency()
        freqs = np.linspace(min_freq, max_freq, nchan)

        # Plot the bandpass:
        if args.verbose:
            print "plotting the bandpass estimate"
        fig1 = plt.figure()
        lines = []
        for ipol in xrange(bl_mean.shape[0]):
            plt.plot(freqs[non_zeroes], bl_mean[ipol][non_zeroes])
        xlab = plt.xlabel('frequency [MHz]')
        ylab = plt.ylabel('power [arbitrary]')
        fig1.savefig(outname+"png")
        plt.clf()

    # Get data and normalize it using the bandpass. We want to correct the data
    # in their original form, thus we need to reload the archive:
    if args.verbose:
        print "re-loading the archive to correct the bandpass"
    ar = psr.Archive_load(ar_name)
    ar.remove_baseline()

    bl_mean_avg = []
    for ipol in xrange(bl_mean.shape[0]):
        bl_mean_avg.append(np.average(bl_mean[ipol][non_zeroes]))
    for isub in xrange(ar.get_nsubint()):
        for ipol in xrange(ar.get_npol()):
            for ichan in xrange(ar.get_nchan()):
                prof = ar.get_Profile(isub, ipol, ichan)
                if ichan in non_zeroes:
                    if ipol < bl_mean.shape[0]:
                        prof.scale(bl_mean_avg[ipol] / bl_mean[ipol][ichan])
                    else:
                        prof.scale(bl_mean_avg[0] / bl_mean[0][ichan])
                else:
                    prof.set_weight(0.0)
    if args.verbose:
        print "Unloading the bandpass-corrected archive to " + outname \
             + args.ext
    ar.unload(outname+args.ext)
