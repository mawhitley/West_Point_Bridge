# processing in the folder where zip, slcs,ifg folder are
m=20170803
s=20170815 
ifg=${m}_${s}
sw1b1m=5 #0
sw1b2m=9 #0

sw2b1m=5 #1
sw2b2m=9 #7

sw3b1m=0 #1
sw3b2m=0 #7


sw1b1s=5 #0
sw1b2s=9 #0

sw2b1s=5 #1
sw2b2s=9 #7 

sw3b1s=0 #3
sw3b2s=0 #9

dempath=/Proj/s1_jinghe/DEM/
demname=Jinghe.filled
mlr=10
mla=2
it=3
 
wrkdir=`pwd`

#unzip SLC; extract to GAMMA internals
PAR_S1_SLC_SDV.sh
mkdir $ifg
#process master frame
cd $m
echo `pwd`
rm SLC_TAB2 SLC_TAB_*
echo "SLC_copy_S1_SubSW.sh $wrkdir/$ifg/ $m SLC_TAB $sw1b1m $sw1b2m $sw2b1m $sw2b2m $sw3b1m $sw3b2m 1 $dempath $demname"
SLC_copy_S1_SubSW.sh $wrkdir/$ifg/ $m SLC_TAB $sw1b1m $sw1b2m $sw2b1m $sw2b2m $sw3b1m $sw3b2m 1 $dempath $demname
cd $wrkdir

#process slave frame
cd $s
rm SLC_TAB2 SLC_TAB_*
echo "SLC_copy_S1_SubSW.sh $wrkdir/$ifg/ $s SLC_TAB $sw1b1s $sw1b2s $sw2b1s $sw2b2s $sw3b1s $sw3b2s 2 $dempath $demname"
SLC_copy_S1_SubSW.sh $wrkdir/$ifg/ $s SLC_TAB $sw1b1s $sw1b2s $sw2b1s $sw2b2s $sw3b1s $sw3b2s 2 $dempath $demname
cd $wrkdir

cd $ifg
INTERF_PWR_S1_LT_TOPS_Proc.sh $m $s ./DEM/HGT_SAR_${mlr}_${mla} $mlr $mla $it 0
INTERF_PWR_S1_LT_TOPS_Proc.sh $m $s 0 $mlr $mla $it 1 
#INTERF_PWR_S1_LT_TOPS_Proc.sh $m $s 0 $mlr $mla $it 2

ln -s $ifg.diff0 $ifg.diff0.man
Unwrapping_Geocoding_S1.sh $m $s man $mlr $mla 0 1 1
demw=`grep width: ./DEM/demseg.par | awk '{print $2}'`
demnl=`grep nlines: ./DEM/demseg.par | awk '{print $2}'`
ifgw=`grep range_samples $m.mli.par | awk '{print $2}'`
geocode_back $ifg.diff0 $ifgw ./DEM/MAP2RDC $ifg.diff0.man.geo $demw $demnl - 1

cd $wrkdir










