#Function create Log folder
    Function CreateLogsFolder
{
    If(!(Test-Path C:\Logs))
    {
    New-Item -Force -Path "C:\Logs\" -ItemType Directory
		}
		else 
		{ 
    Write-Host "Le dossier "C:\Logs\" existe déjà !"
    }
}

#Create Log Folder
    CreateLogsFolder

#Declaration of script variables
$Client = "Client Name"
$ListDisk = Get-CimInstance -Class Win32_LogicalDisk | where {$_.DriveType -eq "3"}
$Server = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$SetMinSizeLimit = 600GB;
$LogPath = "C:\Logs\CheckHardDriveFreeSpace.log"
$Date = Get-Date

#Scan Free Hard Drive Space  
Foreach($Disk in $ListDisk)
    {
   $DiskFreeSpace = ($Disk.freespace/1GB).ToString('F2')
   Write-Output "$($Date)  L'espace disque restant sur $($Server), $($Disk.DeviceID) est de $DiskFreeSpace Go" | Tee-Object -FilePath $LogPath -Append
    }

#Send email if 
If ($disk.FreeSpace -lt $SetMinSizeLimit)
 {
    Write-Output "$($Date) Sending Alert email..." | Tee-Object -FilePath $LogPath -Append
    
    $smtpServer = "SMTP_Server"
    $msg = new-object Net.Mail.MailMessage
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)  
    $msg.From = "noreply@domainname.extension"
    $msg.To.Add("username@domainname.extension")
    #$msg.CC.Add("username@domainname.extension")
    $msg.Attachments.Add("$LogPath")
    $msg.subject = "$($Client)  :  Server disk space problem on $($Server)"
    $msg.body = "$($date) : The remaining disk space on disk $($Disk.DeviceID) of the server $($Server) is $($DiskFreeSpace) Go"
    $smtp.send($msg)
    
    Write-Host "$($Date) Sending Alert email OK" | Tee-Object -FilePath $LogPath -Append
}
If ($disk.FreeSpace -gt $SetMinSizeLimit)
    {
    Write-Host "Free disk Space OK"
    }
