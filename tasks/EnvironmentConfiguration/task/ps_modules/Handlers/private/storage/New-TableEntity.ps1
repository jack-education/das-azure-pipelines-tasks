function New-TableEntity {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Configuration,
        [Parameter(Mandatory=$true)]
        [String]$PartitionKey,
        [Parameter(Mandatory=$true)]
        [String]$RowKey
    )

    try {
        Trace-VstsEnteringInvocation $MyInvocation

        $Entity = [Microsoft.Azure.Cosmos.Table.DynamicTableEntity]::new($PartitionKey, $RowKey)
        $Entity.Properties.Add("Data", $Configuration)
        $null = $StorageTable.CloudTable.Execute([Microsoft.Azure.Cosmos.Table.TableOperation]::Insert($Entity))

    } catch {
        Write-Error -Message "$_" -ErrorAction Stop
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
