This script can be useful for timing with a per-channel template if the data are missing some channels.

When timing and not fscrunching the stanard, pat will just force the number of channels in data and template to match by scrunching one of these down and timing channel i of data against channel i of the template. This is not ideal if there is significant frequency evolution... This python script solves the problem by creating a template in which the exact frequency structure of the data is reproduced.
