# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Show a dialog box to select the file to monitor
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Executable Files (*.exe, *.bat, *.ps1)|*.exe;*.bat;*.ps1"

if ($openFileDialog.ShowDialog() -eq 'OK') {
    $selectedFile = $openFileDialog.FileName
    $processName = [System.IO.Path]::GetFileNameWithoutExtension($selectedFile)

    param (
        # The interval, in seconds, at which to check the status of the process
        [Parameter(Mandatory=$true)][Uint32]$interval,
        # The email address to send notifications to
        [Parameter(Mandatory=$true)][string]$notificationEmail,
        # Enable Auto restart when the application fails
        [Parameter(Mandatory=$false)][Switch]$Autorestart = $false
    )

    # Function to check if a process is already running
    function IsProcessRunning {
        param (
            [Parameter(Mandatory=$true)][string]$processName
        )

        $runningProcess = Get-Process -Name $processName -ErrorAction SilentlyContinue
        return ($null -ne $runningProcess)
    }

    # Function to start the process if it's not running and check if it starts within a minute
    function StartAndCheckProcess {
        if (-not (IsProcessRunning -processName $processName)) {
            # If the process is not running, attempt to start it
            Start-Process $selectedFile
            # Sleep for 1 minute to allow the process to start
            Start-Sleep -Seconds 60
            # Check if the process is running after 1 minute
            if (-not (IsProcessRunning -processName $processName)) {
                # If it's still not running, send an email notification and exit
                Write-Output "$processName did not start after 1 minute, sending email"
                send-email -subject "Watchdog Notification" -body "$processName did not start after 1 minute. Please investigate." -to $notificationEmail
                exit
            }
        }
    }

    # Check if the process is already running
    if (IsProcessRunning -processName $processName) {
        $startSecondInstance = [System.Windows.Forms.MessageBox]::Show("The process is already running. Do you want to start a second instance?", "Process Running", [System.Windows.Forms.MessageBoxButtons]::YesNo)

        if ($startSecondInstance -eq [System.Windows.Forms.DialogResult]::No) {
            exit
        }
    }

    # Function to check the status of the process
    function checkstatus {
        # Check status of the program, along with auto restart
        if ($Autorestart -eq $true) {
            if (IsProcessRunning -processName $processName) {
                Write-Output "Auto restart enabled"
                Write-Output "$processName is running"
            } else {
                # If the process is not running, start and check it
                StartAndCheckProcess
                Write-Output "Auto restart enabled"
                Write-Output "$processName is running"
            }
        } else {
            if (IsProcessRunning -processName $processName) {
                Write-Output "Auto restart not enabled"
                Write-Output "$processName is running"
            } else {
                # If the process is not running, send an email notification and exit
                Write-Output "$processName is not running, sending email"
                send-email -subject "Watchdog Notification" -body "$processName has stopped working. Please investigate." -to $notificationEmail
                exit
            }
        }
    }

    # Function to send an email notification
    function send-email {
        param (
            [Parameter(Mandatory=$true)]
            [string]$subject,
            [Parameter(Mandatory=$true)]
            [string]$body,
            [Parameter(Mandatory=$true)]
            [string]$to
        )

        # Set up the email message
        $mailMessage = New-Object System.Net.Mail.MailMessage
        $mailMessage.From = "watchdog@email.com"
        $mailMessage.To.Add($to)
        $mailMessage.Subject = $subject
        $mailMessage.Body = $body

        # Set up the SMTP client
        $smtpClient = New-Object System.Net.Mail.SmtpClient
        $smtpClient.Host = "smtp.email.com"
        # Enable below if you need SSL or TLS
        # $smtpClient.Port = 465(SSL)/587(TLS)
        # $smtpClient.EnableSsl = $true
        $smtpClient.Credentials = New-Object System.Net.NetworkCredential("username", "password")

        # Send the email
        $smtpClient.Send($mailMessage)
    }

    # Run the check-status function at the specified interval until the user manually stops the script
    while ($true) {
        Clear-Host
        checkstatus
        Start-Sleep -Seconds $interval
    }

    # Exception handling for crashes
    while ($true) {
        Write-Output "Server starting at: $(Get-Date)"
        try {
            StartAndCheckProcess
            Write-Output "Server crashed or shutdown at: $(Get-Date)"
            # Handle crash (e.g., send email notification or take other actions)
            send-email -subject "Watchdog Notification" -body "$processName has crashed or exited unexpectedly." -to $notificationEmail
        } catch {
            Write-Output "Server encountered an error: $_"
            # Handle the error (e.g., send email notification or take other actions)
            send-email -subject "Watchdog Notification" -body "$processName encountered an error: $_" -to $notificationEmail
        }
    }

    # Created by Chris Masters
}
