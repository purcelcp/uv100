!****************************************************************************
!* System: Connectivity Modeling System (CMS)                               *
!* File : loop.f90                                                          *
!* Last Modified: 2011-07-22                                                *
!* Code contributors: Judith Helgers, Ashwanth Srinivasan, Claire B. Paris, * 
!*                    Erik van Sebille                                      *
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

!calculates the new position of the particle every timestep.
!writes output file
SUBROUTINE loop(my_id, npes)

 USE constants
 USE globalvariables
 USE mod_calendar
 USE mod_reef
 USE mod_ibio
 USE mod_diffpart
 USE mod_random

 IMPLICIT NONE 

 integer (kind=int_kind), intent(in) :: npes, my_id 

 integer (kind=int_kind) :: &
     r,n,j, &  !loop variables
     sze,   &  !number of lines in the releasefile
     pflag, &  !flag if particle is inside or outside polygon
     layer, &  !for ibio
     ppes, startR, endR, & !for mpi
     rnInt,julian,firstfilejulian,lastfilejulian,yymm,basedate, &
     ngrid    
 integer (kind=int8_kind):: time_t, run_time, startsec, time_t_first, maxparticlestart
 logical (kind=log_kind) :: allFinished, timeFlag,flag(6), landflag
 real (kind = real_kind) :: ppesReal,un,vn,wn,tn,sn,rn,newi(QAx),newj(QAx),newk(QAx),diam,dens
 character(char_len)     :: rfname, filename


!calculate number of release locations
 rfname = adjustl(trim(fileinput))//trim(releaseFilename)
 CALL getSize(rfname,sze)

!calculate which lines of the release file my_id has to run
 IF (npes .gt. sze) THEN
  print *, "Error: You USE more processors than the number of lines in the release file. ", &
           " Decrease the number of processors."
  stop
 ENDIF
 ppesReal = (real (sze)) / (real (npes))
 ppes = ceiling(ppesReal)
 startR = (my_id*ppes)+1
 endR = (startR + ppes-1)
 IF ((startR + ppes) .gt. sze) THEN
  endR = sze
 ENDIF

 IF (restartfromfile) THEN
  write(filename,'(A,I0)') 'file_',my_id+1
  CALL readrestartfile(trim(filename),startR,endR,time_t)
  startsec = time_t
  time_t_first = time_t + timeStep
 ELSE
!define density, diameter and halflife of all particle
  DO r=startR,endR
   IF (withibm) THEN
! get size and density of the particle from diffpart input file
    IF (diffPart) THEN
     DO n=1, particle(r)%num_rel
      CALL random_int(0,100,rnInt)
      size_loop: DO j = 1, numCat
       IF (rnInt .le. cumPerc(j)) THEN
        CALL random_real(catMinSize(j), catMaxSize(j),particle(r)%diam(n))
        CALL random_real(catMinDens(j), catMaxDens(j),particle(r)%density(n))
        particle(r)%halflife(n) = catHalfLife(j)
        exit size_loop
       ENDIF
      ENDDO size_loop
     ENDDO
    ELSE
!   else get the size and density of the particle from the file ibm.nml
     DO n=1, particle(r)%num_rel
      particle(r)%diam(n) = diam_particle
      particle(r)%density(n) = dens_particle
      particle(r)%halflife(n) = halflife
     ENDDO
    ENDIF
    diam=particle(r)%diam(n)
    dens=particle(r)%density(n)
   ELSE
    diam=-1
    dens=-1
   ENDIF
   DO n=1, particle(r)%num_rel
    particle(r)%oldi(n)=0
    particle(r)%oldj(n)=0
    particle(r)%oldk(n)=0
   ENDDO
  ENDDO

!check if release polygons are correct if polygon is set to true
  IF(polygon) THEN
   DO r=startR,endR
    CALL check_release_polygon(particle(r)%ilon,particle(r)%ilat,particle(r)%id)
   ENDDO
  ENDIF
  startsec = 0
  time_t_first = timeStep
 ENDIF

