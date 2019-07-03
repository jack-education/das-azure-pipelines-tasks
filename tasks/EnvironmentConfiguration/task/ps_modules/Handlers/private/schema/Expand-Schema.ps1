function Expand-Schema {
    [CmdletBinding()][OutputType("System.Collections.Hashtable")]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        $PropertyObject
    )

    try {

        Trace-VstsEnteringInvocation $MyInvocation

        [Hashtable]$ProcessedProperties = @{ }
        foreach ($Key in $PropertyObject.Keys) {

            $Property = $PropertyObject.Item($Key)
            Write-Verbose -Message "Processing Property: $Property"
            Switch ($Property.Type.ToString()) {

                'Object' {
                    Write-Host "    -> [Object]$($Key)"
                    $PropertyValue = Expand-Schema -PropertyObject $Property.Properties
                    break
                }

                'Array' {
                    Write-Host "    -> [Array]$($Key)"
                    $PropertyValue = Get-SchemaProperty -PropertyObject $Property -AsArray
                    break
                }

                'String' {
                    Write-Host "    -> [String]$($Key)"
                    $PropertyValue = Get-SchemaProperty -PropertyObject $Property
                    break
                }

                'Integer' {
                    Write-Host "    -> [Integer]$($Key)"
                    $PropertyValue = Get-SchemaProperty -PropertyObject $Property -AsInt
                    break
                }

                'Number' {
                    Write-Host "    -> [Number]$($Key)"
                    $PropertyValue = Get-SchemaProperty -PropertyObject $Property -AsNumber
                    break
                }

                'Boolean' {
                    Write-Host "    -> [Bool]$($Key)"
                    $PropertyValue = Get-SchemaProperty -PropertyObject $Property -AsBool
                    break
                }

                Default {
                    $PropertyValue = "Undefined"
                    break
                }

            }

            $ProcessedProperties.Add($Key, $PropertyValue)
        }

        Write-Output $ProcessedProperties

    }
    catch {
        Write-Error -Message "Failed to expand schema property [$Key] $_" -ErrorAction Stop
    }
    finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}