!****************************************************************************
!* System: Connectivity Modeling System (CMS)                               *
!* File : mod_buoyancy_larva.f90                                            *
!* Last Modified: 2011-07-22                                                *
!* Code contributors: Judith Helgers, Claire B. Paris                       * 
!*                                                                          *
!* Copyright (C) 2011, University of Miami                                  *
!*                                                                          *
!* This program is free software: you can redistribute it and/or modify     *
!* it under the terms of the GNU Lesser General Public License as published *
!* by the Free Software Foundation, either version 3 of the License, or     *
!*(at your option) any later version.                                       *
!*                                                                          *
!* This program is distributed in the hope that it will be useful,          *
!* but WITHOUT ANY WARRANTY; without even the implied warranty of           *
!* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
!* See the Lesser GNU General Public License for more details.              *
!*                                                                          *
!* You should have received a copy of the GNU Lesser General                *
!* Public License along with this program.                                  *
!* If not, see <http://www.gnu.org/licenses/>.                              *
!****************************************************************************


MODULE mod_buoyancy

USE mod_kinds

IMPLICIT NONE

CONTAINS

!**************************************************************
!Calculate buoyancy component for larva
!Equation (2), (3) and (4) from Zheng and Yapa(2000)
subroutine get_buoyancy(dens_water, temp_water,diam_part, dens_part, w2)

real(kind=real_kind), intent(in)  :: &
     dens_water, temp_water, diam_part, dens_part
real(kind=real_kind), intent(out) :: w2

real(kind=real_kind) :: &
     viscosity,dc1, dc2, dc, power, wpart1, wpart2, wpart3

 viscosity = 1.88e-3 - (temp_water*4.e-5) 
 !print *, "dens water: ", dens_water
 !print *, "viscosity water: ", viscosity   
 !print *, "diameter particle: ", diam_part
 !print *, "density particle: ", dens_part

!Equation (4) from Zheng and Yapa(2000)
 power = 2./3.
 dc1 = (9.52 * viscosity)**(power)
 power = 1./3.  
 dc2 = (9.8 * dens_water * abs(dens_part-dens_water))**(power)
 dc = dc1/dc2
 !print *, dc

 IF (diam_part .lt. dc) THEN
!Equation (2) from Zheng and Yapa(2000). Formula of stokes  
  w2=1. * (9.8 * (diam_part*diam_part) * (dens_part-dens_water)) /(18. * viscosity)
  !print *, "stokes: ",w2
 ELSE
!Equation (3) from Zheng and Yapa(2000).
  wpart1 = -8. * 9.8 * diam_part * (dens_part-dens_water)
  wpart2 = 3. * dens_water
  wpart3 = wpart1/wpart2 
  w2 = -1. * sqrt(wpart3)
  !print *, "other formula: ",diam_part, w2   
 ENDIF

END SUBROUTINE get_buoyancy
!**************************************************************

END MODULE mod_buoyancy

