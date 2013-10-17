import numpy as np
from scipy.io import netcdf
import matplotlib
import matplotlib.pyplot as plt

nest_filename='../nests/data_raw'
traj_filename='traj_file_01.nc'

lonAxis = netcdf.netcdf_file(nest_filename, 'r').variables['lon'].data.squeeze()
latAxis = netcdf.netcdf_file(nest_filename, 'r').variables['lat'].data.squeeze()
uvel = netcdf.netcdf_file(nest_filename, 'r').variables['UKO'].data.squeeze()


lon = np.ma.masked_equal(netcdf.netcdf_file(traj_filename, 'r').variables['lon'].data.squeeze(), 1.26765060e+30)
lat = np.ma.masked_equal(netcdf.netcdf_file(traj_filename, 'r').variables['lat'].data.squeeze(), 1.26765060e+30)

cm = matplotlib.cm.get_cmap('jet')
xy = range(lat[0,:].size)
z=xy

mask = np.ma.masked_equal(uvel, -8.99999987e+33)[0,:,:].squeeze()
plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
for i in range(lon.shape[0]) :
    ps = plt.scatter(lon[i,:], lat[i,:], c=z, cmap = cm, alpha = 0.5, linewidth = 1)
    #plt.figure()
    #plt.contourf(lonAxis,latAxis, mask[0,:,:].squeeze())
    #pl = plt.plot(lon[i,:], lat[i,:], alpha = 0.5)
cbar = plt.colorbar(ps)
cbar.set_label('Age (months)')
plt.show()
#plt.savefig('figure1.png')
