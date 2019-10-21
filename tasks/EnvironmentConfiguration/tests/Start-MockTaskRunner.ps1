$TestRunner = Start-Job -ScriptBlock {
    $ENV:SYSTEM_CULTURE = "en_US"
    $VerbosePreference = "Continue"
    $Debugpreference = "Continue"

    Import-Module -Name $using:PSScriptRoot/../task/ps_modules/VstsTaskSdk -Force
    Import-Module -Name $using:PSScriptRoot/modules/UnitTest.Helpers.psm1 -Force
    Import-Module -Name $using:PSScriptRoot/../task/InitializationHelpers.psm1 -Force

    try {
        Set-MockEnvironment

        $SourcePath = "$using:PSScriptRoot/resource"
        $TargetFilename = "*.schema.json"
        $TableName = "configuration"
        $StorageAccount = "testconversion41"
        $EnvironmentName = "dev"
        . $using:PSScriptRoot/../task/Invoke-Task.ps1

    }
    finally {
        Clear-MockEnvironment
    }
}
# Wait for default input
Wait-Job $TestRunner
Receive-Job $TestRunner

Wait-Job $TestRunner
Receive-Job $TestRunner
