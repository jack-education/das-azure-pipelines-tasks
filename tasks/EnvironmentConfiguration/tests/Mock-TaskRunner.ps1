Import-Module -Name $PSScriptRoot/../task/ps_modules/VstsTaskSdk -Force

$SourcePath = "$PSScriptRoot/resource"
$TargetFilename = "*.schema.json"
$TableName = "configuration"
$StorageAccount = "helloitscraigstr"
$EnvironmentName = "dev"


. $PSScriptRoot/../task/Invoke-Task.ps1