function Get-StorageAccountKey {
    <#
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Name
    )

    try {
        Trace-VstsEnteringInvocation $MyInvocation

        if ($Script:IsAz) { 
            $StorageAccount = Get-AzureRmResource -Name $Name -ResourceType "Microsoft.Storage/storageAccounts" -ErrorAction Stop
        }
        elseif ($Script:IsAzureRm) {
            $StorageAccount = Find-AzureRmResource -Name $Name -ResourceType "Microsoft.Storage/storageAccounts" -ErrorAction Stop
        }

        if (!$StorageAccount) {
            Write-Error -Message "Could not find storage account resource." -ErrorAction Stop
        }

        $StorageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccount.ResourceGroupName -Name $Name)[0].Value
        Write-Output $StorageAccountKey
    }
    catch {
        Write-Error -Message "Failed to retrieve key from $($Name): $_" -ErrorAction Stop
    }
    finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}