#! /bin/tcsh -f
#  This script is reading the all the S1 data set listed and converted into
#  GAMMA internal format
#
#

set wrk = `pwd`  # setup current working dir
echo $wrk

foreach zipf ( *.zip ) # ($filen) 
        echo $zipf
        unzip $zipf
        set folder = `echo $zipf | cut -d '.' -f1`
        set datelong = `echo $zipf | cut -d '_' -f6`
        set acqdate = `echo $datelong | cut -d 'T' -f1`
        echo $folder  $datelong $acqdate
        cd $folder.SAFE

        par_S1_SLC measurement/s1a-iw1* annotation/s1a-iw1* annotation/calibration/calibration-s1a-iw1* annotation/calibration/noise-s1a-iw1* ${acqdate}_001.slc.par ${acqdate}_001.slc ${acqdate}_001.tops_par
        par_S1_SLC measurement/s1a-iw2* annotation/s1a-iw2* annotation/calibration/calibration-s1a-iw2* annotation/calibration/noise-s1a-iw2* ${acqdate}_002.slc.par ${acqdate}_002.slc ${acqdate}_002.tops_par
        par_S1_SLC measurement/s1a-iw3* annotation/s1a-iw3* annotation/calibration/calibration-s1a-iw3* annotation/calibration/noise-s1a-iw3* ${acqdate}_003.slc.par ${acqdate}_003.slc ${acqdate}_003.tops_par
        ls *_00*.slc >slctab
        ls *_00*.slc.par > slcpartab
        ls *_00*.tops_par > topstab
        paste slctab slcpartab topstab >SLC_TAB
        #SLC_mosaic_S1_TOPS SLC_TAB ${acqdate}_mos.slc ${acqdate}_mos.slc.par - - -
        set width = `awk '$1 == "range_samples:" {print $2}' ${acqdate}_003.slc.par`
        rasSLC ${acqdate}_003.slc $width 1 0 50 10

        mkdir $wrk/${acqdate}/
        mv *.slc* $wrk/${acqdate}/
        mv *.tops_par $wrk/${acqdate}/
        mv SLC_TAB $wrk/${acqdate}/

        cd $wrk
        rm -rf $folder.SAFE
end

