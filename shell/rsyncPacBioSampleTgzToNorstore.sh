#!/bin/bash
##########################################Remember
# Implement the choice between fastq and raw data
# Is the if statement correct?
# One  parameter is given at command line: Instruction folder at Abel
# Replace ProjectHalTest with Project
# test.txt should be replaced by $extSampleName.tgz
# Remove # for find tar command
# Replace md5sum *.txt with ©md5sum *.tgz
# How do I get lowercase for i.e. refLastNameCust
# Uncomment the add passord command
##########################################
#This shell script creates a tarball with folder structure:
#External sample name/SMRTcellFolder/Analysis_Results/
##########################################Working at Abel
#record time at start
start=$(date +%s.%N)
#Can optionally run a fast test of the script using small files
testOrFullScale=yes
#send email to whend finished (comma separated list)
emailRecipients=halfdanr@ibv.uio.no
#Read Aves readme file with parameters for shell based on 
#How to read par file: http://stackoverflow.com/questions/17530141/how-to-include-a-file-containing-variables-in-a-shell-script
#echo $1/parForShell.sh
. $1/parForShell.sh
#Make variable string content lower case
refLastNameCust_lower=$( echo "$refLastNameCust" | tr -s  '[:upper:]'  '[:lower:]' )
##########################################SSH Norstore##########################################Go to Norstore and create directory for delivery
ssh halfdanr@login.norstore.uio.no <<HERE
cd /projects/NS9012K/www/hts-nonsecure.uio.no/
mkdir Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
HERE
##########################################logout Norstore##########################################
#at Abel
cd /work/users/halfdanr/PacbioAutomation/
#make temporary folder to collect symlinks
mkdir -p Tarballs
#enter temp folder
cd Tarballs
#create SampleName,SMRTcell directory structure based on Aves readme file
#create folder named with external SampleName
mkdir -p $extSampleName 
cd $extSampleName
#create SMRTcell directories
while read file ; do
	#create symlinks
	#here the backslash before $file is crucial
	#http://www.unix.com/shell-programming-and-scripting/170834-cannot-create-variables-via-ssh-remote-machine.html
	eval ln\ -s\ \$file
#The Ave directory and SMRTcell.xt file is used here
done < $1/SMRTcells.txt
#step up temp into Pacbio_tarballs folder
cd ..
#Make tarball of subset of files in decretory structure base command (tar -h -czvf CIAT22838_R2.tgz *_subreads.fastq *.metadata.xml *.bax.h5)
#link for info:http://www.cyberciti.biz/faq/linux-unix-find-files-with-symbolic-links/
#link for info:http://stackoverflow.com/questions/18731603/how-to-tar-certain-file-types-in-all-subdirectories

if [ wantRawData=="yes" ]
then
echo "The user wants raw data"
echo "Creating the tarball"
   find -L ./$extSampleName -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf $extSampleName.tgz -T -
   #remove folder so that it does not get copied along with tar ball. This should be a temporary solution (until it is possible to copy file s with parallel rsync script)
   rm -rf ./$extSampleName
   #Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
   #rsync -av $extSampleName.tgz halfdanr@login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
	#using script for parallell rsync instead: Only takes content of a directory as input
	echo "Copying tar file"
	/work/users/halfdanr/shellScripts/rsync_parallel.sh --parallel=8  -av ./ halfdanr@login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
else
   echo "The user do not want raw data"
   echo "Creating the tarball"
   find -L ./$extSampleName -iname "*.subreads.fastq" | tar -h -czvf $extSampleName.tgz -T -
   #remove folder so that it does not get copied along with tar ball. This should be a temporary solution (until it is possible to copy file s with parallel rsync script)
   rm -rf ./$extSampleName
   #Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
   #rsync -av $extSampleName.tgz halfdanr@login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
	#using script for parallell rsync instead: Only takes content of a directory as input
	echo "Copying tar file"
	/work/users/halfdanr/shellScripts/rsync_parallel.sh --parallel=8  -av ./ halfdanr@login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
fi

#find -L ./$extSampleName -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf $extSampleName.tgz -T -

#Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
#rsync -av $extSampleName.tgz halfdanr@login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
#record time at end
end=$(date +%s)
#calculate runtime
runtime=$(python -c "print(${end} - ${start})")
#send email
##########################################SSH Cod node##########################################Go to cod node to send email
ssh halfdanr@cod3.uio.no <<HERE
#cat > email.txt << EOF1
#Subject:$extSampleName has been copied to Norstore

#$extSampleName has been copied to Norstore. Runtime was $runtime.
#EOF1
#sendmail halfdanr@ibv.uio.no < email.txt
echo "sending email to $emailAdressOfScriptRunner using variable"
echo "$extSampleName has been copied to Norstore. Runtime was $runtime" | mail -s "$extSampleName has been copied to Norstore" $emailRecipients
HERE
##########################################logout cod node##########################################










