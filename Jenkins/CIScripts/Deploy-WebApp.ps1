Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure'
Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ResourceManager\AzureResourceManager'

$ServicePrincipalPassword = ConvertTo-SecureString "test.123" -AsPlainText -Force
$ServicePrincipalCredentials = New-Object System.Management.Automation.PSCredential ("2759983a-7c50-484a-b93c-e116e71ed16e", $ServicePrincipalPassword)
Add-AzureAccount -Credential $ServicePrincipalCredentials -ServicePrincipal -Tenant 72f988bf-86f1-41af-91ab-2d7cd011db47
Select-AzureSubscription -SubscriptionId 9de7ded6-0ad3-43e6-87b8-17d93e3ff695

Switch-AzureMode AzureResourceManager

New-AzureResourceGroup -Name cawarg105 -Location westus -TemplateFile C:\Users\vmuser\.jenkins\jobs\ci\workspace\Templates\WindowsVirtualMachine.json -TemplateParameterFile C:\Users\vmuser\.jenkins\jobs\ci\workspace\Templates\WindowsVirtualMachine.param.dev.json 

$PublicIP = Get-AzurePublicIpAddress -Name cawadscvm5-PublicIP-VM -ResourceGroupName cawarg105

$ipAddr = $PublicIP.IpAddress

Switch-AzureMode AzureServiceManagement

$Argument= '-source:package="C:\Users\vmuser\.jenkins\jobs\ci\workspace\WebApplication3\obj\Debug\Package\WebApplication3.zip"' + " -dest:auto,ComputerName=$ipAddr,"+'username=vmuser' +',password=test.123' + ' -verb:sync -allowUntrusted'
$MSDeployPath = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select -Last 1).GetValue("InstallPath")
Start-Process "$MSDeployPath\msdeploy.exe" $Argument -Wait -PassThru