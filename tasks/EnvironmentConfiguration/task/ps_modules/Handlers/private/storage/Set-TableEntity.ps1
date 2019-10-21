function Set-TableEntity {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Configuration,
        [Parameter(Mandatory = $true)]
        [PSObject]$Entity
    )

    try {
        Trace-VstsEnteringInvocation $MyInvocation
        $Entity.Properties["Data"].StringValue = $Configuration
        if ($Global:IsAz) {
            $null = $StorageTable.CloudTable.Execute([Microsoft.Azure.Cosmos.Table.TableOperation]::InsertOrReplace($Entity))
        }
        elseif ($Global:IsAzureRm) {
            $null = $StorageTable.CloudTable.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::InsertOrReplace($Entity))
        }
        else {
            throw "Couldn't find Global Azure module setting $($MyInvocation.ScriptLineNumber) $($MyInvocation.ScriptName)"
        }

    }
    catch {
        Write-Error -Message "$_" -ErrorAction Stop
    }
    finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
