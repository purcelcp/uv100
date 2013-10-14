close all; clear all; clc;

fprintf('working...');
%echo on

cd /uv/user/pgierz/tracers_1p2/expt/raw_inputs;

%load mpiom_gr30s.mat;

% Prior to use this script, the file of mpiom output needs to be transformed to the netcdf, using following command:
% cdo -f nc copy input output

% For long timescales >600 timesteps, this script fails for some unknown reason. 
% It is then best to split the original file into two separat files, and
% perform the transformation twice, thereafter recombining the files.

filename = ['/csys/nobackup1_PALEO/pgierz/dump/GR30s.nc'];

ncid_file2   = netcdf.open([filename],'NC_NOWRITE');
GR30_lon = netcdf.inqVarID(ncid_file2,'grid_center_lon');
lon = netcdf.getVar(ncid_file2,GR30_lon);
lon = permute(lon,[2,1]);
GR30_lat = netcdf.inqVarID(ncid_file2,'grid_center_lat');
lat = netcdf.getVar(ncid_file2,GR30_lat);
lat = permute(lat,[2,1]);
netcdf.close(ncid_file2);

%filename = ['/csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity.nc'];
filename = ['/uv/user/pgierz/tracers_1p2/expt/raw_inputs/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_000001.nc']

ncid_file   = netcdf.open([filename],'NC_WRITE');
varid_u = netcdf.inqVarID(ncid_file,'UKO');
uij = netcdf.getVar(ncid_file,varid_u);
uij = permute(uij,[2,1,3,4]);
varid_v = netcdf.inqVarID(ncid_file,'VKE');
vij = netcdf.getVar(ncid_file,varid_v);
vij = permute(vij,[2,1,3,4]);

fprintf('Starting loop, working...');

ie=120;je=101;ke=40;
%ie=120;je=100;ke=40;
xc=lon; k=find(xc>180);xc(k)=xc(k)-360;
yc=lat;
for ts=1:30
for i=1:ie,
    for j=1:je,
        % derive the rotation angle from gridpoint coordinate differences
        % dxj:= diff. along j=const. in the curvilinear coordinate system
        % dyi:= diff. along i=const. in the curvilinear coordinate system
        if i<ie,
            dxj(j,i)=xc(j,i+1)-xc(j,i); 
            if dxj(j,i)<-90, % consider change of sign @180?E
                dxj(j,i)=abs(abs(xc(j,i+1))-(xc(j,i)));
            end;
            dyi(j,i)=yc(j,i+1)-yc(j,i); 
        else   % consider right border
            dxj(j,i)=xc(j,1)-xc(j,i);
            dyi(j,i)=yc(j,1)-yc(j,i);
        end;  
        % rotational angle, assume local orthogonality of the curvilinear
        % coordinate system
        phi(j,i)=atan2(dyi(j,i),dxj(j,i));
        % rotation of velocities        
        for l=1:ke,
            if (isnan(uij(j,i,l,ts))==1), uij(j,i,l,ts)=0; end
            if (isnan(vij(j,i,l,ts))==1), vij(j,i,l,ts)=0; end
            uxy(j,i,l,ts)=uij(j,i,l,ts)*cos(phi(j,i))-vij(j,i,l,ts)*sin(phi(j,i));
            vxy(j,i,l,ts)=uij(j,i,l,ts)*sin(phi(j,i))+vij(j,i,l,ts)*cos(phi(j,i));
        end;
    end;
end;
end;

uxy(find(abs(uxy)>100)) = uij(1,1,1,1);
vxy(find(abs(vxy)>100)) = uij(1,1,1,1);

uxy = permute(uxy,[2,1,3,4]);
vxy = permute(vxy,[2,1,3,4]);


%filename1 = ['/csys/nobackup2_PALEO/sbora/wind/mfiles/pihs02_mpiom_year2497_rotvel.nc'];

%ncid_file1   = netcdf.open([filename],'NC_WRITE');

netcdf.putVar(ncid_file,varid_u, uxy);
netcdf.putVar(ncid_file,varid_v, vxy);
netcdf.close(ncid_file);

fprintf('Done with rotation...');

fprintf('Regridding...');

clear all;

% Probaly, you will be requested to type in your password, because the
% switch of computer server is essential for using cdo commonds
%unix('ssh rayo3 "/opt/cdo-1.5.4/bin/cdo -t mpiom1 -f nc setgrid,/csys/nobackup1_PALEO/pgierz/dump/GR30s.nc -setgrid,r122x101 /csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity.nc /csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_normalgrid.nc"'); 
%unix('ssh rayo3 "/opt/cdo-1.5.4/bin/cdo remapcon,r360x180 /csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_normalgrid.nc /csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_normalgrid_r360x180.nc"'); 
%unix('cp /csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_normalgrid_r360x180.nc /csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_normalgrid_r360x180_final.nc');
%unix('cp /csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_normalgrid_r360x180.nc /csys/nobackup1_PALEO/pgierz/Data_Raw/mpiom/Clim/aor/RCP4m/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_normalgrid_r360x180_final.nc');

% This part has been changed, since cdo runs on uv100

unix('cdo -t mpiom1 -f nc setgrid,/csys/nobackup1_PALEO/pgierz/dump/GR30s.nc -setgrid,r122x101 /uv/user/pgierz/tracers_1p2/expt/raw_inputs/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_000001.nc /uv/user/pgierz/tracers_1p2/expt/raw_inputs/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_000001_normalgrid.nc');
unix('cdo remapcon,r360x180 /uv/user/pgierz/tracers_1p2/expt/raw_inputs/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_000001_normalgrid.nc /uv/user/pgierz/tracers_1p2/expt/raw_inputs/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_000001_normalgrid_r360x180.nc');
unix('mv /uv/user/pgierz/tracers_1p2/expt/raw_inputs/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_000001_normalgrid_r360x180.nc /uv/user/pgierz/tracers_1p2/expt/raw_inputs/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_000001_normalgrid_r360x180_final.nc');

filename = ['/uv/user/pgierz/tracers_1p2/expt/raw_inputs/RCP4.5m-r_mpiom_3336-3389_Clim_velocity_000001_normalgrid_r360x180_final.nc'];
ncid_file   = netcdf.open([filename],'NC_WRITE');
varid_u = netcdf.inqVarID(ncid_file,'UKO');
u_original = netcdf.getVar(ncid_file,varid_u);
varid_v = netcdf.inqVarID(ncid_file,'VKE');
v_original = netcdf.getVar(ncid_file,varid_v);

u_original(360,:,:,:) = (u_original(359,:,:,:)+u_original(1,:,:,:))/2;
v_original(360,:,:,:) = (v_original(359,:,:,:)+v_original(1,:,:,:))/2;

u_original(find(abs(u_original)>100)) = u_original(1,1,1,1);
v_original(find(abs(v_original)>100)) = u_original(1,1,1,1);

netcdf.putVar(ncid_file,varid_u, u_original);
netcdf.putVar(ncid_file,varid_v, v_original);
netcdf.close(ncid_file);

% The file with '_final.nc' at the tail of the name is the one you need!
% Good Luck!
% Xun

quit


