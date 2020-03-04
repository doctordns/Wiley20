Demo 10b - Create permanent event handler

# Group to monitor
$Group = 'Enterprise Admins'

# 1. Create the Event Filter query
$Group = 'Enterprise Admins'
$q = @"
  Select * From __InstanceModificationEvent Within 5  
   Where TargetInstance ISA 'ds_group' AND 
         TargetInstance.ds_name = '$Group'
"@
$q

# Create the filter
$Param = @{
            QueryLanguage =  'WQL'
            Query          =  $Q
            Name           =  "EventFilter1"
            EventNameSpace =  "root/directory/LDAP"
        }
$InstanceFilter = New-CimInstance -ClassName __EventFilter -Namespace root/subscription -Property $param -Verbose 

# 2. Creating the Event Consumer to run C:\foo\cim\monitor.ps1" 
$CLT = 'PowerShell.exe -File C:\Foo\Nonitor.ps1'
$Param =@{
            Name = "EventConsumer1";
            CommandLineTemplate=$CLT
        }
$InstanceConsumer = New-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -Property $param -Verbose

# 3. Bind the filter and consumer" 
$param = @{
           Filter = [ref]$InstanceFilter     
           Consumer=[ref]$InstanceConsumer
          }

$InstanceBinding= New-CimInstance -Namespace root/subscription -ClassName __FilterToConsumerBinding  -Property $param -Verbose 

#region helper functions

# helper functions
# Need to run the shell as elevated
Function sh {cls;
'Event Filters defined:'
  Get-CimInstance -Namespace root\subscription -ClassName __EventFilter  | FT name, query
'Consumer Defined:'
  Get-CimInstance -NameSpace root\subscription -classname CommandLineEventConsumer | FT Name, Commandlinetemplate
'Binding Defined:'
  Get-CimInstance -Namespace root\subscription -ClassName __FilterToConsumerBinding | FT Filter, Consumer
}
function de {
GCIM -name root\subscription __EventFilter | Remove-CimInstance
GCIM -name root\subscription CommandLineEventConsumer | Remove-CimInstance
GCIM -name root\subscription __FilterToConsumerBinding |Remove-CimInstance
}
#endregion