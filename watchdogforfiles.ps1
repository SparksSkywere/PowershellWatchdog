#This script is to check the heartbeat of a Windows application and function as a watchdog for servers.

param (
	#The name of the process to monitor
	[Parameter(Mandatory=$true)][string]$processName,
	#The interval, in seconds, at which to check the status of the process
	[Parameter(Mandatory=$true)][Uint32]$interval,
	#The email address to send notifications to
	[Parameter(Mandatory=$true)][string]$notificationEmail,
	#Enable Auto restart when the application fails
	[Parameter(Mandatory=$false)][Switch]$Autorestart = $false
)
#Function to check the status of the process
function checkstatus {
#Get process that is running, just the process name, no extensions used
$process = Get-Process -Name $processName
	#Check status of the program, along with auto restart
	if ($Autorestart -eq $true){
		if ($null -eq $process ) {
			#If the process is not running, send an email notification and exit the script with auto restart enabled
			Write-Output "$processName is not running, sending notification and restarting application"
			send-email -subject "Watchdog Notification" -body "$processName has stopped working, Restarting application." -to $notificationEmail
			Start-Process $ProcessPath.FileName
		}
		else {
			Write-Output "Auto restart enabled"
			Write-Output "$processName is running"
		}
	}
	#Check status of the program - Listen only
	if ($Autorestart -eq $false) {
		if ($null -eq $process ) {
			#If the process is not running, send an email notification and exit the script with auto restart disabled
			Write-Output "$processName is not running, sending email"
			send-email -subject "Watchdog Notification" -body "$processName has stopped working. Please investigate." -to $notificationEmail
		exit
		}
		else {
			Write-Output "Auto restart not enabled"
			Write-Output "$processName is running"
		}
	}
}
#Function to send an email notification
function send-email {
	param (
		[Parameter(Mandatory=$true)]
		[string]$subject,
		[Parameter(Mandatory=$true)]
		[string]$body,
		[Parameter(Mandatory=$true)]
		[string]$to
	)
	
	#Set up the email message
	$mailMessage = New-Object System.Net.Mail.MailMessage
	$mailMessage.From = "watchdog@email.com"
	$mailMessage.To.Add($to)
	$mailMessage.Subject = $subject
	$mailMessage.Body = $body

	#Set up the SMTP client
	$smtpClient = New-Object System.Net.Mail.SmtpClient
	$smtpClient.Host = "smtp.email.com"
	$smtpClient.Credentials = New-Object System.Net.NetworkCredential("username", "password")

	#Send the email
	$smtpClient.Send($mailMessage)
}
#Get process path, this value is saved in memory and will only be used for restarting the application
$ProcessPath = Get-Process $processName -FileVersionInfo | Select-Object FileName

#Run the check-status function at the specified interval
while ($true) {
	Clear-Host
	checkstatus
	Start-Sleep -Seconds $interval
}
#Made by Chris Masters