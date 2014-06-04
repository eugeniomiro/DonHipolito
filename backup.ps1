Function LogWrite([string]$logstring)
{
    echo $logstring
    Add-content $logFileName -value $([string]::Format("{0}: {1}", $(Get-Date -format yyyy/MM/dd-HH:mm:ss), $logstring))
}

function ExecuteOrQuit([string]$cmd, [string[]]$par, [string]$name) {
    $status = $(Start-Process -filePath $cmd -argumentList $par -PassThru -Wait)
    if ($status.ExitCode -gt 0) {
        LogWrite -logstring $([string]::Format('errorcode {0} ejecutando ''{1}'' cmd (''{2}'' {3}) ', 
                                        $status.ExitCode, $name, $cmd, [String]::Join(' ', $par)))
        exit
    }
}

##
##  valores de configuracion
##
$dbname='marketing'
$mysqlPath='C:\Archivos de programa\MySQL\MySQL Server 5.1'
$targetDir='D:\OpenOrange\Marketing'
$user='openorange'
$password='Uss9954orange8'
$hostip='192.168.1.219'
$port='3306'
$compressor='C:\Program Files (x86)\7-Zip\7z.exe'
$numDays=2

##
##  nombres de archivo
##
$logFileName=[string]::Format('{0}-{1}.log', $dbname, $(Get-Date -format yyyyMMdd-HHmm))
$targetZip =[string]::Format('{0}-{1}.zip', $dbname, $(Get-Date -format yyyyMMdd-HHmm))
$targetFile=[string]::Format('{0}-DB-{1}.sql', $dbname, $(Get-Date -format yyyyMMdd-HHmm))
$attachFile=[string]::Format('{0}-Attach-{1}.sql', $dbname, $(Get-Date -format yyyyMMdd-HHmm))
$eventLogFile=[string]::Format('{0}-EventLog-{1}.sql', $dbname, $(Get-Date -format yyyyMMdd-HHmm))

##
##  comandos
##

$currentDir=pwd
$pastLimit=$(Get-Date).AddDays(-$numDays)

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
LogWrite -logstring 'iniciando backup'
ExecuteOrQuit -cmd $mysqldump -par $dumpDbCmd -name 'dump db'

LogWrite -logstring 'dump db OK'
ExecuteOrQuit -cmd $mysqldump -par $dumpAttach -name 'dump attach'

LogWrite -logstring 'dump attach OK'
ExecuteOrQuit -cmd $mysqldump -par $dumpEventLog -name 'dump eventlog'

LogWrite -logstring 'dump eventLog OK'

LogWrite -logstring 'comprimiendo base...'

cd $targetDir

ExecuteOrQuit -cmd $compressor -par $([string]::Format('a -tzip {0} {1}', $targetZip, $targetFile)) -name $targetFile 

LogWrite -logString 'comprimiendo attach...'
ExecuteOrQuit -cmd $compressor -par $([string]::Format('a -tzip {0} {1}', $targetZip, $attachFile)) -name $attachFile 

LogWrite -logString 'comprimiendo eventLog...'
ExecuteOrQuit -cmd $compressor -par $([string]::Format('a -tzip {0} {1}', $targetZip, $eventLogFile)) -name $eventLogFile 

LogWrite -logstring 'compresion completa...'

cd $currentDir

LogWrite -logstring $([string]::Format('borrando archivos en "{1}" creados hace mas de {0} dias', $numDays, $targetDir))
Get-ChildItem -Path $targetDir -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $pastLimit } | Remove-Item -Force -Verbose

LogWrite -logstring 'borrando archivos *.sql'
Remove-Item -Path *.sql -Verbose

LogWrite -logstring 'Backup ejecutado correctamente...'