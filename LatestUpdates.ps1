
#[ValidateSet('Application', 'CriticalUpdates', 'Definitions', 'FeaturePacks', 'SecurityUpdates', 'ServicePacks', 'Tools', 'UpdateRollups', 'Updates')]

#Using WUA to Scan for Updates Offline with PowerShell 
#VBS version: https://docs.microsoft.com/en-us/previous-versions/windows/desktop/aa387290(v=vs.85) 
 
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager
$UpdateService = $UpdateServiceManager.AddScanPackageService("Offline Sync Service", "C:\users\gibbo\documents\mdt\wsusscn2.cab", 1)
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

Write-Output "Searching for updates... `r`n" 

$UpdateSearcher.ServerSelection = 3 #ssOthers 
 
$UpdateSearcher.ServiceID = $UpdateService.ServiceID.ToString() 
 
$SearchResult = $UpdateSearcher.Search("IsInstalled=1 and CategoryIDs contains '28BC880E-0592-4CBF-8F95-C79B17911D5F'") # or "IsInstalled=0 or IsInstalled=1" to also list the installed updates as MBSA did 
 
$Updates = $SearchResult.Updates 
 
if($Updates.Count -eq 0){ 
    Write-Output "There are no applicable updates." 
    return $null 
} 
 
Write-Output "List of applicable items on the machine when using wssuscan.cab: `r`n" 
 
$i = 0 
foreach($Update in $Updates){  
    Write-Output "$($i)> $($Update.Title)" 
    $i++ 
}

exit
[hashtable]$UpdateTypes = @{

    'Critical Update'      = 'Critical non-security related'
    'Definition Update'    = 'Adds or modifies the definition database of Windows operating system; A definition database is a database that is built into the operating system to help it identify malicious code, phishing sites, and junk mail'
    'Update'               = 'Noncritical non-security related'
    'Driver Updates'       = 'Device drivers'
    'Security Updates'     = 'Critical security related'
    'Feature Pack Updates' = 'Are updates that makes changes to specific features of the operating system; such updates are released as and when available to a selected set of users; if that set of users provide good feedback about the changes in operating system features, Microsoft includes the changes into the next big release of Windows Operating Software; Currently, you get two feature updates every year if you are using Windows 10'
    'Monthly Rollup'       = 'Among the different types of Windows updates, you also get monthly rollup as an update on every second Tuesday normally; this update includes all the updates rolled out previous month plus additional definitions of malware'
    'Service Pack'         = 'It is a cumulative set of all hotfixes, security updates, critical updates, fixes, and updates. It is a set of Windows Updates that were released between two successive versions of Windows operating system. The age of Service Packs is over now.'
    'Tool updates'         = 'These are updates to the built-in utilities and tools.'
    'Update rollup'        = 'A cumulative set of hotfixes, security updates, critical updates, and updates that are packaged together for easy deployment'
    'Full updates'         = 'They have all the necessary components and files that have changed since the last feature update.'
    'Express updates'      = 'They generate differential downloads for every component in the full update based on several historical bases.'
    'Delta updates'        = 'They include only the components that changed in the most recent quality update, and will only install if a device already has the previous month’s update installed.'
'Security Quality Update'='It contains all the previous updates.'
'Security Monthly Quality Rollup'='It contains only the current month’s updates.'
    'Preview of Monthly Quality Rollup' = 'It is a preview of the Quality updates that will be released next month.'
    'Service Stack Updates' = 'They are kept separate from the regular cumulative updates because these Cumulative Updates add new and more optimized files to the operating system.'
}
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$foo = $Searcher.Search("IsInstalled=1").Updates
