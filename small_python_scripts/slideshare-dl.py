#!/usr/bin/env python

# based on https://gist.github.com/julionc/1224088

import os
import urllib2

try:
    from BeautifulSoup import BeautifulSoup
except ImportError:
    try:
        from bs4 import BeautifulSoup
        print "Using BeautifulSoup version 4"
    except ImportError:
        print "Please install BeautifulSoup version 3 or 4 before continuing"
        exit(1)

from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.utils import ImageReader
import io

url = raw_input('Slideshare URL : ')
output = raw_input('Output file : ')
html = urllib2.urlopen(url).read()

soup = BeautifulSoup(html, "lxml")

images = soup.findAll('img', {'class':'slide_image'})

aux = canvas.Canvas(output, pagesize = A4)
lWidth, lHeight = A4
aux.setPageSize((lHeight, lWidth)) # landscape

for image in images:
    image_url = image.get('data-full').split('?')[0]
    ih = urllib2.urlopen(image_url)
    image_file = io.BytesIO(ih.read())
    ih.close()
    image = ImageReader(image_file)
    iWidth, iHeight = image.getSize()
    ratio = 1.0
    if iWidth > lHeight or iHeight > lWidth: # landscape
        widthRatio = float(lHeight) / iWidth
        heightRatio = float(lWidth) / iHeight
        ratio = widthRatio if widthRatio < heightRatio else heightRatio
    ratio = 0.95 * ratio
    aux.drawImage(image, 15, 15, width = iWidth * ratio, height = iHeight * ratio)
    aux.showPage()

aux.save()
