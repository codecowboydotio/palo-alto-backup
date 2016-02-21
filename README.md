# palo-alto-backup
Powershell backup script for palo alto

Script will create a configuration file if one does not exist in the specified directory.

Fill out the config file with an API key and other details.

Start backing up your palo alto firewalls.

# Configuration
To Configure the script, set the config file path. By default this is the current directory.
Run the script once.
You will get a message about a configuration file not being found, and the script will create one for you.

# Configuration File Structure
The configuration file is an XML file.
The configuration directives are wrapped inside a <config> tag; each one is described below.
<paloip> - This tag is used to hold the IP address of the palo alto device to be backed up.
<apikey> - This tag is used to hold the API key that has been configured on the palo alto device.
<logfile> - This tag is used to hold the name of the log file (including path) for example: c:\logfile.log
<logfilesize>ADD - This tag is used to hold the maximum size of the logfile. The logfile will be checked and rolled when it reaches this size. Note that the check only occurs once each time the script is run.
<outputfile> - This is the name of the outputfile (i.e. the backup). It should contain the path, like the logfile. For example: c:\backup.xml
