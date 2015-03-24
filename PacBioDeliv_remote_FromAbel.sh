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
#Can optionally run a fast test of the script using small files
testOrFullScale=yes
#Create password for delivery folder
pw=$(tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | fold -w 12 | head -n 1)
#Read Aves readme file with parameters for shell based on 
#How to read par file: http://stackoverflow.com/questions/17530141/how-to-include-a-file-containing-variables-in-a-shell-script
#echo $1/parForShell.sh
. $1/parForShell.sh
#Make variable string content lower case
refLastNameCust_lower=$( echo "$refLastNameCust" | tr -s  '[:upper:]'  '[:lower:]' )
#write pwd
rm ./dron_$extSampleName.txt
touch ./dron_$extSampleName.txt
echo "$pw" >> dron_$extSampleName.txt
##########################################SSH Norstore##########################################Go to Norstore and create directory for delivery
ssh halfdanr@login.norstore.uio.no <<HERE
cd /projects/NS9012K/www/hts-nonsecure.uio.no/
mkdir Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
HERE
##########################################logout Norstore##########################################
#at Abel
cd /work/users/halfdanr
#make temporary folder to collect symlinks
mkdir -p temp
#enter temp folder
cd temp
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
#step into temp folder
cd ..
#Make tarball of subset of files in decretory structure base command (tar -h -czvf CIAT22838_R2.tgz *_subreads.fastq *.metadata.xml *.bax.h5)
#link for info:http://www.cyberciti.biz/faq/linux-unix-find-files-with-symbolic-links/
#link for info:http://stackoverflow.com/questions/18731603/how-to-tar-certain-file-types-in-all-subdirectories

if [ wantRawData=="yes" ]
then
echo "The user wants raw data"
   find -L ./$extSampleName -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf $extSampleName.tgz -T -
   #Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
   rsync -av $extSampleName.tgz halfdanr@login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
else
   echo "The user do not want raw data"
    find -L ./$extSampleName -iname "*.subreads.fastq" | tar -h -czvf $extSampleName.tgz -T -
   #Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
   rsync -av $extSampleName.tgz halfdanr@login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
fi

find -L ./$extSampleName -iname "*.metadata.xml" -o -name "*.subreads.fastq" -o -name "*.bax.h5" | tar -h -czvf $extSampleName.tgz -T -

#Copy tarball to Norstore; test.txt should be replaced by $extSampleName.tgz
rsync -av $extSampleName.tgz halfdanr@login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
##########################################SSH Norstore##########################################
ssh halfdanr@login.norstore.uio.no<<HERE
cd /projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
#md5sum *.txt  > md5sums.txts
md5sum *.tgz > md5sums.txts
############create .htaccess file#####
rm ./.htaccess
touch ./.htaccess
echo "AuthUserFile /norstore_osl/home/timothyh/.htpasswd" >> .htaccess
echo "AuthGroupFile /dev/null" >> .htaccess
echo "AuthName ByPassword" >> .htaccess
echo "AuthType Basic" >> .htaccess
echo "" >> .htaccess
echo "<Limit GET>" >> .htaccess
echo "require user $refLastNameCust_lower-$sampleType" >> .htaccess
echo "</Limit>" >> .htaccess
########################
#Change the file rights so that the file(s) can be downloaded
chmod -R 755 *
#Add the password to the password database file using the command below
htpasswd /norstore_osl/home/timothyh/.htpasswd refLastNameCust_lower-$sampleType
##how do I enter the passord automatically??This seem sto work
$pw
$pw
HERE
####################################################################################
##############################Formulate an email
####################################################################################
#http://stackoverflow.com/questions/4658283/shell-script-to-send-email
#mail -s "Sequence ready for download - sequencing run XXXXX - sample $refLastNameCust" you@youremailid.com < /home/calvin/application.log
#rm ./letterForDeliveryToUser.txt
#touch ./letterForDeliveryToUser.txt
#echo "AuthUserFile /norstore_osl/home/timothyh/.htpasswd" >> ./letterForDelivery


#Hi,

#The data can be downloaded from
#https://webserver1.norstore.uio.no/Project_Arrighi-gDNA-2015-02-16

#username: arrighi-gdna
#password: puBXEEdrb4x8

#Subreads.fastq, bax.h5 and metadata.xml files are available in the file CIAT22838_R2.tgz

#Best regards,

#Halfdan Rydbeck




