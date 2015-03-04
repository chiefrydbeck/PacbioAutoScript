# AutomationPacBio
Shell and python script for automatic delivery of PacBio output
 

EXAMPLE OF HOW TO CALL THE SCRIPT
sh PacBioDeliv_remote_FromAbel.sh /projects/nscdata/utsp/H/HoracioSchneider/PB_0124


The script should be run from Abel and needs as argument the path to a directory with delivery information. 
The directory must contain a "parForShell.sh" and a "SMRTcells.txt"
An example directory with delivery information is located (at Abel) at /projects/nscdata/utsp/H/HoracioSchneider/PB_0124 

"parForShell.sh should have the following format:
wantRawData=Yes (or No)
refFirstNameCust=Firstname
refLastNameCust=Lastname
#external sample name
extSampleName=aotus_azarae	
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


PACBIODELIV_REMOTE_FROMABEL.SH WILL DO THE FOLLOWING: 

ABEL
parForShell.sh is read

NORSTORE
A directory at /projects/NS9012K/www/hts-nonsecure.uio.no/ called Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d) is created

ABEL
Symbolic links to folders is created in a folder .temp/$extSampleName usin ginformatin from SMRTcell.txt 
Files of interest from these folders is selected and compressed into tarball "$extSampleName.tgz" keeping the file structure of the original SMRTcell folder.
The tarball is copied to Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d) at Norstore

NORTSTORE
An md5sums.txts file is created in Project\_$refLastNameCust\_$sampleType\_$(date +%Y-%m-%d)
.htaccess is also created with "require user $refLastNameCust_lower-$sampleType"
Password for user is added to the password database at norstore




