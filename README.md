# Powershell Watchdog
A powershell script used on client / servers to help keep an eye on currently running processes, this program is meant to watch 1 application at a time, the program does not need to be launched via the watchdog and instead sits alongside it, you can put a bat script into SHELL:STARTUP to then call the .PS1 scripts one by one with timeouts or you can use a scheduler and such, since this is attached to processes it can be started seperately or as part of a bootup script. This is up to you on how you want to operate this script, an example BAT is at the bottom of this readme for running an app and then attaching the watchdog.

# Usage
When running the script you will need to input parameters into the command, if you do not the script will not work properly, when writing in the process you just put the name, no need for ".exe" as we are not executing the program, this program will also auto exit upon the failing process, this is to help stop spamming the screen with powershells left open when a program has crashed.

# Example Powershell Command:
	.\watchdogforfiles.ps1 -processName 'PROGRAMNAME' -interval '5' -notificationemail "EMAIL@MAIL.COM"

# Auto Restart:
As most watchdogs are just meant to listen the options to restart by default is disabled, you can enable them via having "-AutoRestart" in the command line

	.\watchdogforfiles.ps1 -processName 'PROGRAMNAME' -interval '5' -notificationemail "EMAIL@MAIL.COM" -AutoRestart

# EMAIL Setup
In the script when you have downloaded it there is a few things you need to edit for this to work, edit the script and change the following lines:

	$mailMessage = New-Object System.Net.Mail.MailMessage
	$mailMessage.From = "watchdog@email.com"   -----------> Change this to your sending email or corperate sending email (service accounts)
	$mailMessage.To.Add($to)
	$mailMessage.Subject = $subject
	$mailMessage.Body = $body

	$smtpClient = New-Object System.Net.Mail.SmtpClient
	$smtpClient.Host = "smtp.email.com"   --------------> Change this to your SMTP server or corperate SMTP server
	$smtpClient.Credentials = New-Object System.Net.NetworkCredential("username", "password")  --------------------> Put in the credentials here

# Example BAT:
This is for launching powershell scripts (the start powershell line can be inputted directly into CMD)

	@echo off
	@echo Launching XXX Application + Watchdog
	Start XXX.exe
	Start powershell "Path\XXX.ps1" -processName 'PROGRAMNAME' -interval '5' -notificationemail "EMAIL@MAIL.COM"
	exit
