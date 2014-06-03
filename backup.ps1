function ExecuteOrQuit($cmd, $name) {
    Invoke-Expression $cmd
    if ($LASTEXITCODE -gt 0) {
        echo 'errorcode ' + $LASTEXITCODE + 'ejecutando ' + $name
        exit
    }
}
##
##  valores de configuracion
##
$currentDir=pwd
$mysqlPath='C:\Archivos de programa\MySQL\MySQL Server 5.1'
$targetDir='D:\Open\USS'
$user='openorange'
$password='Uss9954orange8'
$hostip='192.168.1.219'
$port='3306'
$dbname='openuss'
$compressor='C:\Program Files\WinRAR\rar.exe'
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
$dumpDbCmd=[string]::Format('{0} -u{1} -p{2} -h{3} --port {4} -Q --hex-blob --verbose --complete-insert --allow-keywords --create-options -r"{6}\{7}" {5} --ignore-table="{5}.Attach" --ignore-table="{5}.EventLog" ', 
                            $mysqldump, $user, $password, $hostip, $port, $dbname, $targetDir, $targetFile)
$dumpAttach=[string]::Format('{0} -u{1} -p{2} -h{3} --port {4} -Q --hex-blob --verbose --complete-insert --allow-keywords --create-options -r"{6}\{7}" {5} Attach', 
                            $mysqldump, $user, $password, $hostip, $port, $dbname, $targetDir, $attachFile)
$dumpEventLog=[string]::Format('{0} -u{1} -p{2} -h{3} --port {4} -Q --hex-blob --verbose --complete-insert --allow-keywords --create-options -r"{6}\{7}" {5} EventLog', 
                            $mysqldump, $user, $password, $hostip, $port, $dbname, $targetDir, $eventLogFile)

##
##  Ejecución
##
ExecuteOrQuit $dumpDbCmd, 'dump db'
ExecuteOrQuit $dumpAttach, 'dump attach'
ExecuteOrQuit $dumpEventLog, 'dump eventlog'

echo 'comprimiendo base...'

cd $targetDir

ExecuteOrQuit $([string]::Format('"{0}" a {1}.zip {1}', $compressor, $targetFile)), 'zip ' + $targetFile
ExecuteOrQuit $([string]::Format('"{0}" a {1}.zip {1}', $compressor, $attachFile)), 'zip ' + $attachFile
ExecuteOrQuit $([string]::Format('"{0}" a {1}.zip {1}', $compressor, $eventLogFile)), 'zip ' + $eventLogFile

cd $currentDir

echo 'borrando archivos creado hace más de ' + $numDays + ' días'
Get-ChildItem -Path $targetDir -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $pastLimit } | Remove-Item -Force