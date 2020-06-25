# 10.3 - Create and run a data collector set
#
#  Run on SRV1

# 1. Create and populate a new collector
$Name = 'SRV1 Collector Set'
$SRV1CS1 = New-Object -COM Pla.DataCollectorSet
$SRV1CS1.DisplayName                = $Name
$SRV1CS1.Duration                   = 12*3600  
$SRV1CS1.SubdirectoryFormat         = 1 
$SRV1CS1.SubdirectoryFormatPattern  = 'yyyy\-MM'
$JPHT = @{
  Path      = "$Env:SystemDrive"
  ChildPath = "\PerfLogs\Admin\$Name"
}
$SRV1CS1.RootPath = Join-Path @JPHT
$SRV1Collector1 = $SRV1CS1.DataCollectors.CreateDataCollector(0)
$SRV1Collector1.FileName              = "$Name_"
$SRV1Collector1.FileNameFormat        = 1 
$SRV1Collector1.FileNameFormatPattern = "\-MM\-dd"
$SRV1Collector1.SampleInterval        = 15
$SRV1Collector1.LogFileFormat         = 3 # BLG separated
$SRV1Collector1.LogAppend             = $True

# 2. Define counters of interest
$Counters1 = @(
    '\Memory\Pages/sec',
    '\Memory\Available MBytes', 
    '\Processor(_Total)\% Processor Time', 
    '\PhysicalDisk(_Total)\% Disk Time',
    '\PhysicalDisk(_Total)\Disk Transfers/sec' ,
    '\PhysicalDisk(_Total)\Avg. Disk Queue Length'
)

# 3. Add the counters to the collector
$SRV1Collector1.PerformanceCounters = $Counters1

# 4. Create a schedule - start tomorrow morning at 06:00
$StartDate = Get-Date -Day $((Get-Date).Day+1) -Hour 6 -Minute 0 -Second 0
$Schedule = $SRV1CS1.Schedules.CreateSchedule()
$Schedule.Days = 7
$Schedule.StartDate = $StartDate
$Schedule.StartTime = $StartDate

# 5. Create, add and start the collector set
try
{
    $SRV1CS1.Schedules.Add($Schedule)
    $SRV1CS1.DataCollectors.Add($SRV1Collector1) 
    $SRV1CS1.Commit("$Name" , $null , 0x0003) | Out-Null
    $SRV1CS1.Start($false);
}
catch 
{
    Write-Host "Exception Caught: " $_.Exception -ForegroundColor Red
    return
}

# 6. Create a second collector that collects to a CSV file
$Name = 'SRV1 Collector Set2 (CSV)'
$SRV1CS2 = New-Object -COM Pla.DataCollectorSet
$SRV1CS2.DisplayName                = $Name
$SRV1CS2.Duration                   = 12*3600  
$SRV1CS2.SubdirectoryFormat         = 1 
$SRV1CS2.SubdirectoryFormatPattern  = 'yyyy\-MM'
$JPHT = @{
  Path      = "$Env:SystemDrive"
  ChildPath = "\PerfLogs\Admin\$Name"
}
$SRV1CS2.RootPath = Join-Path @JPHT
$SRV1Collector2 = $SRV1CS2.DataCollectors.CreateDataCollector(0)
$SRV1Collector2.FileName              = "$Name_"
$SRV1Collector2.FileNameFormat        = 1 
$SRV1Collector2.FileNameFormatPattern = "\-MM\-dd"
$SRV1Collector2.SampleInterval        = 15
$SRV1Collector2.LogFileFormat         = 0 # CSV format
$SRV1Collector2.LogAppend             = $True
# Define counters of interest
$Counters2 = @(
    '\Memory\Pages/sec',
    '\Memory\Available MBytes', 
    '\Processor(_Total)\% Processor Time', 
    '\PhysicalDisk(_Total)\% Disk Time',
    '\PhysicalDisk(_Total)\Disk Transfers/sec' ,
    '\PhysicalDisk(_Total)\Avg. Disk Queue Length'
)
#  Add the counters to the collector
$SRV1Collector2.PerformanceCounters = $Counters2
# Create a schedule - start tomorrow morning at 06:00
$StartDate = Get-Date -Day $((Get-Date).Day+1) -Hour 6 -Minute 0 -Second 0
$Schedule2 = $SRV1CS2.Schedules.CreateSchedule()
$Schedule2.Days = 7
$Schedule2.StartDate = $StartDate
$Schedule2.StartTime = $StartDate
# Create, add and start the collector set
try
{
    $SRV1CS2.Schedules.Add($Schedule2)
    $SRV1CS2.DataCollectors.Add($SRV1Collector2) 
    $SRV1CS2.Commit("$Name" , $null , 0x0003) | Out-Null
    $SRV1CS2.Start($false);
}
catch 
{
    Write-Host "Exception Caught: " $_.Exception -ForegroundColor Red
    return
}


# 7. Using Perfmon to view data collector sets

see perfmon access



###  at this point the collector set is live inside Windows

# To Clean up
# Remove the countesrs
$DCStRemote = New-Object -COM Pla.DataCollectorSet
$Name = 'SRV1 Collector Set'
$DCstRemote.Query($Name,'LocalHost')
$DCstRemote.Stop($true)
$DCstRemote.Delete()
$DCStRemote2 = New-Object -COM Pla.DataCollectorSet
$Name2 = 'SRV1 Collector Set2 (CSV)'
$DCstRemote2.Query($Name2,'LocalHost')
$DCstRemote2.Stop($true)
$DCstRemote2.Delete()
# Restart the counter
$DCStRemote2 = New-Object -COM Pla.DataCollectorSet
$DCstRemote2.Query($Name2,'LocalHost')
$DCstRemote2.Start($true)

