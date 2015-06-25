#!/bin/bash
#This shell script creates a tarball with folder structure:
#External sample name/SMRTcellFolder/Analysis_Results/
# The tarball is rsynced to Norstore 
#An email with start and end time is sent to $emailRecipients when the copying is finshed
#
##########################################Working at Abel######################################
##Record time at start
start=$(date +%s.%N)
##Can optionally run a fast test of the script using small files. Not in use yet
#testOrFullScale=yes
##Send email to when finished (comma separated list)
emailRecipients=${USER}@uio.no
##Read parForShell.sh use data form Aves readme file
##How to read par file: 
##http://stackoverflow.com/questions/17530141/how-to-include-a-file-containing-variables-in-a-shell-script
##The format of parForShell.sh is described in README.md
#echo $1/parForShell.sh
. $1/parForShell.sh
##Make variable string content lower case
refLastNameCust_lower=$( echo "$refLastNameCust" | tr -s  '[:upper:]'  '[:lower:]' )
######################Go to Norstore and create directory for delivery##########################
##########################################SSH Norstore##########################################
ssh login.norstore.uio.no <<HERE
cd /projects/NS9012K/www/hts-nonsecure.uio.no/
mkdir Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
HERE
##########################################logout Norstore########################################
##At Abel
cd /work/projects/nscdata/PacbioAutomation/
##Make temporary folder to collect symlinks
mkdir -p Tarballs
##Enter temp folder
cd Tarballs
##Create SampleName,SMRTcell directory structure based using variables from parForShell.sh that should be in directory provided when calling this script.
##Create folder named with external SampleName
mkdir -p $extSampleName 
cd $extSampleName
##Create SMRTcell directories
while read file ; do
	##Create symlinks
	##Here the backslash before $file is crucial
	##http://www.unix.com/shell-programming-and-scripting/170834-cannot-create-variables-via-ssh-remote-machine.html
	eval ln\ -s\ \$file
##The SMRTcell.xt file is used here. It is provided by Ave (lab team) and should be in directory provided when calling this script.
done < $1/SMRTcells.txt
##Step up temp into Pacbio_tarballs folder
cd ..
##Make tarball of subset of files in decretory structure base command 
#(tar -h -czvf CIAT22838_R2.tgz *_subreads.fastq *.metadata.xml *.bax.h5)
##Link for info:http://www.cyberciti.biz/faq/linux-unix-find-files-with-symbolic-links/
##Link for info:http://stackoverflow.com/questions/18731603/how-to-tar-certain-file-types-in-all-subdirectories
if [ wantRawData=="yes" ]
then
echo "The user wants raw data"
echo "Creating the tarball"
   find -L ./$extSampleName -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf $extSampleName.tgz -T -
   ##Remove folder so that it does not get copied along with tar ball. 
   ##This should be a temporary solution (until it is possible to copy file s with parallel rsync script)
   rm -rf ./$extSampleName
   ##Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
   rsync -av $extSampleName.tgz login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
	##Using script for parallell rsync instead: Only takes content of a directory as input
	echo "Copying tar file"
	export PATH=$PATH:/usit/abel/u1/olews/work/parsyncfp
	##Using a script for parallel copying provided by Ole Widar Saastad from USIT
	#/work/projects/nscdata/shellScripts/rsync_parallel.sh --parallel=8  -av ./ login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
	##Using par
	#parsyncfp -NP=24 $extSampleName.tgz login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
else
   echo "The user do not want raw data"
   echo "Creating the tarball"
   find -L ./$extSampleName -iname "*.subreads.fastq" | tar -h -czvf $extSampleName.tgz -T -
   ##Remove folder so that it does not get copied along with tar ball. This should be a temporary solution (until it is possible to copy file s with parallel rsync script)
   rm -rf ./$extSampleName
   ##Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
   rsync -av $extSampleName.tgz login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
	##Using script for parallell rsync instead: Only takes content of a directory as input
	echo "Copying tar file"
	#/work/projects/nscdata/shellScripts/rsync_parallel.sh --parallel=8  -av ./ login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
	##Using par
	#parsyncfp -NP=24 $extSampleName.tgz login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
fi

#find -L ./$extSampleName -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf $extSampleName.tgz -T -

##Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
#rsync -av $extSampleName.tgz login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
##Record time at end
end=$(date +%s)
##Calculate runtime
runtime=$(python -c "print(${end} - ${start})")
##Send email
##########################################Go to cod node to send email##########################
##########################################SSH Cod node##########################################
ssh cod3.uio.no <<HERE
#cat > email.txt << EOF1
#Subject:$extSampleName has been copied to Norstore

#$extSampleName has been copied to Norstore. Runtime was $runtime.
#EOF1
#sendmail ${USER}@uio.no
echo "sending email to ${emailRecipients} using variable"
echo "${extSampleName} has been copied to Norstore. Runtime was ${runtime}" | mail -s "${extSampleName} has been copied to Norstore" ${emailRecipients}
HERE
##########################################logout cod node##########################################










