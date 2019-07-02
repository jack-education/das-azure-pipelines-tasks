<#
    .SYNOPSIS
    Install common task modules at build time.

    .DESCRIPTION
    Install common task modules at build time.

    .PARAMETER TaskRoot
    The root of the task to be built

    .PARAMETER Clean
    Clean package directories before building

    .PARAMETER Build
    Package an extension package

    .PARAMETER Publish
    Packge and publish an extension package to the marketplace

    .PARAMETER AccessToken
    A personal access token with enough privileges to publish the package

    .PARAMETER SkipRestore
    Don't restore dependencies listed in dependency.json

    .EXAMPLE
    Restore-TaskDependency -TaskRoot ./MyTask

    .EXAMPLE
    Restore-TaskDependency -TaskRoot ./MyTask -Clean

    .EXAMPLE
    Restore-TaskDependency -TaskRoot ./MyTask -Clean -Build

    .EXAMPLE
    Restore-TaskDependency -TaskRoot ./MyTask -Clean -Publish

    .EXAMPLE
    Restore-TaskDependency -TaskRoot ./MyTask -Publish -SkipRestore

    .NOTES
    Requirements:
    The following applications must be installed an available in your PATH
    - git
    - tfx-cli
#>
[CmdletBinding(DefaultParameterSetName = "Build")]
Param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$TaskRoot,
    [Parameter(Mandatory = $false)]
    [switch]$Clean,
    [Parameter(Mandatory = $false)]
    [Parameter(Mandatory = $true, ParameterSetName = "Build")]
    [switch]$Build,
    [Parameter(Mandatory = $false, ParameterSetName = "Publish")]
    [switch]$Publish,
    [Parameter(Mandatory = $true, ParameterSetName = "Publish")]
    [string]$AccessToken,
    [Parameter(Mandatory = $false)]
    [switch]$SkipRestore
)

# Default error action to stop
$ErrorActionPreference = "Stop"

function Set-PatchVersion {
    Param (
        [Parameter(Mandatory = $true)]
        [String]$TaskRoot
    )

    try {
        $Manifest = "$TaskRoot/vss-extension.json"
        $Task = "$TaskRoot/task/task.json"
    
        $ManifestObject = Get-Content -Path $Manifest -Raw | ConvertFrom-Json
        $TaskObject = Get-Content -Path $Task -Raw | ConvertFrom-Json
    
        [Version]$Version = $ManifestObject.Version
        $Increment = $Version.Build + 1
        $NewVersion = "$($Version.Major).$($Version.Minor).$Increment"
        Write-Verbose -Message "Version set to $NewVersion"
    
        $ManifestObject.Version = [Version]::new($NewVersion).ToString()
        $TaskObject.Version.Patch = $Increment
    
        $ManifestObject | ConvertTo-Json -Depth 10 | Set-Content -Path $Manifest
        $TaskObject | ConvertTo-Json -Depth 10 | Set-Content -Path $Task

    } catch {
        Write-Error -Message "Failed to update task version number: $_" -ErrorAction Stop
    }

}


