#Convert sequel bam to fastq
##load smrtlink module 
module load smrtlink

##cmd line parameters
dir_deliv_instrux="/work/projects/nscdata/PacbioAutomation/DelivInstrucs/03_Sequel"
projFoldName=$1

while read smrtCellPath; do
	if [ -n "$smrtCellPath" ]; then
	number_of_occurrences=$(grep -o "/" <<< "$smrtCellPath" | wc -l)
	#echo "smrtCell=$(echo $smrtCellPath| cut -d'/' -f $(number_of_occurrences))"
	smrtCell=$(echo $smrtCellPath| cut -d'/' -f $number_of_occurrences)
	runFolder=$(echo $smrtCellPath| cut -d'/' -f $((number_of_occurrences-1)))
	rAnds=$runFolder"/"$smrtCell"/"
	inputPath=${smrtCellPath%${rAnds}}
	echo "##############run:"${runFolder}" smrtcell: "${smrtCell}"###############"
	echo "Converting bam to fastq in :" ${smrtCellPath}
	cd $smrtCellPath
	for bamFile in *.bam
		do
		fn_no_ext="${bamFile%.*}"
		echo bamtools convert -format fastq -in $fn_no_ext.bam -out $fn_no_ext.fastq
		bamtools convert -format fastq -in $fn_no_ext.bam -out $fn_no_ext.fastq
		done
	echo " "
	fi
done < $dir_deliv_instrux/$projFoldName/SMRTcells.txt

