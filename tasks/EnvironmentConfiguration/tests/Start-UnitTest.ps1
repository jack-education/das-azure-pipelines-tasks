Import-Module -Name $PSScriptRoot/modules/UnitTest.Helpers.psm1 -Force
Import-Module -Name $PSScriptRoot/../task/InitializationHelpers.psm1 -Force

$ErrorActionPreference = "Stop"
$ENV:IsTest = $true

Initialize-TaskDependencies

$Parameters = @{
    PassThru = $true
    OutputFormat = 'NUnitXml'
    OutputFile = "$PSScriptRoot\Test-Pester.XML"
}

Push-Location
Set-Location -Path $PSScriptRoot
$TestResults = Invoke-Pester @Parameters
Pop-Location

if ($TestResults.FailedCount -gt 0) {
    Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
}