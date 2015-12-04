
# coding: utf-8

import psrchive as psr
from numpy import isclose, where, invert
from operator import itemgetter
from itertools import groupby
from argparse import *

parser = ArgumentParser ()

parser.add_argument('-t', '--template', dest='template', nargs=1,
        help="Template from which the new templates are to be derived")
parser.add_argument('INPUT_ARCHIVE', nargs='+',
        help="Archives for which a matched template is needed")
parser.add_argument('-e', '--ext', dest='ext', nargs=1,
        default="matched_std", help="extension for the output file")

args = parser.parse_args()

# This needs to be replaced with optparse to get the setup from the command line

std = psr.Archive_load(args.template[0])

was_dedispersed = std.get_dedispersed()
if was_dedispersed:
    std.dededisperse()
else:
    print "WARNING: your template is not dedispersed."

# Obtain a list of frequencies contained in the template

std_freqs = []
std_channels = range(std.get_nchan())
for i in range(std.get_nchan()):
    std_freqs.append(std.get_Profile(0, 0, i).get_centre_frequency())


# Obtain a list of frequncies contained in data

for input_ar in args.INPUT_ARCHIVE:
    data = psr.Archive_load(input_ar)
    print "handling " + input_ar + " with " + str(data.get_nchan()) + " channels"
    data_freqs = []
    for i in range(data.get_nchan()):
        data_freqs.append(data.get_Profile(0, 0, i).get_centre_frequency())

# Find an overlap between the two sets and prepare a list of ranges of channels to be deleted 

    overlap = [any(isclose(x, data_freqs)) for x in std_freqs]
    std_delete_channels = where(invert(overlap))[0]
    ranges = []
    for k, g in groupby(enumerate(std_delete_channels), lambda (i,x):i-x):
        group = map(itemgetter(1), g)
        ranges.append((group[0], group[-1]))
    print ranges

# check if all the channels from the data where found in the template

    if len(std_delete_channels) + len(data_freqs) != len(std_freqs):
        print "WARNING: The template did not contain all the necessary channels!"

# remove the unwanted channels from a copy of the template:

    std_copy = std.clone() 
    for x,y in reversed(ranges):
        try:
            std_copy.remove_chan(x, y)
        except IndexError:
            print "removing channels from " + str(x) + " to " + str(y)
            print "org template had " + std.get_nchan() + " channels"
            print "copy has now " + std_copy.get_nchan() + " channels"
        except:
            print "Other exception"
    if was_dedispersed:
        std_copy.dedisperse()
    std_copy.unload(input_ar + "." + args.ext[0])
