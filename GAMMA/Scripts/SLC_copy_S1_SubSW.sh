#! /bin/bash -f
#  This script is preparing S1 data for interferometry processing
#  1. Data will be prepared as full swath (three) mosaiced
#  2. For master image the DEM data will be prepared
#     Make sure the DEM data is provided, modifed the line
#
#
#  Create by W.G, 2015
#
#
if [ "$#" -le 9 ]
then
    echo " "
    echo "$0: Preparing for the Sentinel-1 SLC data, Organize folder and DEM, swath by swath"
    echo "                                                                       05/2015 W.G"
    echo " "
    echo "USAGE: $0 <IFG_Folder> <SLC identifier> <SLC_TAB> <Burst Index-First> <Burst Index-Last> <Master/Slave>"
    echo "       1. IFG_Folder      Absolute pass of desination folder "
    echo "       2. SLC Id          SLC identifier (example: 20150429)"
    echo "       3. SLC_TAB         Corresponding SLC tab file"
    echo "                          1st row- iw1_SLC iw1_SLC_par iw1_TOPSAR_par"
    echo "                          2nd row- iw2_SLC iw2_SLC_par iw2_TOPSAR_par"
    echo "                          3rd row- iw3_SLC iw3_SLC_par iw3_TOPSAR_par"
    echo "       4. Burst SW1Id-1   Burst 1 of the first burst to copy in SLC swath1"
    echo "       5. Burst SW1Id-2   Burst 1 of the last burst to copy in SLC swath1"
    echo "       6. Burst SW2Id-1   Burst 2 of the first burst to copy in SLC swath2"
    echo "       7. Burst SW2Id-2   Burst 2 of the last burst to copy in SLC swath2"
    echo "       8. Burst SW3Id-1   Burst 3 of the first burst to copy in SLC swath3"
    echo "       9. Burst SW3Id-2   Burst 3 of the last burst to copy in SLC swath3"
    echo "       10. M/S          Master/Slave image flag"

    echo "                       input 1 for master"
    echo "                       input 2 for slave"
    echo "       11. DEM_folder   Absolute pass of DEM data folder"
    echo "       12. DEM Id       DEM identifier (example, "Nepal" for Nepal.par Nepal.dem)"
    echo ""
    echo "EXAMPLE: $0 /import/c/w/gong/Kenny/S1_Nepal_postseismic/track_1032/20150506_20150518_lower 20150506  SLC_TAB 1 2 1 2 1 3 1 "
    exit
fi



#if [ "$#" -ge 4 ]; then
#        rlks=$4
#fi


path=${1}/
slcname=$2
tabin=$3
#burstu=$4
#burstl=$5



msflag=${10}
tabout0=${tabin}_out
raml=10
azml=2

dempath=${11} #/import/c/w/gong/Kenny/DEM/Galapagos/
demname=${12} #final_Galapagos
demovr1=1
demovr2=1


echo $dempath
echo $demname
echo "$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}" > $path/SLC_copy_S1_bash_${msflag}.log
echo ""

wrk=`pwd`  # setup current working dir

# preparing the folder savee swath moscaic

#if [ -e  ${tabout0} ]
#then
#rm ${tabout0}
#fi

#if [ -e  ${tabin}_sw ]
#then
#rm ${tabout0}
#fi

i=1;
while read p ; do
	slc=`echo $p | cut -d ' ' -f1`
	par=`echo $p | cut -d ' ' -f2`
	top=`echo $p | cut -d ' ' -f3`
	echo $p > ${tabin}_sw${i}
	echo ${path}/${slc} ${path}/${par} ${path}/${top}>${tabout0}_sw${i}
	i=$(($i + 1))
done <$tabin


if [ $4 -ne 0 ]; then
echo "##=============- SW1 -================" >>$path/SLC_copy_S1_bash_${msflag}.log

echo "SLC_copy_S1_TOPS ${tabin}_sw1  ${tabout0}_sw1 1 $4 1 $5"
      SLC_copy_S1_TOPS ${tabin}_sw1  ${tabout0}_sw1 1 $4 1 $5 >> $path/SLC_copy_S1_bash_${msflag}.log
      cp ${tabin}_sw1 ${tabin}2
echo ""
fi

if [ $6 -ne 0 ]; then
echo "##=============- SW2 -================" >>$path/SLC_copy_S1_bash_${msflag}.log

echo "SLC_copy_S1_TOPS ${tabin}_sw2  ${tabout0}_sw2 1 $6 1 $7"
      SLC_copy_S1_TOPS ${tabin}_sw2  ${tabout0}_sw2 1 $6 1 $7 >> $path/SLC_copy_S1_bash_${msflag}.log

      if [ -e ${tabin}2 ]; then
         paste -s ${tabin}_sw1 ${tabin}_sw2  > ${tabin}2
      else
         cp ${tabin}_sw2 ${tabin}2
      fi
