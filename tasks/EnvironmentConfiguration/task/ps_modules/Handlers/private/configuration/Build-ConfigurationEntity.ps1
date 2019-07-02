function Build-ConfigurationEntity {
    <#
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$SchemaDefinitionPath
    )

    try {
            Trace-VstsEnteringInvocation $MyInvocation

            Write-Host "Parsing schema: $(([System.IO.FileInfo]$SchemaDefinitionPath).Name) $($Script:EmojiDictionary.Lightning)"
            $SchemaDefinition = Get-Content -Path $SchemaDefinitionPath -Raw
            $SchemaObject = [Newtonsoft.Json.Schema.JSchema, Newtonsoft.Json.Schema, Version = 3.0.0.0, Culture = neutral, PublicKeyToken = 30ad4fe6b2a6aeed]::Parse($SchemaDefinition)

            Write-Host "Processing properties"
            $Settings = [Newtonsoft.Json.JsonSerializerSettings]::new()
            $Settings.MaxDepth = 100
            $Configuration = [Newtonsoft.Json.JsonConvert]::SerializeObject((Expand-Schema -PropertyObject $SchemaObject.Properties), $Settings)

            Write-Output $Configuration
    }
    catch {
        Write-Error -Message "$_" -ErrorAction Stop
    }
    finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}