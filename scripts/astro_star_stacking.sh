#!/bin/bash
#######################################################################################
#
#	file		:	astro_star_stacking.sh
#	date		:	02/07/2015
#	version		:	0.1 - Average Black Frames
#			:	0.2 - Subtract Black Frame from Star Frames
#			:	0.3 - Align star images
#			:	0.4 - Average star images
#	requires	:	hugin, dcraw, imagemagick
#	copyright	:	(c) st599 MMXV
#
#######################################################################################


echo "ASTRO STAR STACKING shell script"
echo ""
echo " (c) st599 ver 0.4"

#####################
# Black Frames      #
#####################

echo "...BLACK FRAMES"

cd blackframes

# Convert Canon CR2 Frames to TIFF

echo "......Convert CR2 to Linear TIFF"

for file in *.CR2
do
	dcraw -T -4 $file
done

echo "......Average Black Frames"

convert *.tiff -alpha off -evaluate-sequence mean -depth 16 blackframe.tiff
convert *.tiff -alpha off -evaluate-sequence median -depth 16 blackframe1.tiff

echo "......Move Black Frame"

mv blackframe.tiff blackframe1.tiff ../starframes

echo "......Tidy Up"

rm *.tiff

cd ..

#####################
# Star Frames       #
#####################

echo "...STAR FRAMES"

cd starframes

# Convert Canon CR2 Frames to TIFF

echo "......Convert CR2 to Linear TIFF and Subtract Black File"

for file in *.CR2
do
	dcraw -T -4 $file
	composite -compose minus ${file%.CR2}.tiff blackframe.tiff -depth 16 corr1_${file%.CR2}.tiff
	composite -compose minus ${file%.CR2}.tiff blackframe1.tiff -depth 16 corr2_${file%.CR2}.tiff
done

echo "......Align Image Stack"

fl='corr1*.tiff'

align_image_stack -v -a ais1 $fl

fl='corr2*.tiff'

align_image_stack -v -a ais2 $fl

echo "......Average Corrected Star Frames"

convert ais1*.tif -alpha off -evaluate-sequence mean -depth 16 final_stars1.tiff
convert ais1*.tif -alpha off -evaluate-sequence median -depth 16 final_stars2.tiff
convert ais2*.tif -alpha off -evaluate-sequence mean -depth 16 final_stars3.tiff
convert ais2*.tif -alpha off -evaluate-sequence median -depth 16 final_stars4.tiff

echo "......Convert to sRGB"

convert final_stars1.tiff -set colorspace RGB -colorspace sRGB -depth 16 final_stars1.tiff
convert final_stars2.tiff -set colorspace RGB -colorspace sRGB -depth 16 final_stars2.tiff
convert final_stars3.tiff -set colorspace RGB -colorspace sRGB -depth 16 final_stars3.tiff
convert final_stars4.tiff -set colorspace RGB -colorspace sRGB -depth 16 final_stars4.tiff
mv final_stars*.tiff ../

rm *.tiff

cd ..

echo "......PROCESS FINISHED"

