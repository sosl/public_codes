#!/usr/bin/env python

from argparse import *
import sys
from pyPdf import PdfFileWriter, PdfFileReader

parser = ArgumentParser(description="Rotate pages in the pdf fed from stdin to stdout")

parser.add_argument('--pages', nargs='+', type=int, 
        help="Pages to rotate")

args = parser.parse_args()

pages = [ int(x) -1 for x in args.pages ]

input = PdfFileReader(sys.stdin)
output = PdfFileWriter()
for i in range(0,input.getNumPages()):
    if i in pages:
        output.addPage(input.getPage(i).rotateClockwise(90))
    else:
        output.addPage(input.getPage(i))
    output.write(sys.stdout)
