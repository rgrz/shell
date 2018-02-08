#!/bin/bash

# download new pics from ESA Image of the week into ~/Pictures/ESA/images

cd ~/Pictures/ESA; rm ~/Pictures/ESA/ESA_LINKS.txt

echo creating image list

# wget source html and sed's to extract the complete url to each file. Then write the ouput to ESA_LINKS.txt
wget -O - http://www.esa.int/spaceinimages/Sets/Earth_observation_image_of_the_week\
| sed -n -e 's/_lv_top.*/.jpg/p' \
| sed -n -e 's/<img src="/http:\/\/www.esa.int/p' \
>  ~/Pictures/ESA/ESA_LINKS.txt

#cat /home/lebos/Pictures/ESA/Earth_observation_image_of_the_week | sed -n -e 's/_lv_top.*/.jpg/p' | sed -n -e 's/<img src="/http:\/\/www.esa.int/p' >  /home/lebos/Pictures/ESA/ESA_LINKS.txt

cd ~/Pictures/ESA/images

# create an array with all image names in folder
arr=( * )

echo curling new images
for i in `cat ~/Pictures/ESA/ESA_LINKS.txt`; do

	# basename extracts the file name from path/url
        fname=`basename $i`

	#if echo ${arr[@]} | fgrep --word-regexp "$fname"; then
	if [[ "${arr[*]}" =~ (^|[^[:alpha:]])$fname([^[:alpha:]]|$) ]]; then
        	echo $fname already downloaded
	else
		echo donwloading $fname

		# curl to download the file
		curl -O $i

		# add the new image to xfce's background image list file
		# echo ~/Pictures/ESA/images/"$fname" >> ~/Pictures/ESA/images/list_bck

		# Add image title to photo
		display_name=$(echo "$a" | sed "s/_/ /g" <<< $fname)
		display_name=${display_name/".jpg"/""}
		echo transforming image: $display_name
                convert "$fname" \
                 -pointsize 30 \
                 -draw "gravity southeast fill black text 0,12 '$display_name' fill white text 1,11 '$display_name' " "$fname"
	fi
done

notify-send 'New Images from ESA Download!' 'Check them in ~/Pictures/ESA' --icon=dialog-information
