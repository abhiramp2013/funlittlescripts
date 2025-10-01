#!/usr/bin/env bash
shopt -s globstar
shopt -s dotglob

#NOTE - takes about 2 seconds for 600 files
echo -en "\nDisplaying a list of files arranged under their types, along with the count. :\n\n" >&2


WORKING_DIR=$1
#PROCESSOR_SCRIPT=$2
DELIM='.'

quickpartition(){
	
	echo -en "\n-----------------------------------------\n\n"
}

#if [ -z $PROCESSOR_SCRIPT ]
#then
#	echo "[INFO] PROCESSOR_SCRIPT variable is not set ! No processing specified !"
#else
#	source $PROCESSOR_SCRIPT
#	echo "[INFO] Sourcing PROCESSOR_SCRIPT = $PROCESSOR_SCRIPT" 
#fi

if [ -z $WORKING_DIR ]
then
	WORKING_DIR=$(pwd)
fi

echo "[INFO] Working on directory : $WORKING_DIR"  >&2

PS4='[INFO] '
set -x
cd $WORKING_DIR
set +x


echo "[INFO] Proccessing..." >&2
# 1 -> List of all files and directories in the path
tmp_all_files=(**)
OLDIFS=$IFS
IFS=$'\n'

# 2 -> List of all directories
all_dirs=($(find . -type d | sed 's/^.\///' | tail -n +2))
all_files=()

# 3 -> List of all files and not directories
for i in "${tmp_all_files[@]}"; do
	found=0
	for j in "${all_dirs[@]}"; do
		#echo "comparning $j    with     $i"
		if [[ "$j" == "$i" ]]
		then
			found=1
		fi
	done
	[ $found -eq 0 ] && all_files+=($i)		
done
IFS=$OLDIFS



# Ammend this regex if it doesn't cover the file types you intended, eg. with special chars in it
# or pass this as an argument
ext_pat="[^\.](\.[a-zA-Z0-9]+$)"		

for i in "${all_files[@]}"; do
	if [[ $i =~ $ext_pat ]]
	then
		all_exts+=(${BASH_REMATCH[1]})
	fi
done

ext_arr=($(printf "%s\n" "${all_exts[@]}" | sort -u))

quickpartition
echo -n "EXTENSION TYPES IN $WORKING_DIR :    "
echo "${ext_arr[*]}" 


#Sorting files with extensions and no extensions
OLDIFS=$IFS
IFS=$'\n'

echo
for ext in "${ext_arr[@]}";do
	
	found=0
	arrname="${ext:1}_extension"
	
	ext_patt=".*\\$ext$"
	for f in "${all_files[@]}"; do
		if [[ "$f" =~ $ext_patt ]]
		then
			found=1
			eval "$arrname+=(\"$f\")"
			#echo $f
		fi
	done
	[ $found -eq 1 ] && ext_arr_list+=($arrname)
done

echo
echo "LIST OF FILES PER EXTENSION:"
for arr in "${ext_arr_list[@]}"; do
	
	echo
	echo -n "$arr list : "
	eval "printf \"%s\n\" \"\${#$arr[@]}\""
	all_ext_array+=($(eval "printf \"%s\n\" \"\${$arr[@]}\""))
	eval "printf \"%s\n\" \"\${$arr[@]}\""

done

echo
for i in "${all_files[@]}"; do
	found=0
	for j in "${all_ext_array[@]}"; do
		if [[ "$j" == "$i" ]]
		then
			found=1
		fi
	done
	[ $found -eq 0 ] && non_ext_files+=($i)		
done
IFS=$OLDIFS

echo
echo "Files Without Any OR Ambiguos Extension : ${#non_ext_files[@]}"
printf "%s\n" "${non_ext_files[@]}"


####
echo
quickpartition
echo "Number Of Directories - ${#all_dirs[@]}"
echo "Number Of Files       - ${#all_files[@]}"
quickpartition



# FUTURE TODO : 
# Also provide a small help message ?
# assuming . is the delimiter for extensions

# Make them all start with the default process
# Allow someone to change the process - and then add the name of the function to the same file or a separate 
# file with all functions and source it in this file
#
# Create a usage , and helper
# Trap a kill and do any clean up necessary or simply trap for fun
# No headers or info - just output - use a flag && echo 
# Full path or only the current path - based on $WORKING_DIR or cd to $WORKING_DIR set path based on flag
# Only display the count or only display the files - simple variable in the loop for printing LIST OF FILES PER EXTENSION
