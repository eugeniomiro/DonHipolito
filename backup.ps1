function ExecuteOrQuit([string]$cmd, [string[]]$par, [string]$name) {
    Start-Process -filePath $cmd -argumentList $par
    if ($LASTEXITCODE -gt 0) {
        echo [string]::Format('errorcode {0} ejecutando {1}', $LASTEXITCODE, $name)
        exit
    }
}
##
##  valores de configuracion
##
$currentDir=pwd
$mysqlPath='C:\Archivos de programa\MySQL\MySQL Server 5.1'
$targetDir='D:\OpenOrange\Marketing'
$user='openorange'
$password='Uss9954orange8'
$hostip='192.168.1.219'
$port='3306'
$dbname='marketing'
$compressor='C:\Program File\7-Zip\7z.exe'
$numDays=2
$pastLimit=$(Get-Date).AddDays(-$numDays)

##
##  nombres de archivo
##
$targetFile=[string]::Format('{0}-{1}.sql', $dbname, $(Get-Date -format yyyyMMdd-HHmm))
$attachFile=[string]::Format('{0}-Attach-{1}.sql', $dbname, $(Get-Date -format yyyyMMdd-HHmm))
$eventLogFile=[string]::('{0}-EventLog-{1}.sql', $dbname, $(Get-Date -format yyyyMMdd-HHmm))

##
##  comandos
##

$mysqldump=[string]::Format('"{0}\bin\mysqldump.exe"', $mysqlPath)
$dumpDbCmd=[string]::Format('-u{0} -p{1} -h{2} --port {3} -Q --hex-blob --verbose --complete-insert --allow-keywords --create-options -r"{5}\{6}" {4} --ignore-table="{4}.Attach" --ignore-table="{4}.EventLog" ', 
                            $user, $password, $hostip, $port, $dbname, $targetDir, $targetFile)
$dumpAttach=[string]::Format('-u{0} -p{1} -h{2} --port {3} -Q --hex-blob --verbose --complete-insert --allow-keywords --create-options -r"{5}\{6}" {4} Attach', 
                            $user, $password, $hostip, $port, $dbname, $targetDir, $attachFile)
$dumpEventLog=[string]::Format('-u{0} -p{1} -h{2} --port {3} -Q --hex-blob --verbose --complete-insert --allow-keywords --create-options -r"{5}\{6}" {4} EventLog', 
                            $user, $password, $hostip, $port, $dbname, $targetDir, $eventLogFile)

##
##  Ejecución
##
ExecuteOrQuit -cmd $mysqldump -par $dumpDbCmd -name 'dump db'
ExecuteOrQuit -cmd $mysqldump -par $dumpAttach -name 'dump attach'
ExecuteOrQuit -cmd $mysqldump -par $dumpEventLog -name 'dump eventlog'

echo 'comprimiendo base...'

cd $targetDir

ExecuteOrQuit -cmd $compressor -par $([string]::Format('a -tzip {0}.zip {0}', $targetFile)) -name $targetFile 
ExecuteOrQuit -cmd $compressor -par $([string]::Format('a -tzip {0}.zip {0}', $attachFile)) -name $attachFile 
ExecuteOrQuit -cmd $compressor -par $([string]::Format('a -tzip {0}.zip {0}', $eventLogFile)) -name $eventLogFile 

cd $currentDir

echo $([string]::Format('borrando archivos en "{1}" creados hace mas de {0} dias', $numDays, $targetDir))
Get-ChildItem -Path $targetDir -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $pastLimit } | Remove-Item -Force