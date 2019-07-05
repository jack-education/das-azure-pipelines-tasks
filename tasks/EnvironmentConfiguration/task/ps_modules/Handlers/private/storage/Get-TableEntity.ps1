function Get-TableEntity {
    <#
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [PSObject]$StorageTable,
        [Parameter(Mandatory = $true)]
        [String]$PartitionKey,
        [Parameter(Mandatory = $true)]
        [String]$RowKey
    )

    try {
        Trace-VstsEnteringInvocation $MyInvocation

        if ($Global:IsAz) {
            $TableOperation = [Microsoft.Azure.Cosmos.Table.TableOperation]::Retrieve($PartitionKey, $RowKey)
        }
        elseif ($Global:IsAzureRm) {
            $TableOperation = [Microsoft.WindowsAzure.Storage.Table.TableOperation]::Retrieve($PartitionKey, $RowKey)

        }
        $Entity = $StorageTable.CloudTable.Execute($TableOperation, $null, $null)

        Write-Output $Entity.Result

    }
    catch {
        Write-Error -Message "$_" -ErrorAction Stop
    }
    finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
