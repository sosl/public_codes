import urllib2
import BeautifulSoup
import getpass
import os
from argparse import ArgumentParser

parser = ArgumentParser(prog="Parse PWG's list of observations")

parser.add_argument("-p", "--psrs", dest="PSRs", nargs='+', required=True, 
                    metavar='PSR', help="Provide one or more pulsars names.")

args = parser.parse_args()

requestedPSRs = args.PSRs

baseURL = 'http://www.astron.nl/lofarpwg/'
mainURL = 'http://www.astron.nl/lofarpwg/pulsars-time.html'
username = raw_input("Please provide username: ")
password = getpass.getpass()

# Authenticate and keep alive
passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
passman.add_password(None, baseURL, username, password)
authhandler = urllib2.HTTPBasicAuthHandler(passman)
opener = urllib2.build_opener(authhandler)
urllib2.install_opener(opener)
pagehandle = urllib2.urlopen(mainURL)

html = pagehandle.read()
soup = BeautifulSoup.BeautifulSoup(html)

table = soup.find('table')

count = 0
usefulRows = []
for row in table.findAll("tr"):
    cells = row.findAll("td")
    if len(cells) == 20:
        source = cells[3].find(text=True)
        if source in requestedPSRs:
            metaCell = cells[19]
            metaCellText = metaCell.find(text=True)
            obsIDText = cells[1].find(text=True)
            if metaCellText == "meta":
                count+=1
                metaURLCell = metaCell.find("a",href=True)
                if (metaURLCell):
                    metaURL = baseURL + metaURLCell['href']

                    manifestRemote = urllib2.urlopen(metaURL)
                    if not os.path.exists("./manifests"):
                        os.makedirs("./manifests")
                    manifestLocal = open("manifests/"+obsIDText+".txt", "w")
                    manifestLocal.write(manifestRemote.read())
                    manifestLocal.close()
                else:
                    print "WARNING: Found a row with meta but without href"
                    print "Source was: ", source
                    print "ObsID was:", obsIDText

print ""
print ""
print "Found ",count,"observations"
