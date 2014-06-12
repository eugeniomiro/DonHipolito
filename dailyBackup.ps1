#function sendMail
#{
#     Write-Host "Sending Email"
#
#     #SMTP server name
#     $smtpServer = "smtp.xxxx.com"
#
#     #Creating a Mail object
#     $msg = new-object Net.Mail.MailMessage
#
#     #Creating SMTP server object
#     $smtp = new-object Net.Mail.SmtpClient($smtpServer)
#
#     #Email structure 
#     $msg.From = "fromID@xxxx.com"
#     $msg.ReplyTo = "replyto@xxxx.com"
#     $msg.To.Add("toID@xxxx.com")
#     $msg.subject = "My Subject"
#     $msg.body = "This is the email Body."
#
#     #Sending email 
#     $smtp.Send($msg)
#  
#}

$logfilename = "Backup_OpenOrange_Full.log"

.\Backup_OpenOrange.ps1 -dbname tecnologia -targetDir D:\OpenOrange\Tecnologia *>&1 | Out-File -Append $logfilename
.\Backup_OpenOrange.ps1 -dbname marketing  -targetDir D:\OpenOrange\Marketing *>&1 | Out-File -Append $logfilename
#.\Backup_OpenOrange.ps1 -dbname ussgps     -targetDir D:\OpenOrange\GPS *>&1 | Out-File -Append $logfilename
#.\Backup_OpenOrange.ps1 -dbname openuss    -targetDir D:\OpenOrange\USS *>&1 | Out-File -Append $logfilename

# enviar logfilename por email
# remove-item $logfilename
#
