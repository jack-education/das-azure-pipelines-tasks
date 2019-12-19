function Get-SchemaProperty {
    [CmdletBinding(DefaultParameterSetName = "Standard")]
    Param(
        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "AsInt")]
        [Parameter(Mandatory = $true, ParameterSetName = "AsNumber")]
        [Parameter(Mandatory = $true, ParameterSetName = "AsArray")]
        [Parameter(Mandatory = $true, ParameterSetName = "AsBool")]
        $PropertyObject,
        [Parameter(Mandatory = $false, ParameterSetName = "AsInt")]
        [Switch]$AsInt,
        [Parameter(Mandatory = $false, ParameterSetName = "AsNumber")]
        [Switch]$AsNumber,
        [Parameter(Mandatory = $false, ParameterSetName = "AsArray")]
        [Switch]$AsArray,
        [Parameter(Mandatory = $false, ParameterSetName = "AsBool")]
        [Switch]$AsBool
    )

    try {

        Trace-VstsEnteringInvocation $MyInvocation

        if ($PropertyObject.ExtensionData.ContainsKey("environmentVariable")) {

            $VariableName = $PropertyObject.ExtensionData.Item("environmentVariable").Value
            $TaskVariable = Get-VstsTaskVariable -Name $VariableName
            if (![string]::IsNullOrEmpty($TaskVariable)) {
                switch ($PSCmdlet.ParameterSetName) {

                    'Standard' {
                        $TaskVariable = "$($TaskVariable)"
                        break
                    }

                    'AsInt' {
                        $TaskVariable = [int]$TaskVariable
                        break
                    }

                    'AsNumber' {
                        $TaskVariable = [Decimal]::Parse($TaskVariable)
                        break
                    }

                    'AsArray' {
                        $TaskVariable = @($TaskVariable | ConvertFrom-Json)
                        break
                    }

                    'AsBool' {
                        $TaskVariable = $TaskVariable.ToLower() -in '1', 'true'
                        break
                    }
                }
                return $TaskVariable
            }
        }

        if ($null -ne $PropertyObject.Default) {
            Write-Verbose -Message "No environment variable found but a default value is present in the schema"
            $TaskVariable = $PropertyObject.Default.Value
            Write-Verbose -Message "Set default value '$TaskVariable'"
            return $TaskVariable
        }

        throw "No environment variable found and no default value set in schema"
    }
    catch {
        Write-Error -Message "Could not get property from object [ $VariableName ] : $_" -ErrorAction Stop
    }
    finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
