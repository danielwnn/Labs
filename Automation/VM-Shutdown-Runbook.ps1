<#
.SYNOPSIS
  Connects to Azure and stops of all VMs in the specified Azure subscription or resource group

.PARAMETER ResourceGroupName
   Optional
   Allows you to specify the resource group containing the VMs to stop.  
   If this parameter is included, only VMs in the specified resource group will be stopped, otherwise all VMs in the subscription will be stopped.  

.NOTES
   AUTHOR: Daniel Wang 
   LASTEDIT: January 24, 2020
#>

param (
    [Parameter(Mandatory=$false)] 
    [String] $ResourceGroupName = "DevOps-Lab-RG"
)

# Returns strings with status messages
[OutputType([String])]

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    $loginStatus = Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

# If there is a specific resource group, then get all VMs in the resource group,
# otherwise get all VMs in the subscription.
if ($ResourceGroupName) 
{ 
	$VMs = Get-AzureRmVM -ResourceGroupName $ResourceGroupName
}
else 
{ 
	# $VMs = Get-AzureRmVM
    exit -1
}

# Stop each of the VMs
foreach ($VM in $VMs)
{
    $StopRtn = $VM | Stop-AzureRmVM -Force

    $VMDetail = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VM.Name -Status
    Write-Output ($VM.Name + ": " + $VMDetail.Statuses[1].DisplayStatus)
}