import numpy as np
from scipy.io import netcdf
import matplotlib
import matplotlib.pyplot as plt

nest_filename='../nests/data_raw'
traj_filename='traj_file_1.nc'

lonAxis = netcdf.netcdf_file(nest_filename, 'r').variables['lon'].data.squeeze()
latAxis = netcdf.netcdf_file(nest_filename, 'r').variables['lat'].data.squeeze()
uvel = netcdf.netcdf_file(nest_filename, 'r').variables['UKO'].data.squeeze()


lon = np.ma.masked_equal(netcdf.netcdf_file(traj_filename, 'r').variables['lon'].data.squeeze(), 1.26765060e+30)
lat = np.ma.masked_equal(netcdf.netcdf_file(traj_filename, 'r').variables['lat'].data.squeeze(), 1.26765060e+30)

cm = matplotlib.cm.get_cmap('jet')
xy = range(lat[0,:].size)
z=xy

mask = np.ma.masked_equal(uvel, -8.99999987e+33)[0,:,:].squeeze()
#for i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]:
#    for x in [1, 2, 3, 4]:
#        for y in [1,2,3,4]:
#            plt.subplot(x,y,i)
#            plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
#            ps = plt.scatter(lon[i,:], lat[i,:], c=z, cmap = cm, alpha = 0.5)


plt.subplot(2,6,1)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[0,:], lat[0,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,2)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[1,:], lat[1,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,3)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[2,:], lat[2,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,4)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[3,:], lat[3,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,5)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[4,:], lat[4,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,6)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[5,:], lat[5,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,7)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[6,:], lat[6,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,8)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[7,:], lat[7,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,9)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[8,:], lat[8,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,10)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[9,:], lat[9,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,11)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[10,:], lat[10,:], c=z, cmap = cm, alpha = 0.5)
plt.subplot(2,6,11)
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
ps = plt.scatter(lon[11,:], lat[11,:], c=z, cmap = cm, alpha = 0.5)


cbar = plt.colorbar(ps)
cbar.set_label('Age (months)')
plt.show()