!set dataExist to true for now, as it is needed in findgrid
 DO n=1, nnests
  nests(n)%dataExist = .true.
 ENDDO

!find the first available nestfile. In "monthly" mode, the first and last months cannot be used
 yymm=nests(1)%tstart_yy*12+(nests(1)%tstart_mm-1)
 IF ((nests(1)%time_units == "months") .and. (loopfiles .eqv. .false.)) THEN
  yymm=yymm+1
 ENDIF
 CALL jd(yymm/12,mod(yymm,12)+1,nests(1)%tstart_dd,firstfilejulian)

 yymm=nests(1)%tend_yy*12+(nests(1)%tend_mm-1)
 IF ((nests(1)%time_units == "months") .and. (loopfiles .eqv. .false.)) THEN
  yymm=yymm-1
 ENDIF
 CALL jd(yymm/12,mod(yymm,12)+1,nests(1)%tend_dd,lastfilejulian)

!find after how many seconds each release location has to start
 maxparticlestart=0
 DO r=startR,endR
  CALL jd(particle(r)%year,particle(r)%month,particle(r)%day,julian)
  IF ((julian.gt.lastfilejulian) .or. (julian.lt.firstfilejulian)) THEN
   particle(r)%move(:)=.false.
  ELSE
   IF (backward) THEN
    particle(r)%start = ((lastfilejulian - julian)*secs_in_day) + particle(r)%seconds
   ELSE
    particle(r)%start = ((julian - firstfilejulian)*secs_in_day) + particle(r)%seconds
   ENDIF
   IF (particle(r)%start .gt. maxparticlestart) THEN
    maxparticlestart = particle(r)%start
   ENDIF
  ENDIF
 ENDDO 
 total_seconds = timeMax + maxparticlestart

 IF (backward) THEN
  basedate=lastfilejulian
 ELSE
  basedate=firstfilejulian
 ENDIF
!create the outputfile
 IF (npes .lt. 10) THEN
  write(filename,'(A,I0)') 'file_',my_id+1
 ELSEIF (npes .lt. 100) THEN
  write(filename,'(A,I2.2)') 'file_',my_id+1
 ELSE
  write(filename,'(A,I3.3)') 'file_',my_id+1
 ENDIF

 CALL init_trajfile(trim(filename), startR, endR)
 IF (polygon) THEN
  CALL init_confile(trim(filename))
 ENDIF 

!print the startposition of the particles to the outputfile
!check first if the startpositions are correct
 DO r=startR,endR
  DO n=1, particle(r)%num_rel
!  IF there are no nestfiles for given data, output -5 to outputfile
   IF (particle(r)%move(n).eqv..false.) THEN
    IF (ascii) THEN
     CALL stateout_trajfile_ascii(n,r,startsec,-5)
    ELSE
     CALL stateout_trajfile_netcdf(n,r,startsec,startsec,-5,startR)
    ENDIF
    print *, 'Warning: no data for start time of particle',r,'so it will not be integrated.'
    IF (nests(1)%time_units == "months") THEN
     print *, '(In "monthly" mode, particles can only start on or after second available month)'
    ENDIF
   ELSE
!   check if startposition is inside the grid   
    CALL findnest(particle(r)%nlon(n),particle(r)%nlat(n),particle(r)%ndepth(n),ngrid,r,n)
!   if startposition is outside grid, output -1 to outputfile
    IF (ngrid .eq. -1) THEN
     IF (ascii) THEN
      CALL stateout_trajfile_ascii(n,r,startsec,-1)
     ELSE
      CALL stateout_trajfile_netcdf(n,r,startsec,startsec,-1,startR)
     ENDIF
     particle(r)%move(n) = .false.
    ELSE
