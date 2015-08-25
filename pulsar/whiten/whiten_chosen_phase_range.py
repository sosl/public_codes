# Copyright (C) 2015 by Stefan Oslowski
# Licensed under the Academic Free License version 3.0
# Brief explanation of the license can be found here:
# http://rosenlaw.com/OSL3.0-explained.htm
# Full text:
# http://opensource.org/licenses/AFL-3.0
# or see the LICENSE in the top directory of the repo for the 


# This script will whiten a chosen phase range (from wps to wpe) with
# std_dev of the random noise drawn from the off-pulse region (ops till ope)

import numpy as np
import psrchive as psr
from sys import argv
from os.path import splitext
from os.path import split
from optparse import OptionParser

parser = OptionParser ()

parser.add_option('--wps', '--whiten_start', dest='wps', type='int',
                  help="start of the phase range to be whitened, in bins")
parser.add_option('--wpe', '--whiten_stop', dest='wpe', type='int', 
                  help="end of the phase range to be whitened, in bins")

parser.add_option('--ops', '--offpulse_start', dest='ops', type='int',
                  help="start of the off-pulse phase range, in bins")
parser.add_option('--ope', '--offpulse_stop', dest='ope', type='int',
                  help="end of the off-pulse phase range, in bins")

parser.add_option('-e', dest='ext', type='string',
                  help="Write new files with this extension")
parser.add_option('-O', dest='outpath', type='string',
                  help="Write new files with this extension")
parser.add_option('-v', dest='verbose', action='store_true',
                  help="Verbose mode")

(options, args) = parser.parse_args()

# ensure both ops / ope and wps / wpe were provided:
if not options.wps or not options.wpe or not options.ope or not options.ops:
    print "You must provide the start and end of both"
    print "the off-pulse phase range and the phase region"
    print "to be whitened using --wps, --wpe, --ops, and --ope"
    print
    exit(1)

if not options.ext:
    options.ext="wn"


for archive_filename in args:
    if not options.outpath:
        options.outpath=split(archive_filename)[0]
        #deal with files in ./:
        if not options.outpath:
            options.outpath="."
    ar = psr.Archive_load(archive_filename)
    if not ar.get_dedispersed():
        if options.verbose:
            print "Dedispersing the archive"
        ar.dedisperse()
        was_dedispersed=True
    else:
        was_dedispersed=False

    for isub in range(ar.get_nsubint()):
        int=ar.get_Integration(isub)
        for ichan in range(ar.get_nchan()):
            for ipol in range(ar.get_npol()):
                prof = int.get_Profile(ipol, ichan)
                amps=prof.get_amps()
                off=amps[options.ops:options.ope]
                off_std=np.std(off)
                #need the average as didn't subtract the baseline
                off_avg=np.average(off)
                if off_avg != 0 and  off_std != 0:
                    if options.verbose:
                        print "Skipping subint, chan, pol ", isub, ichan, ipol,
                        " as no data available"
                    new_noise=np.random.normal(loc=off_avg, scale=off_std, size=options.wpe-options.wps+1)
                    for ibin in range(options.wps, options.wpe+1):
                        amps[ibin]=new_noise[options.wps-ibin]

    if not was_dedispersed:
        if options.verbose:
            print "De-dedispersing the archive"
        ar.dededisperse()

    if options.verbose:
        print "writing " + splitext(archive_filename)[0]+"."+options.ext
    ar.unload(options.outpath+"/"+splitext(archive_filename)[0]+"."+options.ext)
