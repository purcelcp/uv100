#!/usr/bin/python
#
#   This script will rotate the U and V velocities of a mpiom file
#   and then send a command to cat and regrid everything to 360x180
#
#   19.09.13
#   Paul Gierz
#   AWI Bremerhaven

import sys, getopt
import numpy as np
from scipy.io import netcdf
import math

import sys
import time

from progressbar import AnimatedMarker, Bar, BouncingBar, Counter, ETA, \
    AdaptiveETA, FileTransferSpeed, FormatLabel, Percentage, \
    ProgressBar, ReverseBar, RotatingMarker, \
    SimpleProgress, Timer

widgets = [Bar('>'), ' ', ETA(), ' ', ReverseBar('<')]

def main(argv):
    global inputfile
    global outputfile
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
    except getopt.GetoptError:
        print 'test.py -i <inputfile> -o <outputfile>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h' or opt == '?' or opt == '':
            print 'rotate_regrid.py -i <inputfile> -o <outputfile>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg
    print 'Input file is "', inputfile
    print 'Output file is "', outputfile

if __name__ == "__main__" :
    main(sys.argv[1:])
    regridfile = '/csys/nobackup1_PALEO/pgierz/dump/GR30s.nc'
    lon = netcdf.netcdf_file(regridfile, 'r').variables['grid_center_lon'].data.squeeze()
    print 'lon has shape ', lon.shape
    print 'transposing...'
    lon = lon.transpose((1,0))
    print 'new shape is ', lon.shape
    lat = netcdf.netcdf_file(regridfile, 'r').variables['grid_center_lat'].data.squeeze().transpose(1,0)
    print 'lat has shape ', lat.shape
    u   = netcdf.netcdf_file(inputfile, 'r').variables['UKO'].data.squeeze()
    print u.shape
    u   = np.transpose(u, (2,3,1,0))
    print u.shape
    v   = netcdf.netcdf_file(inputfile, 'r').variables['VKE'].data.squeeze().transpose((2,3,1,0))
    time = u.shape[0]
    lev = u.shape[1]
    #print nlons, nlats, time, lev
    xc = lon
    m, n = np.where(xc>180)
    #print m, m.shape
    #print n, n.shape

    xd = np.copy(xc)
    xd[m, n] = xd[m, n] - 360
    #print k, xc[k], xc.shape
    #for i, j in m, n:
    #    xd = np.copy(xc)
    #    xd[i, j] = xd[i, j] - 360
    xc = xd
    yc = lat
    ie = 120
    je = 101
    ke = 40
    dxj = np.zeros([je,ie])     ### FIXME Allocation is incorrectly sized.
    dyi = np.zeros([je,ie])
    phi = np.zeros([je,ie])
    uxy = np.zeros([je, ie, ke, time])
    vxy = np.zeros([je, ie, ke, time])
    print 'Starting rotation...'
    pbar = ProgressBar(widgets=widgets, maxval=time-1).start()
    for t in np.arange(0, time-1):
        #print t, ' of', time-1
        for i in np.arange(0, ie-1):
            #print i, ' of', ie-1
            for j in np.arange(0, je-1):
                #print j, ' of', je-1
                if i < ie:
                    #print i < nlons
                    #print "xc shape is: "+str(xc.shape)
                    #print i, nlons
                    #print j, i, j+1, i+1
                    dxj[j,i] = xc[j,i+1]-xc[j,i]
                    if dxj[j,i] < -90. :
                        dxj[j,i] = abs(abs(xc(j,i+1))-(xc(j,i)))
                    dyi[i,j] = yc[j,i+1]-yc[i,j]
                else :
                    dxj[j,i]=xc[j,1] - xc[j,i]
                    dyi[j,i]=yc[j,1] - yc[j,i]
                phi[j,i]=math.atan2(dyi[j,i],dxj[j,i])
                for l in np.arange(0, ke-1) :
                    #print l, ' of', ke-1
                    if math.isnan(u[j,i,l,t]) : u[j,i,l,t]=0
                    if math.isnan(v[j,i,l,t]) : v[j,i,l,t]=0
                    uxy[j,i,l,t] = u[j,i,l,t]*math.cos(phi[j,i])-v[j,i,l,t]*math.sin(phi[j,i])
                    vxy[j,i,l,t] = u[j,i,l,t]*math.sin(phi[j,i])+v[j,i,l,t]*math.cos(phi[j,i])
        pbar.update()
    pbar.finish()
    print 'Done rotating!'
