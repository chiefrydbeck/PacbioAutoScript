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


PacbioAutoScript contains the code and a .git directory. So to issue git command one should stand in PacbioAutoScript.
The shell scripts is stored in ".../home/PacbioAutomation/PacbioAutoScript/shell/"

How I run the scripts
cd ../home/PacbioAutomation/AutomationRun
screen -S testPacbioAutomation
sh /work/projects/nscdata/PacbioAutomation/PacbioAutoScript/shell/rsyncPacBioSampleTgzToNorstore.sh /work/projects/nscdata/PacbioAutomation/DelivInstrucs/01_Test 1>test_1.out 2>test_1.err
#When the above is done
screen -rd testPacbioAutomation
sh /work/projects/nscdata/PacbioAutomation/PacbioAutoScript/shell/finaliseNorstoreDeliveryFolder.sh /work/projects/nscdata/PacbioAutomation/DelivInstrucs/01_Test 1>test_2.out 2>test_2.err
## Currently the two scripts needs to be run at the same date. Otherwise the folder names will have different names in them.

../home/PacbioAutomation/DelivInstrucs/01_Test must contain a "parForShell.sh" and a "SMRTcells.txt" file.

"parForShell.sh should have the following format(it woudl be nice if it also included the user email adresses):
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
Symbolic links to folders is created in a folder /work/projects/nscdata/temp/$extSampleName using ginformatin from SMRTcell.txt 
Files of interest from these folders is selected and compressed into tarball "$extSampleName.tgz" keeping the file structure of the original SMRTcell folder.
The tarball is copied to Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d) at Norstore


 finaliseNorstoreDeliveryFolder.sh  WILL DO THE FOLLOWING:
ABEL
parForShell.sh is read
NORSTSTORE
An md5sums.txt file is created in Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
.htaccess is also created with "require user $refLastNameCust_lower-$sampleType"
Password for user is added to the password database at norstore
The password is written to a file starting with dron_ so that it can be included in the delivery email to the user.

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




