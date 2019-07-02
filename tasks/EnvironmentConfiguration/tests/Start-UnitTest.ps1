$ENV:SYSTEM_CULTURE = "en_US"
$ErrorActionPreference = "Stop"
$ENV:IsTest = $false

Import-Module -Name $PSScriptRoot/../task/InitializationHelpers.psm1 -Force -Global

# function Global:Trace-VstsLeavingInvocation {
# }

# function Global:Trace-VstsEnteringInvocation {
# }

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