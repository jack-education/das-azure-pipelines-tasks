function Set-TableEntity {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Configuration,
        [Parameter(Mandatory=$true)]
        [PSObject]$Entity
    )

    try {
        Trace-VstsEnteringInvocation $MyInvocation
        $Entity.Properties["Data"].StringValue = $Configuration
        $null = $StorageTable.CloudTable.Execute([Microsoft.Azure.Cosmos.Table.TableOperation]::InsertOrReplace($Entity))

    } catch {
        Write-Error -Message "$_" -ErrorAction Stop
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation

    }

}
