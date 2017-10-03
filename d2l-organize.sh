count=0
total_count=0

if [ ! -d "$1" ] && [ "$1" != "" ]; then			# first argument blank or nonexistent
	echo "Directory $1 does not exist. Cancelling."
elif [ ! -d "$2" ] && [ "$2" != "" ]; then			# second argument blank or nonexistent
	echo "Directory $2 does not exist. Create the $2 directory first."
elif [ "$1" != "" ] && [ "$2" != "" ]; then
	for file in "$1"/*.{tar,tar.gz}					# iterate through all .tar and .tar.gz archives
	do
		((total_count++))							# increment total count
		strip_prefix="${file#*-\ }"					# strip characters before name
		strip_suffix="${strip_prefix%*\ *\.tar*}"	# strip characters after name

		studentname=(a b c)								# array with name to be separated by spaces
		studentfile=(a b c)								# array with name to be separated by underscores

		IFS=' '
		names=()
		read -r -a names <<< "$strip_suffix"		# read string into indexed array
		i=0
		for elem in ${names[@]}						# move indexed array into studentname and student file
		do											#   -puts index 0 of old into index 1 of new
			((i++))
			studentname[${i}]="${elem}"
			studentfile[${i}]="${elem}"
		done

		studentname[0]="${studentname[$i]}"			# shove the lastname in the front
		studentfile[0]="${studentfile[$i]}"

		unset 'studentname[${#studentname[@]}-1]'	# remove duplicate last name from the end
		unset 'studentfile[${#studentfile[@]}-1]'

		final_studentname=()
		final_studentfile=()

		for elem in ${studentname[@]}				# build string from array
		do
			final_studentname+="${elem} "
			final_studentfile+="${elem}_"
		done

		studentname="${final_studentname%?}"		# workaround on the for loop, strips last space
		studentfile="${final_studentfile%?}"		# strips last underscore

		if [ ! -d "$2/${studentfile}" ]; then		#if directory does not exist
			mkdir "$2/${studentfile}"
			echo "Uncompressing ${studentname}'s archive into $2/${studentfile}..."
			tar -xf "${file}" -C "$2/${studentfile}" > /dev/null 2>&1
			if [ ! $? == 0 ]; then
				echo "*****ERROR: uncompressing ${studentname}'s archive. Unsupported format.*****"
			else
				((count++))							# increment count of successful uncompressions
			fi
		  else
			echo "Directory $2/${studentfile} exists. Skipping uncompression."
		fi
	done

	echo "Done. Uncompressed a total $count of $total_count archives."
else
	echo "Usage: <script.sh> <source directory> <destination>"
fi
