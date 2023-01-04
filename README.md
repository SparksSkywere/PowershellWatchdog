# Powershell Watchdog
A powershell script used on client / servers to help keep an eye on currently running processes, this program is meant to watch 1 application at a time, the program does not need to be launched via the watchdog and instead sits alongside it, you can put a bat script into SHELL:STARTUP to then call the .PS1 scripts one by one with timeouts or you can use a scheduler and such, since this is attached to processes it can be started seperately or as part of a bootup script. This is up to you on how you want to operate this script, an example BAT is at the bottom of this readme for running an app and then attaching the watchdog.

# Usage

When running the script you will need to input parameters into the command, if you do not the script will not work properly, when writing in the process you just put the name, no need for a .exe as we are not executing the program, this program will also auto exit upon the failing process, this is to help stop spamming the screen with powershells.

Example launch:
.\watchdogforfiles.ps1 -processName 'PROGRAMNAME' -interval '5' -notificationemail "EMAIL@MAIL.COM"

# SMTP Setup
In the script when you have downloaded it there is a few things you need to edit for this to work, edit the script and change the following lines:

	$mailMessage = New-Object System.Net.Mail.MailMessage
	$mailMessage.From = "watchdog@email.com"   -----------> Change this to your sending email or corperate sending email
	$mailMessage.To.Add($to)
	$mailMessage.Subject = $subject
	$mailMessage.Body = $body

	$smtpClient = New-Object System.Net.Mail.SmtpClient
	$smtpClient.Host = "smtp.email.com"   --------------> Change this to your personal SMTP server or corperate SMTP server
	$smtpClient.Credentials = New-Object System.Net.NetworkCredential("username", "password")  --------------------> Put in the credentials here

# Example BAT for launching powershell scripts:

	@echo off
	@echo Launching XXX Application
	start XXX.exe
	start powershell -File "Path\XXX.ps1" -processName 'PROGRAMNAME' -interval '5' -notificationemail "EMAIL@MAIL.COM"
	timeout 5
	@echo Launching XXX Appplication
	start XXX.exe
	start powershell -File "Path\XXX.ps1" -processName 'PROGRAMNAME' -interval '5' -notificationemail "EMAIL@MAIL.COM"
	exit
