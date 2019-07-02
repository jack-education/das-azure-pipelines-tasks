[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [System.IO.FileInfo]$TestRoot
)

$ResolvedTestRoot = $TestRoot.FullName

$Parameters = @{
    PassThru = $true
    OutputFormat = 'NUnitXml'
    OutputFile = "$ResolvedTestRoot\Test-Pester.XML"
}

Push-Location
Set-Location -Path $ResolvedTestRoot
$TestResults = Invoke-Pester @Parameters
Pop-Location

if ($TestResults.FailedCount -gt 0) {
    Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed" -ErrorAction Stop
}