echo ""
fi

if [ $8 -ne 0 ]; then
echo "##=============- SW3 -================" >>$path/SLC_copy_S1_bash_${msflag}.log

echo "SLC_copy_S1_TOPS ${tabin}_sw3  ${tabout0}_sw3 1 $8 1 $9"
      SLC_copy_S1_TOPS ${tabin}_sw3  ${tabout0}_sw3 1 $8 1 $9 >> $path/SLC_copy_S1_bash_${msflag}.log
      if [ -e ${tabin}2 ]; then
         #cp ${tabin}2 ${tabin}tmp
         #paste -s ${tabin}tmp  ${tabin}_sw3 > ${tabin}2
        tmpa=`more ${tabin}_sw3`
        echo $tmpa >> ${tabin}2
      else
        cp ${tabin}_sw3 ${tabin}2
      fi
echo ""
fi


cp ${tabin}2 ${path}/${tabin}


cd ${path}/
echo 'cd `pwd`' >>$path/SLC_copy_S1_bash_${msflag}.log

echo "SLC_mosaic_S1_TOPS ${tabin} ${slcname}.slc ${slcname}.slc.par $raml $azml"
      SLC_mosaic_S1_TOPS ${tabin} ${slcname}.slc ${slcname}.slc.par $raml $azml >> $path/SLC_copy_S1_bash_${msflag}.log
echo ""

width=`awk '$1 == "range_samples:" {print $2}' $slcname.slc.par`

echo "rasSLC $slcname.slc $width 1 0 50 10"
      rasSLC $slcname.slc $width 1 0 50 10 >> $path/SLC_copy_S1_bash_${msflag}.log
echo ""


echo "multi_S1_TOPS ${tabin}  ${slcname}.mli ${slcname}.mli.par $raml $azml"
      multi_S1_TOPS  ${tabin} ${slcname}.mli ${slcname}.mli.par $raml $azml >> $path/SLC_copy_S1_bash_${msflag}.log
echo ""


echo $msflag
if [ "$msflag" = "1" ]
then
	if [ ! -d DEM ]
   	then
	mkdir DEM
	fi

	cd DEM

	mliwidth=`awk '$1 == "range_samples:" {print $2}' ../${slcname}.mli.par`
	mlinline=`awk '$1 == "azimuth_lines:" {print $2}' ../${slcname}.mli.par`
	echo `pwd` >>$path/SLC_copy_S1_bash_${msflag}.log

	echo "GC_map_mod ../${slcname}.mli.par  - $dempath/${demname}.par $dempath/${demname}.dem $demovr1 $demovr2 demseg.par demseg ${slcname}.mli  MAP2RDC inc pix ls_map 1 1"
echo "GC_map_mod ../${slcname}.mli.par  - $dempath/${demname}.par $dempath/${demname}.dem $demovr1 $demovr2 demseg.par demseg ${slcname}.mli  MAP2RDC inc pix ls_map 1 1" >> $path/SLC_copy_S1_bash_${msflag}.log
	GC_map_mod ../${slcname}.mli.par  - $dempath/${demname}.par $dempath/${demname}.dem $demovr1 $demovr2 demseg.par demseg ../${slcname}.mli  MAP2RDC inc pix ls_map 1 1 # >> $path/SLC_copy_S1_bash.log

 	demwidth=`awk '$1 == "width:" {print $2}' demseg.par`

	echo "geocode MAP2RDC demseg $demwidth HGT_SAR_${raml}_${azml} $mliwidth $mlinline"
	geocode MAP2RDC demseg $demwidth HGT_SAR_${raml}_${azml} $mliwidth $mlinline #>> $path/SLC_copy_S1_bash_${msflag}.log


	echo "GC_map_mod ../${slcname}.mli.par  - $dempath/${demname}.par $dempath/${demname}.dem $demovr1 $demovr2 demseg.par demseg ../${slcname}.mli  MAP2RDC inc pix ls_map 1 1" > geocode.log
	echo "geocode MAP2RDC demseg $demwidth HGT_SAR_${raml}_${azml} $mliwidth $mlinline" >> geocode.log
	cd ..
fi
echo ""

cp ${tabin} SLC${msflag}_tab
cd $wrk

echo `pwd` >>$path/SLC_copy_S1_bash_${msflag}.log
echo "##-------------finish sw$i --------------------##">>$path/SLC_copy_S1_bash_${msflag}.log
echo "###----------------------------------------------##">>$path/SLC_copy_S1_bash_${msflag}.log

#<$tabin
