#!/bin/sh

#
# this script will filter files on not_contam_edges=TRUE or not_contam_bicon=TRUE
# it will format files in order to be input to mcl program
# it will call  mcl program to run clustering
# it will call check-MCL-cluster-assignments.py to check wrongly-split and wrongly-connected droplets 
#




#
## format files as MCL input
##
ls *_nbm.csv > inputs.txt

for file in `cat inputs.txt`
do
echo "   "
echo "...file being processed:"
echo $file

sed -s 's/\,/ /g' $file > tmp.txt
filename=$(basename $file .csv)
# for not_contam_edges=TRUE
awk '{ if($4 >=1 && ($10=="True" || $10="TRUE")) print $1, $2, $4}' tmp.txt | awk 'NR > 1' | awk '{$1="bc1" $1; print} '| awk '{$2="bc2" $2; print}' > $filename-nce-MCLin.txt

## for not_contam_edges=TRUE
echo "   "
echo "... created MCL input format file:"
echo $file-nce-MCLin.txt
stat $file-nce-MCLin.txt --printf="file-size: %s\n"
echo "...."

rm tmp.txt
done


echo "   "
echo "... done creating MCL input format files..."
echo "   "


#
## call MCL 
#

# for not_contam_edges=TRUE
ls *-nce-MCLin.txt > inputmcls.txt


for file in `cat inputmcls.txt`
do
echo " "
echo "mcl is running on the file:"
echo $file  
echo " "
filename=$(basename $file .txt)
mcl $file -I 1.2 --abc -o $filename-out
#rm $file
done


echo "   "
echo "... ran MCL on input files..."
echo "   "



##
## call python script to check wrongly-split or wrongly-connected droplets
##

for file in `cat inputs.txt`
do
echo " "
echo "checking wrongly-connected and wrongly-split droplets for:"
echo $file
filename=$(basename $file .csv)
## for not_contam_edges=TRUE
python check-MCL-cluster-assignments.py $file $filename-nce-MCLin-out 

echo "..."
echo ".x."
echo "..."
filename=$(basename $file .csv)
str1a="_mcl_labels.csv"
str1b="_nce_mcl_labels.csv"
filename1a="$filename$str1a"
filename1b="$filename$str1b"
str2a="_mcl_stats.txt"
str2b="_nce_mcl_stats.txt"
filename2a="$filename$str2a"
filename2b="$filename$str2b"
echo "...renaming file..." $filename1a "...as..." $filename1b
mv $filename1a $filename1b 
echo "...renaming file..." $filename2a "...as..." $filename2b
mv $filename2a $filename2b 
echo "..."
echo ".x."
echo "..."

done

#rm inputs.txt
#rm inputmcls.txt



