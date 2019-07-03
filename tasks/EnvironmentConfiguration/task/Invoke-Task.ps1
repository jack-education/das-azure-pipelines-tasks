<#
#>
try {
    Trace-VstsEnteringInvocation $MyInvocation

    Import-Module -Name $PSScriptRoot/InitializationHelpers.psm1 -Force
    Initialize-TaskDependencies
    
    if ($ENV:TF_BUILD) {

        # --- Inputs
        $SourcePath = Get-VstsInput -Name SourcePath -Require
        $TargetFilename = Get-VstsInput -Name TargetFilename -Require
        $TableName = Get-VstsInput -Name TableName -Require

        $StorageAccount = Get-VstsInput -Name StorageAccountName -Require
        $ServiceEndpointName = Get-VstsInput -Name ServiceConnectionName -require

        # --- Variables
        $EnvironmentName = (Get-VstsTaskVariable -Name EnvironmentName).ToUpper()
        if (!$EnvironmentName) {
            $EnvironmentName = (Get-VstsTaskVariable -Name RELEASE_ENVIRONMENTNAME).ToUpper()
        }

        # --- Init
        $Endpoint = Get-VstsEndpoint -Name $ServiceEndpointName -Require
        Initialize-AzModule -Endpoint $Endpoint
    }

    $NewEnvironmentConfigurationTableEntryParameters = @{
        SourcePath      = $SourcePath
        TargetFilename  = $TargetFilename
        StorageAccount  = $StorageAccount
        TableName       = $TableName
        EnvironmentName = $EnvironmentName
    }

    New-ConfigurationTableEntry @NewEnvironmentConfigurationTableEntryParameters
}
catch {
    Write-Error -Message "$_" -ErrorAction Stop
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