!    check if startposition is on land
     landflag = .true.
     CALL rungakutta(ngrid,particle(r)%nlon(n),particle(r)%nlat(n),particle(r)%ndepth(n), &
          startsec,diam,dens,1,un,vn,wn,tn,sn,rn,flag,landFlag, &
          r,n,newi,newj,newk)
!    if startposition is on land, output -2 to outputfile, but only if fill_value ne 0
     IF (nests(ngrid)%fill_value .ne. 0.) THEN
      IF ((flag(1) .and. flag(2)) .or. landFlag)  THEN  
       IF (ascii) THEN
         CALL stateout_trajfile_ascii(n,r,startsec,-2)
       ELSE
         CALL stateout_trajfile_netcdf(n,r,startsec,startsec,-2,startR)
       ENDIF
       particle(r)%move(n) = .false.
      ENDIF
     ENDIF
!    output the startlocation
     IF (ascii) THEN
      CALL stateout_trajfile_ascii(n,r,startsec,0)
     ELSE
      CALL stateout_trajfile_netcdf(n,r,startsec,startsec,0,startR)
     ENDIF
    ENDIF
   ENDIF
  ENDDO    
 ENDDO 

!for each timestep
 day_loop: DO time_t=time_t_first,total_seconds,timeStep
 
! write restart data every restartwritefreq time.
  IF (mod(time_t,restartwritefreq).eq.0.) THEN
   write(filename,'(A,I0)') 'file_',my_id+1
   CALL writerestartfile(trim(filename), startR, endR, time_t)
  ENDIF

! load the datafiles
  CALL getphysicaldata(time_t,basedate)

! check if there are datafiles for the given date
  timeFlag = .true.
  DO n=1, nnests
   IF (nests(n)%dataExist) THEN
    timeFlag = .false.
   ENDIF
  ENDDO
 
! if there are no datafiles for the given date then
! stop else move the particles
  IF (timeFlag) THEN
   DO r=startR,endR
    IF (particle(r)%start .lt. time_t) THEN
     DO n=1,particle(r)%num_rel
      particle(r)%flag(n,10)=.True.
     ENDDO
    ENDIF
   ENDDO
  ELSE
!  move all the particles
   CALL move(startR, endR,time_t)
  ENDIF 

!print location and status of particles to output file
  DO r=startR,endR  
   IF (particle(r)%start .lt. time_t) THEN
    DO n=1, particle(r)%num_rel
     IF (particle(r)%move(n) .eqv. .true.) THEN
      run_time = time_t - particle(r)%start

!     Particle leaving model area
      IF(particle(r)%flag(n,7)) THEN
       IF (ascii) THEN
        CALL stateout_trajfile_ascii(n,r,run_time,-1)
       ELSE
        CALL stateout_trajfile_netcdf(n,r, &
             run_time+mod(outputFreq-mod(run_time,outputFreq),outputFreq),time_t,-1, startR)
       ENDIF
       particle(r)%move(n) = .false.
       goto 50
      ENDIF
     
!     Particle is on land
      IF(particle(r)%flag(n,1) .and. particle(r)%flag(n,2)) THEN  
       IF (ascii) THEN
        CALL stateout_trajfile_ascii(n,r,run_time,-2)
       ELSE   
        CALL stateout_trajfile_netcdf(n,r, &
             run_time+ mod(outputFreq - mod(run_time,outputFreq),outputFreq),time_t,-2, startR)
       ENDIF
       particle(r)%move(n) = .false.
       goto 50
      ENDIF

!     Particle is outside time domain
      IF (particle(r)%flag(n,10)) THEN
       IF (ascii) THEN
        CALL stateout_trajfile_ascii(n,r,run_time,-5)
       ELSE
        CALL stateout_trajfile_netcdf(n,r, &
             run_time+ mod(outputFreq - mod(run_time,outputFreq),outputFreq),time_t,-5, startR)
       ENDIF
       particle(r)%move(n) = .false.
       goto 50
      ENDIF

