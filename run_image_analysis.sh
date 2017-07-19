


rm -rf images/forvisualcheck*
rm -rf images/resultsfiles
 

echo " "
echo "...creating directories:  forvisualcheck & resultsfiles ..."
echo " "
mkdir images/forvisualcheck-croppedimages
mkdir images/forvisualcheck-fullimages
mkdir images/resultsfiles



##
##
## below in the "find..." you change the --cutoff_area based on visual examination of overlay of yellow-rectangles over droplets in the image
##
## below in the "find..."  you change the template-bead-file-name based on the template-bead-image you are using
##
## below in the "find..." you tweak the --threshold value 
##
##
## below in the "find..." you change the *.png to *.jpg or *.jpeg or... based on your image file-type/ filename-extension 
##
##

find images -name "*.PNG" -o -name "*.png" -o -name "*.bmp" -o -name "*.BMP" | parallel python process_image-v6.py {} template-bead-set2.png --cutoff_area 2000 --exclude --threshold 0.55

#
#
#


echo "   "
echo "... moving files to appropriate filders..."
echo "   "
mv images/*forvisualinspection*.png images/forvisualcheck-croppedimages/
mv images/*processed_totaldroplets*.png images/forvisualcheck-fullimages/
#mv images/*distribution*.png images/forvisualcheck-fullimages/
mv images/*_summary.csv images/resultsfiles/


echo "   "
echo "...some more processing to put results together...."
echo "   "

seq 0 24 > number_of_beads 
awk 'NR==1{print FILENAME RS $0} NR>1 ' number_of_beads > tmp.txt 
paste -d , tmp.txt images/resultsfiles/*summary.csv > tmp.csv
sed s/"images\/"//g tmp.csv > summarized_results.csv
rm tmp.txt
rm tmp.csv


rm -rf output.csv
rm -rf inputcsvs.txt
ls images/*.csv > tmp.txt
sed s/"images\/"// tmp.txt > inputcsvs.txt
rm tmp.txt

for f in `cat inputcsvs.txt`
do
awk -F, 'BEGIN {OFS=","} {print $0}' images/$f | awk 'NR > 1'  > tmp.csv
sed 's/^/ '"$f,"'/' tmp.csv
rm tmp.csv
done > output.csv

echo "Filename, dropletID, beadsdetectedImage, NumberofBeads" > tmp.csv
cat tmp.csv output.csv | sed s/"images\/"//g |  sed s/_totaldroplets-[0-9]*_totalbeads-[0-9]*.csv// >  all_images_processed_results_together.csv

rm output.csv
rm tmp.csv


mv images/*.csv images/resultsfiles/  ## move these files the last   


echo "  "
echo "...Done!"
echo "  "

echo "...look for these files in the same directory as this script was called from:  summarized_results.csv  &  all_images_processed_results_together.csv"
echo "   "
echo "...look for these folders in the images directory: forvisualcheck-croppedimages, forvisualcheck-fullimages  &  resultsfiles "
echo "   "

