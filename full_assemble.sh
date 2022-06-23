#!/bin/bash

#DIRECTIONS

# to run: 
# chmod +x assemble.sh
# ./assemble.sh folder moviefilename start_fps end_fps textfile
#where:
#	$1 folder is folder containing instrument info
#	$2 moviefilename is name of movie file
#	$3 start_fps is frames per second of original movie
#	$4 end_fps is frames per second of final movie 
#	$5 textfile is file containing order of .jpg images in final version

# 1. Convert movie to library of frames as correct fps
cd part_data/$1
mkdir frames
echo "Extracting frames..."
ffmpeg -i "$2" -vf fps=$3 frames/"$1"_%05d.jpg
# 2. Create list of frames needed for adjusted video at 30 fps
# Run jupyter notebook in directory above and add in pertinent information
# Move output file to this directory
# 3.  Create new frames directory
mkdir new_frames

# 4. Copy data
i=0

while IFS= read -r line; do
    printf -v j "%05d" $i
    echo $j
    cp "./frames/$line" "./new_frames/frame_$j.jpg"

    i=$((i+1))
done < "$5"

# 5. Turn into moviei
ffmpeg -framerate "$4" -i ./new_frames/frame_%05d.jpg "$1"_adjusted.mp4


#6. clean up
rm -rf frames
rm -rf new_frames
