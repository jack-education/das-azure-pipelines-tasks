# --- Dot source handlers
Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -File  -Recurse | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function @(
    'New-ConfigurationTableEntry'
)


$Script:EmojiDictionary = @{
    GreenCheck = [System.Text.Encoding]::UTF32.GetString(@(20, 39, 0, 0))
    StopWatch = [System.Text.Encoding]::UTF32.GetString(@(241, 35, 0, 0))
    Lightning = [System.Text.Encoding]::UTF32.GetString(@(161, 38, 0, 0))    
}
