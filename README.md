# Powershell Watchdog
A powershell script used on client / servers to help keep an eye on currently running processes, this program is meant to run 1 application at a time, the program is launched via this watchdog, you can put a bat script into SHELL:STARTUP to then call the .PS1 scripts one by one with timeouts or you can use a scheduler and such, up to you how to do this, an example BAT is at the bottom of this readme.

# SMTP Setup
In the script when you have downloaded it there is a few things you need to edit for this to work, edit the script and change the following lines:

	$mailMessage = New-Object System.Net.Mail.MailMessage
	$mailMessage.From = "watchdog@email.com"   -----------> Change this to your personal email or corperate email
	$mailMessage.To.Add($to)
	$mailMessage.Subject = $subject
	$mailMessage.Body = $body

	$smtpClient = New-Object System.Net.Mail.SmtpClient
	$smtpClient.Host = "smtp.email.com"   --------------> Change this to your personal SMTP server or corperate SMTP server
	$smtpClient.Credentials = New-Object System.Net.NetworkCredential("username", "password")

# Example BAT for launching powershell scripts:

	$@echo off
	$@echo Launching XXX Application
	$ start powershell -File "Path\XXX.ps1"
	$timeout 5
	$@echo Launching XXX Appplication
	$start powershell -File "Path\XXX.ps1"
	$exit
