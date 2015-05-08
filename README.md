# AutomationPacBio
Shell (and python) scripts for automatic delivery of PacBio output

This is the directory structure that I use when running the scripts:
(I use tree -d FolderName/ to display a tree like the one below)

../home/PacbioAutomation/
|-- AutomationRun
|   `-- Notes
|-- Bkg_tarballs
|-- DelivInstrucs
|   |-- 01_Test
|   |-- JeanFrancoisArrighi
|   |   `-- PB_0188.2
|-- PacbioAutoScript
|   |-- python
|   `-- shell
`-- Tarballs

The shell scripts is stored in ".../home/PacbioAutomation/PacbioAutoScript/shell/"

How I run the scripts
cd ../home/PacbioAutomation/AutomationRun
screen -S testPacbioAutomation
sh /work/users/halfdanr/PacbioAutomation/PacbioAutoScript/shell/rsyncPacBioSampleTgzToNorstore.sh /work/users/halfdanr/PacbioAutomation/DelivInstrucs/01_Test 1>test.out 2>test.err
#When the above is done
sh /work/users/halfdanr/PacbioAutomation/PacbioAutoScript/shell/finaliseNorstoreDeliveryFolder.sh /work/users/halfdanr/PacbioAutomation/DelivInstrucs/01_Test 1>test.out 2>test.err
## Currently the two scripts needs to be run on the same data. Otherwise the foldernames will use different dates

../home/PacbioAutomation/DelivInstrucs/01_Test must contain a "parForShell.sh" and a "SMRTcells.txt" file.

"parForShell.sh should have the following format:
wantRawData=Yes (or No)
refFirstNameCust=Firstname
refLastNameCust=Lastname
#external sample name
extSampleName=users_sampel_name	
#internal sample name
intSampleName=PB_0124		
sampleType=gdna

"SMRTcells.txt" lists the paths to all the SMRTcells for which results should be delivered.
It shoud have the following format:
/projects/nscdata/runsPacbio/2015run06_227/D04_1
/projects/nscdata/runsPacbio/2015run06_227/E04_1
/projects/nscdata/runsPacbio/2015run06_227/F04_1
/projects/nscdata/runsPacbio/2014run38_217/G09_1
/projects/nscdata/runsPacbio/2014run29_208/A01_1 

rsyncPacBioSampleTgzToNorstore.sh WILL DO THE FOLLOWING: 

ABEL
parForShell.sh is read

NORSTORE
A directory at /projects/NS9012K/www/hts-nonsecure.uio.no/ called Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d) is created

ABEL
Symbolic links to folders is created in a folder /work/users/halfdanr/temp/$extSampleName using ginformatin from SMRTcell.txt 
Files of interest from these folders is selected and compressed into tarball "$extSampleName.tgz" keeping the file structure of the original SMRTcell folder.
The tarball is copied to Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d) at Norstore


 finaliseNorstoreDeliveryFolder.sh  WILL DO THE FOLLOWING:
ABEL
parForShell.sh is read
NORSTSTORE
An md5sums.txt file is created in Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
.htaccess is also created with "require user $refLastNameCust_lower-$sampleType"
Password for user is added to the password database at norstore

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




