#!/bin/bash

# download new pics from ESA Image of the week into ~/Pictures/ESA/images
# add title of the image with imagemagick convert
# build for linux
# gnome desktop notifications: notify-send used

echo checking working folders
if [ ! -d "~/Pictures/ESA" ]; then
	echo creating working folder in ~/Pictures/ESA
	mkdir -p ~/Pictures/ESA
fi

if [ ! -d "~/Pictures/ESA/images" ]; then
	echo creating working folder in ~/Pictures/ESA/images
	mkdir -p ~/Pictures/ESA/images
fi

cd ~/Pictures/ESA; rm /home/lebos/Scripts/ESA/ESA_LINKS.txt

echo creating image list
if [ ! -e ~/Pictures/ESA/images/ESA_LINKS.txt ]; then
	echo creating ESA_LINKS
	touch ~/Pictures/ESA/images/ESA_LINKS.txt
fi

cd ~/Pictures/ESA/images

# create an array with all image names in folder
arr=( * )

page=1
mult=16
until [ $page -gt 4 ]
do
	((page++))

	echo pagina $(($page))
	wget -O - 'http://www.esa.int/spaceinimages/Sets/Earth_observation_image_of_the_week/(offset)/'$(($page*$mult))\
	| sed -n -e 's/_lv_top.*/.jpg/p' \
	| sed -n -e 's/<img src="/http:\/\/www.esa.int/p' \
	>  ~/Pictures/ESA/ESA_LINKS.txt

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
			#cd ~/Pictures/ESA/images
			curl -O $i

			# add the new image to xfce's background image list file
			if [ ! -e ~/Pictures/ESA/list_bck]; then
				echo creating list_block
				touch ~/Pictures/ESA/list_bck
			fi
			echo ~/Pictures/ESA/images/"$fname" >> ~/Pictures/ESA/list_bck

			# Add image title to photo
			display_name=$(echo "$a" | sed "s/_/ /g" <<< $fname)
			display_name=${display_name/".jpg"/""}
			echo transforming image: $display_name
		        convert "$fname" \
		         -pointsize 30 \
		         -draw "gravity south fill black text 0,12 '$display_name' fill white text 1,11 '$display_name' " "$fname"
		fi
	# new comment
	done

done
notify-send 'New Images from ESA Download!' 'Check them in ~/Pictures/ESA' --icon=dialog-information
