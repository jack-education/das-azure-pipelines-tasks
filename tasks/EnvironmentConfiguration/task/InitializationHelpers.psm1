function Initialize-TaskDependencies {
    [CmdletBinding()]
    Param()
    try {
        # --- Hacky, but needed to override a call to this function by the AzureHelpers that is breaking the pipeline
        function Global:Get-VstsWebProxy {
            Write-Output $null
        }

        Import-CustomLibraries -ErrorAction Stop
        Import-CustomModules -ErrorAction Stop
    }
    catch {
        Write-Error -Message "Could not initialize task dependencies: $($_.Exception.Message)" -ErrorAction Stop
    }
}

function Import-CustomLibraries {
    [CmdletBinding()]
    Param()
    $null = Get-ChildItem -Path "$PSScriptRoot\Lib\*.dll" | ForEach-Object {
        try {
            Write-Verbose -Message "Adding library $($_.Name)"
            Add-Type -Path $_.FullName
        }
        catch [System.Reflection.ReflectionTypeLoadException] {
            Write-Error -Message $_.Exception.Message -ErrorAction Stop
        }
    }
}

function Import-CustomModules {
    [CmdletBinding()]
    Param()
    try {

        #--- Explicity import the sdk before other modules
        if (!$ENV:IsTest) {
            Import-Module -Name "$PSScriptRoot\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1" -Global
        }

        if ($ENV:TF_BUILD) {
            $null = Get-ChildItem -Path "$PSScriptRoot\ps_modules\" -Directory | Where-Object { $_.Name -ne "VstsTaskSdk" } | ForEach-Object {
                Write-Verbose -Message "Importing Module $($_.Name)"
                Import-Module -Name $_.FullName -Global -Force
            }
        }
        else {
            # --- TODO: No excuse for this.. make it better..
            Import-Module "$PSScriptRoot\ps_modules\Handlers" -Global -Force
        }

    }
    catch {
        # --- TODO: Create an error record handler that returns a custom record and replace $_
        Write-Error -Message $_.Exception.Message -ErrorAction Stop
    }
}

Export-ModuleMember -Function @(
    'Initialize-TaskDependencies'
)