try {

    # --- Ensure that nuget is available
    $null = Register-PackageSource -ProviderName Nuget -Name nuget.org -Location https://www.nuget.org/api/v2 -Trusted:$true -Force

    Write-Verbose -Message "Resolving common paths.."
    $ResolvedTaskRoot = (Resolve-Path -Path "$TaskRoot").Path
    $ConfigPath = "$($ResolvedTaskRoot)/dependency.json"
    $PackageTemp = "$($ENV:Temp)/$((New-Guid).ToString())"
    $ReleaseTaskRoot = "$PSScriptRoot/Release/$($TaskRoot.BaseName)"

    $null = New-Item -Path $PackageTemp -ItemType Directory -Force
    Write-Verbose -Message "ResolvedTaskRoot: $ResolvedTaskRoot"
    Write-Verbose -Message "ReleaseTaskRoot: $ReleaseTaskRoot"
    Write-Verbose -Message "ConfigPath: $ConfigPath"

    if (!$ConfigPath) {
        throw "Could not find dependency.json at $ConfigPath"
    }

    Write-Verbose -Message "Retrieving config definition from $ConfigPath"
    $Config = (Get-Content -Path $ConfigPath -Raw) | ConvertFrom-Json

    if ($Clean.IsPresent -and $SkipRestore.IsPresent){
        Write-Warning -Message "Don't use Clean and SkipRestore together. Clean task will now be skipped!"
    }

    if ($Clean.IsPresent -and !$SkipRestore.IsPresent) {
        Write-Host "Cleaning package directories:"
        $Config.Include | Select-Object -Property Path -Unique | ForEach-Object {
            if ($_.Path) {
                Write-Host " - $($_.Path)"
                Get-ChildItem -Path "$($ReleaseTaskRoot)/$($_.Path)" -Recurse | Remove-Item -Recurse -Force
            }
        }

        Remove-Item -Path "$PSScriptRoot/Release" -Force -Recurse -ErrorAction SilentlyContinue
    }

    if ($Build.IsPresent) {
        Set-PatchVersion -TaskRoot $ResolvedTaskRoot
    }

    $null = New-Item -Path $ReleaseTaskRoot -ItemType Directory -Force -ErrorAction SilentlyContinue
    Copy-Item -Path $ResolvedTaskRoot -Destination "$PSScriptRoot/Release" -Recurse -Force

    if (!$SkipRestore.IsPresent) {

        foreach ($Package in $Config.Include | Sort-Object -Property Type) {
            Write-Verbose -Message "Processing package dependency $($Package.Name)"
            Write-Verbose -Message "Clean package directories: $($NoResotre.IsPresent)"

            Write-Verbose -Message "Resolving package path"
            [System.IO.FileInfo]$ResolvedPackagePath = "$($ReleaseTaskRoot)/$($Package.Path)"
            Write-Verbose -Message "ResolvedPackagePath: $ReleaseTaskRoot"


            switch ($Package.Type) {
                'PSGallery' {

                    $PackageInstallDirectory = "$PackageTemp/$($Package.Name)"

                    $SaveModuleParameters = @{
                        Name            = $Package.Name
                        Path            = $PackageTemp
                        RequiredVersion = $Package.Version
                        Force           = $true
                    }

                    Write-Host "[PSGallery] Saving module $($Package.Name) to $PackageTemp "
                    Save-Module @SaveModuleParameters

                    if ($Package.Copy) {
                        $Package.Copy | ForEach-Object {
                            Write-Host "[PSGallery] Copying module $($Package.Name) to $($Package.Path)"
                            Copy-Item -Path $PackageInstallDirectory/$_ -Destination "$ResolvedPackagePath/$($Package.Name)" -Recurse -Force
                        }
                    }

                    break
                }
                'Nuget' {

                    $PackageDestination = "$PackageTemp/$($Package.Name).$($Package.Version)"

                    $InstallPackageParameters = @{
                        Name             = $Package.Name
                        Destination      = $PackageTemp
                        SkipDependencies = $true
                        ForceBootstrap   = $true
                        RequiredVersion  = $Package.Version
                        Force            = $true
                    }

                    Write-Host "[NuGet] Installing package $($Package.Name) to $($PackageTemp)"
                    $null = Install-Package @InstallPackageParameters

                    if ($Package.Copy) {
                        $null = New-Item -Path $ResolvedPackagePath -ItemType Directory -ErrorAction SilentlyContinue
                        $Package.Copy | ForEach-Object {
                            Write-Host "[NuGet] Copying dependency $_ to $ResolvedPackagePath"
                            Copy-Item -Path $PackageDestination/$_ -Destination $ResolvedPackagePath -Recurse -Force
                        }
                    }

                    break
                }
                'GitHub' {
                    $RepositoryUrl = "https://github.com/$($Package.Name).git"
                    $RepositoryDestination = "$PackageTemp/$($Package.Name.Split("/")[1])"
                    Write-Host "[GitHub] Processing $($RepositoryUrl)"
                    & git.exe clone $RepositoryUrl $RepositoryDestination | Out-Null

                    if ($Package.Copy) {
                        $Package.Copy | ForEach-Object {
                            Write-Host "[GitHub] Copying dependency $_ to $($Package.Path)"
                            Copy-Item -Path $RepositoryDestination/$_ -Destination $ResolvedPackagePath -Recurse -Force
                        }
                    }

                    break
                }
                'Local' {
                    if ($Package.Copy) {
                        $Package.Copy | ForEach-Object {
                            Write-Host "[Local] Copying dependency $_ to $($Package.Path)"
                            Copy-Item -Path $ResolvedTaskRoot/$_ -Destination $ResolvedPackagePath -Recurse -Force
                        }
                    }
                }
                'Defaut' {
                    throw "Unknown package type: $($Package.Type). Supported package types are [GitHub, NuGet, PowerShellGallery]"
                }
            }
        }
    }

    if ($Build.IsPresent -and !$ENV:TF_BUILD) {
        & tfx extension create --root $ReleaseTaskRoot --manifest-globs "$ReleaseTaskRoot/vss-extension.json" --output-path "$PSScriptRoot/Release/bin"
    }

    if ($Publish.IsPresent -and !$ENV:TF_BUILD) {
        & tfx extension publish --manifest-globs "$ReleaseTaskRoot/vss-extension.json" --auth-type pat --token $AccessToken --output-path "$PSScriptRoot/Release/bin"
    }
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}
finally {
    Write-Verbose -Message "Cleaning temp directory $PackageTemp"
    Remove-Item -Path $PackageTemp -Recurse -Force
}
