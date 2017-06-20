##cmd line parameters
dir_deliv_instrux="/work/projects/nscdata/PacbioAutomation/DelivInstrucs/03_Sequel"
projFoldName=$1

##Read parForShell.sh
. $dir_deliv_instrux/$projFoldName/parForShell.sh

##Make variable string content lower case
ln_usr_lower=$( echo "$ln_usr" | tr -s  '[:upper:]'  '[:lower:]' )

##Define project folder name
projectFolderName=Project\_$ln_usr\_$sampleType\_$(date +%Y-%m-%d)\_sequel
echo $projectFolderName

##enter delivery folder
cd /work/projects/nscdata/PacbioAutomation/Sequel_out_for_norstore_deliv

##create project folder for symlinks
mkdir -p "${projectFolderName}_symlinks"

##enter project folder for symlinks
cd "${projectFolderName}_symlinks"

##Create folder for symlinks named with externalSampleName
mkdir -p ${extSampleName}

##enter symlinks folder named with externalSampleName
cd ${extSampleName}

echo "Creating SMRTcell directories with symlinks"
while read file1; do

	echo "##############New smrtCell###############"
	##remove the last character, in case its a slash
	file2="${file1%?}"
	echo "path to smrtCell is:" $file2

	##count number of occurrences of slash in file2
	number_of_occurrences=$(grep -o "/" <<< "$file2" | wc -l)
	echo "number of slashes in path is:"$number_of_occurrences

	##select name of SMRTcell parent folder
	runFolder=$(echo $file1| cut -d'/' -f $number_of_occurrences)
	smrtCell=$(echo $file1| cut -d'/' -f $((number_of_occurrences+1)))
	echo "runfolder is:" $runFolder
	echo "smrtCell is:" $smrtCell

	mkdir $runFolder
	cd $runFolder
	echo "We are now in:"
	pwd

	echo "Making symlingk with:"
	echo eval ln\ -s\ \$file2 \${smrtCell}
	eval ln\ -s\ \$file2 \${smrtCell}

	cd ..
	echo "We are now in:"
	pwd

done < $dir_deliv_instrux/$projFoldName/SMRTcells.txt

##Step up into Sequel_out_for_norstore_deliv folder #Sequel project
cd ../..

##create project folder for tar file
mkdir -p "${projectFolderName}"

##enter project folder for tar file
cd "${projectFolderName}"


echo "Creating tarball"
find -L ../ "${projectFolderName}_symlinks"/${extSampleName} -iname "*.fasta" -o -name "*.bam" -o -name "*.pbi" -o -name "*.xml" | tar -h -czvf $extSampleName.tgz -T -

##Remove folder so that it does not get copied along with tar ball. 
##This should be a temporary solution (until it is possible to copy file s with parallel rsync script)
#rm -rf ../${extSampleName}_symlinks

##make md5sum file
md5sum $extSampleName.tgz  > $md5sum.txt

##Step up into Sequel_out_for_norstore_deliv folder
cd ..

##Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
rsync -av "${projectFolderName}" login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/$projectFolderName
echo "Copying tar file"
