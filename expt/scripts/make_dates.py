#!/usr/bin/python

#  make_dates.py
#  Tracers
#
#  Created by Paul Gierz on 26.09.13
#

import os, sys
import numpy as np
#import re

os.system('cdo showdate data_raw > data_raw.txt')
fin = open('data_raw.txt')
fin = fin.read()
fin = fin.split()

for i in range(len(fin)):
    datestring=fin[i].split('-')
    #datestring='nest_1_'+str(datestring[0])+str(datestring[1])+str(datestring[2])+'000000'
    datestring='nest_1_'+str(datestring[0])+str(datestring[1])+'31000000'
    os.system('ln -s data_raw '+datestring+'u.nc')
    os.system('ln -s data_raw '+datestring+'v.nc')
    os.system('ln -s data_raw '+datestring+'w.nc')
