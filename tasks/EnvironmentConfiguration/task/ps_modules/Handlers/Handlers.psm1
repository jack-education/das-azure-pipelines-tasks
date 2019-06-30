# --- Dot source handlers
Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -File  -Recurse | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function @(
    'New-ConfigurationTableEntry'
)
