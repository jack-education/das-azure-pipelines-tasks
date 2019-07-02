# --- Dot source handlers
Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -File  -Recurse | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function @(
    'New-ConfigurationTableEntry'
)


$Script:EmojiDictionary = @{
    GreenCheck = [System.Text.Encoding]::UTF32.GetString([System.Text.Encoding]::UTF32.GetBytes("✔"))
    StopWatch = [System.Text.Encoding]::UTF32.GetString([System.Text.Encoding]::UTF32.GetBytes("⏱"))
    Lightning = [System.Text.Encoding]::UTF32.GetString([System.Text.Encoding]::UTF32.GetBytes("⚡"))    
}
