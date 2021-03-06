﻿param (
    [string]$smtpServer = "192.168.1.203",
    [string]$logfilename = "Backup_OpenOrange_Full_$(Get-Date -format yyyyMMdd-HHmm).log",
    [string]$from = "USSSRV13@uss.com.ar",
    [string]$toList = "soporte@uss.com.ar,alertas-it@uss.com.ar",
    [Int32]$numDays = 8
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
        Add-Content  $logfilename -Value "Error mientras se enviaba el email: $error"
        exit
    }
}

function exec([string]$backupName, [string]$backupDir) 
{
    Add-Content $logfilename -Value "Backup $backupName ejecutado..." -Encoding UTF8
    .\Backup_OpenOrange.ps1 -dbname $backupName -targetDir $backupDir 
    If ($LASTEXITCODE -ne 0) {
        Add-Content  $logfilename -Value "con error $LASTEXITCODE"
    } else {
        Add-Content $logfilename -Value "OK"
    }
}

$pastLimit=$(Get-Date).AddDays(-$numDays)

Set-Content $logfilename -Value "Iniciando respaldo de base de datos..."
exec -backupName "tecnologia" -backupDir "D:\OpenOrange\Tecnologia"
exec -backupName "marketing" -backupDir "D:\OpenOrange\Marketing"
#exec -backupName "ussgps" -backupDir "D:\OpenOrange\GPS"
#exec -backupName "openuss" -backupDir "D:\OpenOrange\USS"

Get-ChildItem -Path *.log -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $pastLimit } | Remove-Item -Force -Verbose *>&1| Out-File -Append $logFileName -Encoding utf8

# enviar logfilename por emai
sendMail -subject "Reporte de Backup OpenOrange" -body $($(Get-Content $logfilename) -join "`n") -from $from -to $toList 
