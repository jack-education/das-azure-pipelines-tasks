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

        $AzAccountsModule = @(Get-Module Az.Accounts -ListAvailable)[0]
        $AzureRmProfileModule = @(Get-Module AzureRm.Profile -ListAvailable)[0]

        if ($AzAccountsModule) { 
            $StorageAccount = Get-AzureRmResource -Name $Name -ResourceType "Microsoft.Storage/storageAccounts" -ErrorAction Stop
        }
        elseif ($AzureRmProfileModule) {
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