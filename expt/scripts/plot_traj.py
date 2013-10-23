#!/usr/bin/python
import numpy as np
from scipy.io import netcdf
import matplotlib.pyplot as plt
import sys, getopt
from mpl_toolkits.basemap import Basemap
import matplotlib

def main(argv):
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
    except getopt.GetoptError:
        print 'test.py -i <inputfile> -o <outputfile>.\n If outputfile is open file will be opened instead of saved.'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'test.py -i <inputfile> -o <outputfile>.\n If outputfile is open file will be opened instead of saved.'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg
    return inputfile, outputfile


fin, fout = main(sys.argv[1:])
nest_filename='../nests/data_raw'



lonAxis = netcdf.netcdf_file(nest_filename, 'r').variables['lon'].data.squeeze()
latAxis = netcdf.netcdf_file(nest_filename, 'r').variables['lat'].data.squeeze()
uvel = netcdf.netcdf_file(nest_filename, 'r').variables['UKO'].data.squeeze()

lon = np.ma.masked_equal(netcdf.netcdf_file(fin, 'r').variables['lon'].data.squeeze(), 1.26765060e+30)
lat = np.ma.masked_equal(netcdf.netcdf_file(fin, 'r').variables['lat'].data.squeeze(), 1.26765060e+30)
depth = np.ma.masked_equal(netcdf.netcdf_file(fin, 'r').variables['depth'].data.squeeze(), 1.26765060e+30)

cm = matplotlib.cm.get_cmap('jet')
xy = range(lat[0,:].size)
z=xy

colors = matplotlib.cm.rainbow(np.linspace(0, 1, len(z)))
#print colors

plt.subplot(211)

# lon_0, lat_0 are the center point of the projection.
# resolution = 'l' means use low resolution coastlines.
m = Basemap(llcrnrlon=0,llcrnrlat=-80,urcrnrlon=360,urcrnrlat=80,projection='mill')
m.drawcoastlines()
m.fillcontinents(color='coral',lake_color='aqua')
# draw parallels and meridians.
m.drawparallels(np.arange(-90.,120.,30.))
m.drawmeridians(np.arange(0.,420.,60.))
m.drawmapboundary(fill_color='aqua')

xpts, ypts = m(lon, lat)

for i in range(lon.shape[0]) :
    #ps = m.scatter(xpts[i,:], ypts[i,:], alpha = 0.5, s=10, linewidth=0)
    #plt.figure()
    #plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
    pl = m.plot(xpts[i,:], ypts[i,:], '.', alpha = 0.5)
#cbar = plt.colorbar(ps)
#cbar.set_label('Age (months)')

m.plot(xpts[:,0], ypts[:,0], 'w*', markersize=20)

plt.subplot(212)
for i in range(lon.shape[0]) :
    plt.plot(depth[i,:])
    plt.xlabel('Time (months)')
    plt.ylabel('Depth (m)')
if fout == 'open' :
    plt.show()
else :
    plt.savefig(fout)

sys.exit()
