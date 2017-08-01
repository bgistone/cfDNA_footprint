#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import sys
import scipy
import csv
from scipy.signal import savgol_filter
from numpy import median
from optparse import OptionParser

l_wps = []
raw_wps = []

def adjustWPS(wps_within_window):
    #	print wps_within_window
    median_wps = median(wps_within_window)
    dist = 0 - median_wps
    #	print median_wps, dist
    if median_wps < 0:
        for index,value in enumerate(wps_within_window):
            wps_within_window[index] = value + dist
    else:
        for index in range(len(wps_within_window)):
            wps_within_window[index] -= dist
    return wps_within_window

def do(infile, outfile, window, smoothwindow, overlap):
    FH = open(infile,'r',10000)
    start = 0
    end = 0
    for line in FH.readlines():
        end += 1
        #line = line.strip()
        v = line.strip().split('\t')[2]
        v = int(v)
        raw_wps.append(v)
    FH.close()
    print "loaded file done"

    step = start + window
    l_wps = adjustWPS(raw_wps[start:step])
    #print start,step,len(l_wps)
    start = start + overlap
    loop = 1
    while loop:
        step = start + window
        if (step < end):
            tmp = raw_wps[start:step]
            l_wps_tmp = adjustWPS(tmp)
            l_wps.extend(l_wps_tmp[window-overlap:])
            #print start,step,len(l_wps)
            start = start + overlap
        else:
            tmp = raw_wps[start:end]
            l_wps_tmp = adjustWPS(tmp)
            l_wps.extend(l_wps_tmp[window-overlap:])
            #print start,step,len(l_wps)
            loop = 0

    print "adjusting wps done"
    adjusted_wps = savgol_filter(l_wps,smoothwindow,2).tolist()
    print "smoothing done"
    OUTFH = open(outfile,'w')
    OUTFH.writelines("rawWPS"+"\t"+"adjustedWPS"+"\n")
    new_wps_outstr = ""
    raw_wps_outstr = ""
    for index in range(end):
        new_wps_outstr = str(round(adjusted_wps[index],2))
        raw_wps_outstr = str(round(raw_wps[index],2))
        OUTFH.writelines(raw_wps_outstr+"\t"+new_wps_outstr+"\n")
    OUTFH.close()

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option(
            "-i","--infile",
            action="store",
            dest='infile',
            type='string',
            help='Raw WPS file as input'
            )
    parser.add_option(
            "-o","--outfile",
            action="store",
            dest='outfile',
            type='string',
            help="Adjusted WPS file for output"
            )
    parser.add_option(
            "-w","--window",
            action="store",
            dest='window',
            default=1000,
            type='int',
            help='splide window size,default=1000'
            )
    parser.add_option(
            "-p","--overlap",
            action="store",
            dest='overlap',
            default=500,
            type='int',
            help='window overlap,default=500'
            )
    parser.add_option(
            "-s","--smoothwin",
            action="store",
            dest='smoothwindow',
            default=21,
            type='int',
            help='splide window size,default=21'
            )

    (options, args) = parser.parse_args()
    if options.infile is None:
        parser.error("-i, --infile required\n")
    if options.outfile is None:
        parser.error("-o, --outfile required\n")

    do(options.infile,options.outfile,options.window,options.smoothwindow,options.overlap)
