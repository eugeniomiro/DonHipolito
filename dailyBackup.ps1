param (
    [string]$smtpServer = "192.168.1.203",
    [string]$logfilename = "Backup_OpenOrange_Full.log",
    [string]$from = "USSSRV13@uss.com.ar",
    [string]$toList = "soporte@uss.com.ar,alertas-it@uss.com.ar"
)

function sendMail($subject, $body, $from, $toList, $replyTo)
{
    Write-Host "Sending Email"
    Write-Debug "Subject = $subject" 
    Write-Debug "body = $body" 
    Write-Debug "from address = $from" 
    Write-Debug "to addresses = $toList" 
    try {
        #Creating a Mail object
        $msg = new-object Net.Mail.MailMessage
    
        #Creating SMTP server object
        $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    
        #Email structure 
        $msg.From = $from
        $msg.subject = $subject
        $msg.body = $body
        if (![String]::IsNullOrEmpty($replyTo)) {
            $msg.ReplyTo = $replyTo
        }
        $toList.Split(",") | foreach {
            $msg.To.Add($_.Trim())
        }
    
        #Sending email 
        $smtp.Send($msg)
    } catch [System.Exception] {
        Write-Error "Error mientras se enviaba el email: $error"
        exit
    }
}

.\Backup_OpenOrange.ps1 -dbname tecnologia -targetDir D:\OpenOrange\Tecnologia *>&1 | Out-File $logfilename
.\Backup_OpenOrange.ps1 -dbname marketing  -targetDir D:\OpenOrange\Marketing *>&1 | Out-File -Append $logfilename
#.\Backup_OpenOrange.ps1 -dbname ussgps     -targetDir D:\OpenOrange\GPS *>&1 | Out-File -Append $logfilename
#.\Backup_OpenOrange.ps1 -dbname openuss    -targetDir D:\OpenOrange\USS *>&1 | Out-File -Append $logfilename

# enviar logfilename por email
sendMail -subject "Reporte de Backup OpenOrange" -body $($(Get-Content $logfilename) -join '`n') -from $from -to $toList 

#remove-item $logfilename
