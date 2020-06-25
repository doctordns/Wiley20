# 10.5 - Creating a performance monitoring graph
#
# Run on SRV1 after creating CSV performance data

# 1. Load the Forms assembly
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

# 2. Import the CSV data from earlier, and fix row 0
$CSVFile     = Get-ChildItem -Path C:\PerfLogs\Admin\*.csv -Recurse
$Counters    = Import-Csv $CSVFile
$Counters[0] = $Counters[1] # fix row 0 issues

# 3. Create a chart object
$TYPE     = 'System.Windows.Forms.DataVisualization.Charting.Chart'
$CPUChart = New-Object -Typename $TYPE

# 4. Defone the chart dimensions
$CPUChart.Width  = 1000
$CPUChart.Height = 600
$CPUChart.Titles.Add("SRV1 CPU Utilisation") | Out-Null

# 5. Create and define the chart area
$TYPE2 = 'System.Windows.Forms.DataVisualization.Charting.ChartArea'
$ChartArea = New-Object -TypeName $TYPE2
$ChartArea.Name        = "SRV1 CPU Usage"
$ChartArea.AxisY.Title = "% CPU Usage"
$CPUChart.ChartAreas.Add($ChartArea)

# 6. Identify the date/time column
$Name = ($Counters[0] | Get-Member | 
          Where-Object MemberType -EQ "NoteProperty")[0].Name

# 7. Add the data points to the chart.
$CPUChart.Series.Add("CPUPerc")  | Out-Null
$CPUChart.Series["CPUPerc"].ChartType = "Line"
$CPUCounter = '\\SRV1\Processor(_Total)\% Processor Time'
$Counters | 
  ForEach-Object {
   $CPUChart.Series["CPUPerc"].Points.AddXY($_.$name,$_.$CPUCounter) |
        Out-Null
  }

# 8. Ensure folder exists, then save the chart image as 
#    a png file in the folder:
$NIHT = @{
  Path        = 'C:\Perflogs\Reports'
  ItemType    = 'Directory'
  ErrorAction = 'SilentlyContinue' 
}
New-Item @NIHT
$CPUChart.SaveImage("C:\PerfLogs\Reports\SRV1CPU.Png", 'PNG')

# 9. View the chart image
& C:\PerfLogs\Reports\Srv1CPU.Png
