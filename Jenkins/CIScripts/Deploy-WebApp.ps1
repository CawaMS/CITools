Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure'
Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ResourceManager\AzureResourceManager'

$ServicePrincipalPassword = ConvertTo-SecureString "<Password>" -AsPlainText -Force
$ServicePrincipalCredentials = New-Object System.Management.Automation.PSCredential ("<ServicePrincipalID>", $ServicePrincipalPassword)
Add-AzureAccount -Credential $ServicePrincipalCredentials -ServicePrincipal -Tenant <ServicePrincipalTenantID>
Select-AzureSubscription -SubscriptionId <ServicePrincipalSubscriptionID>

Switch-AzureMode AzureResourceManager

New-AzureResourceGroup -Name cawarg105 -Location westus -TemplateFile C:\Users\vmuser\.jenkins\jobs\ci\workspace\Templates\WindowsVirtualMachine.json -TemplateParameterFile C:\Users\vmuser\.jenkins\jobs\ci\workspace\Templates\WindowsVirtualMachine.param.dev.json 

$PublicIP = Get-AzurePublicIpAddress -Name cawadscvm5-PublicIP-VM -ResourceGroupName cawarg105

$ipAddr = $PublicIP.IpAddress

Switch-AzureMode AzureServiceManagement

$Argument= '-source:package="C:\Users\vmuser\.jenkins\jobs\ci\workspace\WebApplication3\obj\Debug\Package\WebApplication3.zip"' + " -dest:auto,ComputerName=$ipAddr,"+'username=vmuser' +',password=test.123' + ' -verb:sync -allowUntrusted'
$MSDeployPath = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select -Last 1).GetValue("InstallPath")
Start-Process "$MSDeployPath\msdeploy.exe" $Argument -Wait -PassThru
