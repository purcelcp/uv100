#!/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/ipython

#  LOCAL_anim.py
#  tracers
#
#  Created by Paul J. Gierz on 16.10.13.
#
"""
To be run on the LOCAL machine. Makes an animation of various tracer trajectories.
"""

from toolkits import *


# Copy inputs
#print "Getting Remote File...."
#os.system('scp pgierz@uv100:/uv/user/pgierz/tracers_1p2/expt/expt_MASTER/output/traj_file_1.nc /Users/Gierz/Documents/Uni/Doktor/Models/tracers/expt/scripts/traj_file_1.nc')
# Load inputs
fin = netcdf.netcdf_file('traj_file_1.nc', 'r')
#print fin.variables


lats = fin.variables['lat'].data.squeeze()
lons = fin.variables['lon'].data.squeeze()

lat_0 = lats[0,0]
lon_0 = lons[0,0]

lat_1 = lat_0 - 5.
lat_2 = lat_1 + 5.

# setup Lambert Conformal basemap.
m = Basemap(width=12000000,height=9000000,projection='lcc',
            resolution='c',lat_1=lat_1,lat_2=lat_2,lat_0=lat_0,lon_0=lon_0)
# draw a boundary around the map, fill the background.
# this background will end up being the ocean color, since
# the continents will be drawn on top.
m.drawmapboundary(fill_color='aqua')
# fill continents, set lake color same as ocean color.
m.fillcontinents(color='coral',lake_color='aqua')
# draw parallels and meridians.
# label parallels on right and top
# meridians on bottom and left
parallels = np.arange(0.,81,10.)
# labels = [left,right,top,bottom]
m.drawparallels(parallels,labels=[False,True,True,False])
meridians = np.arange(10.,351.,20.)
m.drawmeridians(meridians,labels=[True,False,False,True])
# plot blue dot on the starting Location, and label it as such.
lon, lat = lon_0, lat_0 # Location of start point
# convert to map projection coords.
# Note that lon,lat can be scalars, lists or numpy arrays.
xpt,ypt = m(lon,lat)
# convert back to lat/lon
lonpt, latpt = m(xpt,ypt,inverse=True)
m.plot(xpt,ypt,'bo')  # plot a blue dot there
# put some text next to the dot, offset a little bit
# (the offset is in map projection coordinates)
plt.text(xpt+100000,ypt+100000,'Starting Location (%5.1fW,%3.1fN)' % (lonpt,latpt))
#plt.show()

# Very faintly draw full path in the background
lons_p, lats_p = lons[0,:], lats[0,:]
xpts, ypts = m(lons_p, lats_p)
lonpts, latpts = m(xpts,ypts, inverse=True)
m.plot(xpts,ypts,'k-', alpha = 0.1)

#plt.hold(True)
for i in range(0,12*30): #fin.variables['time'].size
    print str(i)+' of '+str(12*30)
    lat_0 = lats[0,i]
    lon_0 = lons[0,i]
    lat_1 = lat_0 - 5.
    lat_2 = lat_1 + 5.
    m = Basemap(width=12000000,height=9000000,projection='lcc',
                    resolution='c',lat_1=lat_1,lat_2=lat_2,lat_0=lat_0,lon_0=lon_0)
    # draw a boundary around the map, fill the background.
    # this background will end up being the ocean color, since
    # the continents will be drawn on top.
    m.drawmapboundary(fill_color='aqua')
    # fill continents, set lake color same as ocean color.
    m.fillcontinents(color='coral',lake_color='aqua')
    # draw parallels and meridians.
    # label parallels on right and top
    # meridians on bottom and left
    parallels = np.arange(0.,81,10.)
    # labels = [left,right,top,bottom]
    m.drawparallels(parallels,labels=[False,True,True,False])
    meridians = np.arange(10.,351.,20.)
    m.drawmeridians(meridians,labels=[True,False,False,True])

    # All points up to here
    lons_c, lats_c = lons[0,0:i], lats[0,0:i]
    xpt_c, ypt_c = m(lons_c, lats_c)
    lon_ptc, lat_ptc = m(xpt_c, ypt_c, inverse=True)
    m.plot(xpt_c, ypt_c, 'kx-', alpha = 0.5)

    # Starting Point
    lon, lat = lons[0,0], lats[0,0] # Location of start point
    # convert to map projection coords.
    # Note that lon,lat can be scalars, lists or numpy arrays.
    xpt,ypt = m(lon,lat)
    # convert back to lat/lon
    lonpt, latpt = m(xpt,ypt,inverse=True)
    m.plot(xpt,ypt,'bo')  # plot a blue dot there
    # put some text next to the dot, offset a little bit
    # (the offset is in map projection coordinates)
    plt.text(xpt+100000,ypt+100000,'Starting Location (%5.1fW,%3.1fN)' % (lonpt,latpt))

    # Current Point
    lon, lat = lons[0,i], lats[0,i] # Location of start point
    # convert to map projection coords.
    # Note that lon,lat can be scalars, lists or numpy arrays.
    xpt,ypt = m(lon,lat)
    # convert back to lat/lon
    lonpt, latpt = m(xpt,ypt,inverse=True)
    m.plot(xpt,ypt,'ko')  # plot a blue dot there
    # put some text next to the dot, offset a little bit
    # (the offset is in map projection coordinates)
    if i != 0 :
        plt.text(xpt+100000,ypt+100000,'Current Location (%5.1fW,%3.1fN)' % (lonpt,latpt))
    plt.savefig('/Users/Gierz/Documents/Uni/Doktor/Graphics/Tracers/tracer1_'+"{0:04d}".format(i+1)+'.png')
    print '/Users/Gierz/Documents/Uni/Doktor/Graphics/Tracers/tracer1_'+"{0:04d}".format(i+1)+'.png saved!'
    plt.close()

print "Making film..."
os.chdir('/Users/Gierz/Documents/Uni/Doktor/Graphics/Tracers/')
command = ('mencoder',
           'mf://*.png',
           '-mf',
           'type=png:w=800:h=600:fps=5',
           '-ovc',
           'lavc',
           '-lavcopts',
           'vcodec=mpeg4',
           '-oac',
           'copy',
           '-o',
           'tracer1.avi')

os.spawnvp(os.P_WAIT, 'mencoder', command)

#plt.show()