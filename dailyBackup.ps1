$logfilename = "backup.log"

backup1.ps1 -dbname tecnologia *>&1 | Out-File -Append $logfilename
backup1.ps1 -dbname marketing  *>&1 | Out-File -Append $logfilename
#backup1.ps1 -dbname ussgps     *>&1 | Out-File -Append $logfilename
#backup1.ps1 -dbname openuss    *>&1 | Out-File -Append $logfilename

# enviar logfilename por email
# remove-item $logfilename
