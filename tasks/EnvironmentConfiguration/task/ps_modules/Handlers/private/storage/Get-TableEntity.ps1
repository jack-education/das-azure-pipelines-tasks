function Get-TableEntity {
<#
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [PSObject]$StorageTable,
        [Parameter(Mandatory=$true)]
        [String]$PartitionKey,
        [Parameter(Mandatory=$true)]
        [String]$RowKey
    )

    try {
        Trace-VstsEnteringInvocation $MyInvocation

        $TableOperation = [Microsoft.Azure.Cosmos.Table.TableOperation]::Retrieve($PartitionKey, $RowKey)
        $Entity = $StorageTable.CloudTable.Execute($TableOperation, $null, $null)

        Write-Object $Entity.Result

    } catch {
        Write-Error -Message "$_" -ErrorAction Stop
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
