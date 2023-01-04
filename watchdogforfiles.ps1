#This script is to check the heartbeat of a Windows application and function as a watchdog for servers.

param (
	#The name of the process to monitor
	[Parameter(Mandatory=$true)][string]$processName,
	#The interval, in seconds, at which to check the status of the process
	[Parameter(Mandatory=$true)][Uint32]$interval,
	#The email address to send notifications to
	[Parameter(Mandatory=$true)][string]$notificationEmail
)

#Function to check the status of the process
function checkstatus {
	# Check if the process is running
	$process = Get-Process -Name $processName
	if ($null -eq $process ) {
		# If the process is not running, send an email notification and exit the script
		Write-Output "$processName is not running, sending email"
		send-email -subject "Process Not Running" -body "$processName is not running on the server. Please investigate." -to $notificationEmail
		exit
	}
	else {
		Write-Output "$processName is running"
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

#Run the check-status function at the specified interval
while ($true) {
	Clear-Host
	checkstatus
	Start-Sleep -Seconds $interval
}
#Made by Chris Masters