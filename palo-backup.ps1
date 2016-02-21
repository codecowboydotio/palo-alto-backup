cls

$script=$MyInvocation.Mycommand.Name
$configfile=".\palo.xml"
$version="1.2"


if(!(Test-Path -Path $configfile))
{
	Write-Host "Configuration File $configfile does not exist."
	Write-Host "Creating blank config file."
	Add-Content $configfile "<config>"
	Add-Content $configfile "`t<paloip>PLACE YOUR PALO ALTO MANAGEMENT IP ADDRESS HERE</paloip>"
	Add-Content $configfile "`t<apikey>PLACE YOUR API KEY HERE</apikey>"
	Add-Content $configfile "`t<logfile>ADD YOUR LOG FILE NAME AND LOCATION HERE (eg: c:\log.txt)</logfile>"
	Add-Content $configfile "`t<logfilesize>ADD YOUR LOGFILE SIZE IN BYTES HERE</logfilesize>"
	Add-Content $configfile "`t<outputfile>ADD YOUR OUTPUT FILE LOCATION and NAME HERE (eg: c:\palo-output.txt)</outputfile>"
	Add-Content $configfile "</config>"
	exit 
}


[xml]$config = Get-Content $configfile
$palo_ip=$config.config.paloip
$api_key=$config.config.apikey
$logfile=$config.config.logfile
$newlogfile = $logfile + ".old"
$logfilesize=$config.config.logfilesize
$outfile=$config.config.outputfile

# Logging function use to log messages to a file
function logger ($filename, $message)
{
$logdate = Get-Date -Format "yyyy-MM-dd"
$logtime = Get-Date -Format "HH:mm:ss"
$logdatetime = $logdate + " " + $logtime

$logmessage = "[" + $logdatetime + "] " + $message 

Write-Host $logmessage
echo $logmessage >> $filename
} 

Write-Host "Version: " $version
Write-Host "Palo IP: " $palo_ip
Write-Host "Logfile: " $logfile
Write-Host "Log File Max Size: " $logfilesize
Write-Host "Log File to Roll to: " $newlogfile
Write-Host "-------------------------------------------------------------------------------"

if (!$logfile)
{
	Write-Host "Parameter logfile is missing from $configfile."
	Write-Host "Clearly, this error cannot be logged to a non-existent log file."
	Write-Host "Exiting..."
	exit
}
if (!$logfilesize) 
{
	Write-Host "Parameter logfilesize is missing from $configfile"
	Write-Host "This parameter defines the maximum size in bytes of the log file."
	Write-Host "Should the log file reach this size, it will be rolled to another file"
	Write-Host "ending with a .old extnesion. A new log file will be created for storing current events."
	Write-Host "Exiting..."
	logger $logfile "Parameter logfilesize missing from $configfile."
	exit
}

if (!$palo_ip)
{
	Write-Host "Parameter paloip is missing from $configfile"
	Write-Host "This parameter defines the palo alto firewall you are attempting to perform a backup of."
	Write-Host "Please check your config file."
	logger $logfile "Parameter paloip missing from $configfile."
	exit
}

if (!$api_key)
{
	Write-Host "Parameter apikey is missing from $configfile."
	Write-Host "This parameter defines the api key used to authenticate against the palo alto."
	Write-Host "Please check your config file."
	logger $logfile "Parameter apikey missing from $configfile."
	exit
}




$ErrorActionPreference = "SilentlyContinue"
$ipAddress = $palo_ip
$ipObj = [System.Net.IPAddress]::parse($ipAddress)
$isValidIP = [System.Net.IPAddress]::tryparse([string]$ipAddress, [ref]$ipObj)
if ($isValidIP) {
   logger $logfile “$ipAddress is a valid IP address”
} else {
   Write-host “$ipAddress is not a valid IP address”
   logger $logfile "$ipAddress is not a valid address - please edit the configuration file."
   exit
}
$ErrorActionPreference = "Continue"


if (Test-Path $logfile)
{
	if ((Get-Item $logfile).length -gt $logfilesize) 
	{ 
		Write-Host "Rotating logfile $logfile to $newlogfile."
		move-item $logfile $newlogfile -force
		logger $logfile "Log file rolled to $newlogfile."
	}
}


# If all of the checks pass then fall through to here

$url="https://$palo_ip/api?type=config&action=show&key=$api_key"

# Ensure that self signed certificates are okay.
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$wc = new-object net.WebClient
$probe = $wc.downloadData($url)
$s = [text.encoding]::ascii.getString($probe)

echo $s >> $outfile
#$netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])

