 
InModuleScope "Handlers" {

    Describe "New-ConfigurationEntity tests" {

        BeforeAll {
            Set-MockEnvironment
            Add-DefaultMocks
        }
    
        AfterAll {
            Clear-MockEnvironment
        }

        $StorageAccount = "mock-storage-account"
        $TableName = "configuration"
        $PartitionKey = "mock-partition-key"
        $RowKey = "mock-row-key"
        $Configuration = Get-Content -Path "$PSScriptRoot/resource/SFA.DAS.Test.Valid.json" -Raw

        $NewConfigurationEntityParameters = @{
            StorageAccount = $StorageAccount
            TableName = $TableName
            PartitionKey = $PartitionKey 
            RowKey = $RowKey 
            Configuration = $Configuration
        }

        Context "When a table named 'configuration' does not exist" {

            Mock Get-AzStorageTable {
                return $null
            }
            
            It "Should create a new table in the storage account" {
                New-ConfigurationEntity @NewConfigurationEntityParameters
                Assert-MockCalled -CommandName Get-AzStorageTable -Times 1
                Assert-MockCalled -CommandName New-AzStorageTable -Times 1
            }

            It "Should throw if there is a failure when building a storage context" {
                Mock New-AzStorageContext {
                    throw "Could not build context"
                }

                { New-ConfigurationEntity @NewConfigurationEntityParameters } | Should Throw
            }
        }

        Context "When all parameters are correct and and there is an existing entity in the configuration table" {
            
            It "Should update an existing entity" {
                { New-ConfigurationEntity @NewConfigurationEntityParameters } | Should Not Throw
                Assert-MockCalled -CommandName Get-AzResource -Times 1
                Assert-MockCalled -CommandName Get-AzStorageAccountKey -Times 1
                Assert-MockCalled -CommandName Get-AzStorageTable -Times 1
    
                Assert-MockCalled -CommandName Get-TableEntity -Times 1
                Assert-MockCalled -CommandName Set-TableEntity -Times 1
            }
        }

        Context "When all parameters are correct and and there is not an existing entity in the configuration table" {
            
            Mock Get-TableEntity {
                return $null
            }

            It "Should create a new entity" {
                { New-ConfigurationEntity @NewConfigurationEntityParameters } | Should Not Throw
                Assert-MockCalled -CommandName Get-AzResource -Times 1
                Assert-MockCalled -CommandName Get-AzStorageAccountKey -Times 1
                Assert-MockCalled -CommandName Get-AzStorageTable -Times 1
    
                Assert-MockCalled -CommandName Get-TableEntity -Times 1
                Assert-MockCalled -CommandName New-TableEntity -Times 1
            }
        }
    }
}