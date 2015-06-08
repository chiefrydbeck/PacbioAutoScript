#!/bin/bash
#Read Aves readme file with parameters for shell based on 
#How to read par file: http://stackoverflow.com/questions/17530141/how-to-include-a-file-containing-variables-in-a-shell-script
#echo $1/parForShell.sh
. $1/parForShell.sh
#Make variable string content lower case
refLastNameCust_lower=$( echo "$refLastNameCust" | tr -s  '[:upper:]'  '[:lower:]' )
emailRecipients=halfdanr@ibv.uio.no,alexajo@uio.no
#Create password for delivery folder
pw=$(tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | fold -w 12 | head -n 1)
#write pwd
rm ./dron_$extSampleName.txt
touch ./dron_$extSampleName.txt
echo "$pw" >> dron_$extSampleName.txt
##########################################SSH Norstore##########################################
ssh login.norstore.uio.no<<HERE
cd /projects/NS9012K/www/hts-nonsecure.uio.no/Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
#remove any previous md5sums.txts
rm ./md5sums.txts
#remove any previous .htaccess
rm ./.htaccess
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
htpasswd -b /norstore_osl/home/timothyh/.htpasswd ${refLastNameCust_lower}-${sampleType}
##how do I enter the passord automatically??This seem sto work
${pw}
${pw}
HERE
####################################################################################
##############################Formulate an email
####################################################################################
#http://stackoverflow.com/questions/4658283/shell-script-to-send-email
##########################################SSH Cod node##########################################
ssh cod3.uio.no <<HERE
cat > email.txt << EOF1
Subject:Pacbio sequence data ready for download - Project_${refLastNameCust}_${sampleType}_$(date +%Y-%m-%d)

The data can be downloaded from
https://webserver1.norstore.uio.no/Project_${refLastNameCust}_${sampleType}_$(date +%Y-%m-%d)

username: ${refLastNameCust_lower}-${sampleType}
Password: ${pw}

There are ??? data files available:
?.tgz ??.tgz

They contain the subreads.fastq, bax.h5 and metadata.xml files.

An md5sum.txt file is also included in the result folder. Please refer to our website (http://www.sequencing.uio.no/services/data-delivery/) for help on how to download the data and on how to use the md5sum.txt file to check whether the files are downloaded completely. 

Best regards,

Halfdan Rydbeck
EOF1
sendmail $emailRecipients < email.txt
#echo "sending email to $emailAdressOfScriptRunner using variable"
#echo "$extSampleName has been copied to Norstore. Runtime was $runtime" | mail -s "$extSampleName has been copied to Norstore" $emailRecipients
HERE
##########################################logout cod node##########################################

echo "Done!"
