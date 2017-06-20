
##cmd line parameters
dir_deliv_instrux="/work/projects/nscdata/PacbioAutomation/DelivInstrucs/03_Sequel"
projFoldName=$1

##Read parForShell.sh
. $dir_deliv_instrux/$projFoldName/parForShell.sh

##Make variable string content lower case
ln_usr_lower=$( echo "$ln_usr" | tr -s  '[:upper:]'  '[:lower:]' )

##Define project folder name
projectFolderName=Project\_$ln_usr\_$sampleType\_$(date +%Y-%m-%d)\_sequel

echo "# The typical sequel output files are:"
echo "#	m54047__yyyyyy.adapters.fasta"
echo "#	m54047_xxxxxx_yyyyyy.scraps.bam"
echo "#	m54047_xxxxxx_yyyyyy.scraps.bam.pbi"
echo "#	m54047_xxxxxx_yyyyyy.sts.xml"
echo "#	m54047_xxxxxx_yyyyyy.subreads.bam"
echo "#	m54047_xxxxxx_yyyyyy.subreads.bam.pbi"
echo "#	m54047_xxxxxx_yyyyyy.subreadset.xml"
echo "#	m54047_xxxxxx_yyyyyy.transferdone"
echo "#	tmp-file-3910640661257096471.txt "
echo ""
echo "# This script collects the runs and smrtCells that belong to a project into a project folder"
echo "# Then is creates a tarball of the folder structure including the file types:"
echo ".fasta,.bam,.pbi, .xml and .fastq"
echo "# The fastq files have been  created with the script convertSequelBam2Fastq.sh"
echo ""
echo ""
##enter delivery folder
echo "# Entering delivery folder"
echo cd /work/projects/nscdata/PacbioAutomation/Sequel_out_for_norstore_deliv
cd /work/projects/nscdata/PacbioAutomation/Sequel_out_for_norstore_deliv

##remove any preexisting project folder for symlinks
rm -rf "${projectFolderName}_symlinks"

##create project folder for symlinks
echo "# Creating and entering project folder to collect symlinks"
echo mkdir -p "${projectFolderName}_symlinks"
mkdir -p "${projectFolderName}_symlinks"

##enter project folder for symlinks
echo cd "${projectFolderName}_symlinks"
cd "${projectFolderName}_symlinks"

##Create and enter folder for symlinks named with externalSampleName
echo "# Creating folder with external sample name"
echo mkdir -p ${extSampleName}
mkdir -p ${extSampleName}

##enter symlinks folder named with externalSampleName
echo cd ${extSampleName}
echo " "
cd ${extSampleName}

echo "# Creating a parent folder, with run name  as name, with symlinks to SMRTcells as  subfolders"

while read file1; do
	if [ -n "$file1" ]; then
	##remove the last character, in case its a slash
        file2="${file1%?}"
	##count number of occurrences of slash in file2
        number_of_occurrences=$(grep -o "/" <<< "$file2" | wc -l)
	##select name of SMRTcell parent folder
        runFolder=$(echo $file1| cut -d'/' -f $number_of_occurrences)
        smrtCell=$(echo $file1| cut -d'/' -f $((number_of_occurrences+1)))
	echo "##############run:"${runFolder}" smrtcell: "${smrtCell}"###############"
	
	echo mkdir $runFolder
	mkdir $runFolder
	echo cd $runFolder
	cd $runFolder
	echo "We are now in:"
	pwd

	echo "Making symlingk with:"
	echo eval ln\ -s\ \$file2 \${smrtCell}
	eval ln\ -s\ \$file2 \${smrtCell}

	echo cd ..
	cd ..
	echo "We are now in:"
	pwd
	
	echo " "
	fi
done < $dir_deliv_instrux/$projFoldName/SMRTcells.txt

##Step up into Sequel_out_for_norstore_deliv folder #Sequel project
echo cd ../..
cd ../..

echo "# A folder structure has now been created..."
echo tree "${projectFolderName}_symlinks"
tree "${projectFolderName}_symlinks" 
echo ""
echo "# ...lets make a tarball of it and md5sum it,..."
echo ""

##create project folder for tar file
echo "#...in a folder with the project folder name"
echo mkdir -p "${projectFolderName}"
mkdir -p "${projectFolderName}"

##enter project folder for tar file
echo cd "${projectFolderName}"
echo ""
cd "${projectFolderName}"


echo "# Creating tarball"
echo "find -L ../${projectFolderName}"_symlinks"/${extSampleName} -iname "*.fasta" -o -name "*.bam" -o -name "*.pbi" -o -name "*.xml" -o -name "*.fastq" | tar -h -czvf $extSampleName.tar -T -"
echo ""
find -L ../${projectFolderName}"_symlinks"/${extSampleName} -iname "*.fasta" -o -name "*.bam" -o -name "*.pbi" -o -name "*.xml"  -o -name "*.fastq" | tar -h -czvf $extSampleName.tgz -T -
#find -L ../${projectFolderName}"_symlinks"/${extSampleName} -iname "*.fasta" -o -name "*.bam" -o -name "*.pbi" -o -name "*.xml" -o -name "*.fastq" | tar -h -czvf $extSampleName.tgz -T -
echo ""
##make md5sum file
echo "Making md5sum"
echo "md5sum $extSampleName.tgz  > md5sum.txt"
echo ""
md5sum *.tgz  > md5sum.txt

##create .htaccess file
rm ./.htaccess
touch .htaccess
#echo "AuthUserFile /projects/NS9012K/www/hts-nonsecure.uio.no/Project_Ln_gdna_2017-06-12_sequel/${projectFolderName}/.htpasswd" >> .htaccess
echo "AuthUserFile /norstore_osl/home/timothyh/.htpasswd" >> .htaccess
echo "AuthGroupFile /dev/null" >> .htaccess
echo "AuthName ByPassword" >> .htaccess
echo "AuthType Basic" >> .htaccess
echo "" >> .htaccess
echo "<Limit GET>" >> .htaccess
echo "require user ${ln_usr_lower}-${sampleType}" >> .htaccess
echo "</Limit>" >> .htaccess

##create .htpasswd file
#echo htpasswd -bc .htpasswd ${ln_usr_lower}-${sampleType} ${sampleType}
#htpasswd -bc .htpasswd ${ln_usr_lower}-${sampleType} ${sampleType} 
##########################################SSH Norstore##########################################
ssh login.norstore.uio.no<<HERE
#Add the password to the password database file using the command below
htpasswd -b /norstore_osl/home/timothyh/.htpasswd ${ln_usr_lower}-${sampleType} ${sampleType}
HERE
####################################################################################
echo # Step up into Sequel_out_for_norstore_deliv folder
echo cd ..
echo ""
cd ..

echo "# Print tree"
echo tree "${projectFolderName}"
tree "${projectFolderName}"
echo ""

echo "# set permissions"
chmod 755 "${projectFolderName}"

echo "# Transferring project folder with tar and md5sum file to Norstore"
echo rsync -avp "${projectFolderName}" login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/
rsync -av "${projectFolderName}" login.norstore.uio.no:/projects/NS9012K/www/hts-nonsecure.uio.no/
