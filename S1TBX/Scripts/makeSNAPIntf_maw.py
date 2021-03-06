#!/usr/bin/env python


import re,sys,os
import numpy as np
from osgeo import gdal

i = sys.argv[1]
q = sys.argv[2]

idataset = gdal.Open(i, gdal.GA_ReadOnly)
qdataset = gdal.Open(q, gdal.GA_ReadOnly)
idata = idataset.GetRasterBand(1)
qdata = qdataset.GetRasterBand(1)

(x,y,trans,proj,idata) = saa.read_gdal_file(saa.open_gdal_file(i))
(x,y,trans,proj,qdata) = saa.read_gdal_file(saa.open_gdal_file(q))


amp = np.sqrt(np.sqrt(np.power(idata,2) + np.power(qdata,2)))
phase = np.arctan2(qdata,idata)


saa.write_gdal_file_float('amplitude.tif',trans,proj,amp)
saa.write_gdal_file_float('phase.tif',trans,proj,phase)









