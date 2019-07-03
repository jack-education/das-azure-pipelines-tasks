function Test-ConfigurationEntity {
    <#
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [String]$Configuration,
        [Parameter(Mandatory = $true)]
        [String]$SchemaDefinitionPath
    )

    try {
        Trace-VstsEnteringInvocation $MyInvocation

        Write-Host "Validating $($Script:EmojiDictionary.StopWatch)"
        $SchemaDefinition = Get-Content -Path $SchemaDefinitionPath -Raw
        $SchemaObject = [Newtonsoft.Json.Schema.JSchema, Newtonsoft.Json.Schema, Version = 2.0.0.0, Culture = neutral, PublicKeyToken = 30ad4fe6b2a6aeed]::Parse($SchemaDefinition)

        $ConfigurationObject = [Newtonsoft.Json.Linq.JToken]::Parse($Configuration)
        [Newtonsoft.Json.Schema.SchemaExtensions]::Validate($ConfigurationObject, $SchemaObject)

        Write-Host "Configuration validated $($Script:EmojiDictionary.GreenCheck)"
    }
    catch {
        Write-Error -Message "Validation failed: $($_.Exception.InnerException.Message)" -ErrorAction Stop
    }
    finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
