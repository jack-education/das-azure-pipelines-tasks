$ENV:SYSTEM_CULTURE = "en_US"
$VerbosePreference = "Continue"
$Debugpreference = "Continue"

Import-Module -Name $PSScriptRoot/../task/ps_modules/VstsTaskSdk -Force
Import-Module -Name $PSScriptRoot/modules/UnitTest.Helpers.psm1 -Force
Import-Module -Name $PSScriptRoot/../task/InitializationHelpers.psm1 -Force

try {
    Set-MockEnvironment

    $SourcePath = "$PSScriptRoot/resource"
    $TargetFilename = "*.schema.json"
    $TableName = "configuration"
    $StorageAccount = "helloitscraigstr"
    $EnvironmentName = "dev"
    . $PSScriptRoot/../task/Invoke-Task.ps1

}
finally {
    Clear-MockEnvironment
}