!     Particle is dead
      IF (mort) THEN
       IF (particle(r)%flag(n,8)) THEN
        IF (ascii) THEN
         CALL stateout_trajfile_ascii(n,r,run_time,-3)
        ELSE
         CALL stateout_trajfile_netcdf(n,r, &
              run_time+mod(outputFreq - mod(run_time,outputFreq),outputFreq),time_t,-3, startR)
        ENDIF
        particle(r)%move(n) = .false.
        goto 50   
       ENDIF
      ENDIF

!     check if particle is inside a polygon
      IF (polygon) THEN
       IF (run_time .ge.(settlementStart*secs_in_day)) THEN
        CALL jd(particle(r)%year, particle(r)%month,particle(r)%day,julian) 
        CALL check_reef_recruitment(particle(r)%nlon(n),particle(r)%nlat(n), &
             particle(r)%ndepth(n),run_time,julian,r,pflag)
        IF (pflag == 1) THEN
!        Particle is inside a polygon
         IF (ascii) THEN
          CALL stateout_trajfile_ascii(n,r,run_time,-4)
         ELSE
          CALL stateout_trajfile_netcdf(n,r, &
               run_time+ mod(outputFreq - mod(run_time,outputFreq),outputFreq),time_t,-4,startR)
         ENDIF
         particle(r)%move(n)= .false.
         goto 50
        ENDIF
       ENDIF
      ENDIF

!     particle that is still moving
!     only write output data every outputFreq time.
      IF (mod(run_time,outputFreq).eq.0.) THEN
       IF (ascii) THEN
        CALL stateout_trajfile_ascii(n,r,run_time,0)
       ELSE
        CALL stateout_trajfile_netcdf(n,r,run_time,time_t,0,startR)
       ENDIF
      ENDIF

!     particle is not allowed to move is release date is not yet reached
      IF (run_time .ge. timeMax) THEN
       particle(r)%move(n) = .false.
      ENDIF
     ENDIF
50   continue
    ENDDO ! END loop: n=1, particle(r)%num_rel
   ENDIF

!  If larvaStart is passed then change from buoyancy to ibio
   IF (massSpawning) THEN
    IF ((eggTimePassed(r) .eqv. .false.) .and. (run_time .ge. (larvaStart*secs_in_day))) THEN
     eggTimePassed(r) = .true.
     DO n=1,particle(r)%num_rel
      CALL set_layer(particle(r)%ndepth(n), layer)
      particle(r)%layer(n) = layer
     ENDDO
    ENDIF
   ENDIF
  ENDDO !end loop: r=startR,endR

! check if all particles are finished
  allFinished = .true.
  DO r=startR,endR 
   DO n=1,particle(r)%num_rel
    IF (particle(r)%start .ge. time_t) THEN
     allFinished = .false.
    ENDIF
    IF (particle(r)%move(n) .eqv. .true.) THEN
     allFinished = .false.
    ENDIF
   ENDDO
  ENDDO
  IF (allFinished) THEN
   exit day_loop
  ENDIF

 ENDDO day_loop

!close output file
 CALL close_trajfile
 IF (polygon) THEN
  CALL close_confile
 ENDIF  

!copy file from directory SCRATCH to directory output
 CALL rename_file( &
     adjustl(trim(filescratch))//trim(trajname) &
    ,adjustl(trim(fileoutput ))//trim(trajname) &
    ,Len(adjustl(trim(filescratch))//trim(trajname)) &
    ,Len(adjustl(trim(fileoutput ))//trim(trajname)))

 IF (polygon) THEN
  CALL rename_file( &
     adjustl(trim(filescratch))//trim(conname) &
    ,adjustl(trim(fileoutput ))//trim(conname) &
    ,Len(adjustl(trim(filescratch))//trim(conname)) &
    ,Len(adjustl(trim(fileoutput ))//trim(conname)))
 ENDIF

END SUBROUTINE loop

