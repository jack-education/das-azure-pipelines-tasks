function New-ConfigurationEntity {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$StorageAccount,
        [Parameter(Mandatory=$true)]
        [String]$TableName,
        [Parameter(Mandatory=$true)]
        [String]$PartitionKey,
        [Parameter(Mandatory=$true)]
        [String]$RowKey,
        [Parameter(Mandatory=$true)]
        [String]$Configuration
    )

    try {

        Trace-VstsEnteringInvocation $MyInvocation

        Write-Verbose -Message "Building storage context"
        $StorageAccountKey = Get-StorageAccountKey -Name $StorageAccount
        $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageAccountKey

        Write-Verbose -Message "Searching for storage table $TableName"
        $StorageTable = Get-AzureStorageTable -Context $StorageContext -Name $TableName -ErrorAction SilentlyContinue
        if (!$StorageTable){
            Write-Verbose -Message "Creating a new storage table $TableName"
            $StorageTable = New-AzureStorageTable -Context $StorageContext -Name $TableName
        }

        $Entity = Get-TableEntity -StorageTable $StorageTable -PartitionKey $PartitionKey -RowKey $RowKey

        if ($Entity) {
            Write-Host "Updating existing entity [$RowKey]"
            Set-TableEntity -Configuration $Configuration -Entity $Entity
        }
        else {
            Write-Host "Creating a new entity [$RowKey]"
            New-TableEntity -Configuration $Configuration -PartitionKey $PartitionKey -RowKey $RowKey
        }
    } catch {
        Write-Error -Message "$_" -ErrorAction Stop
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}