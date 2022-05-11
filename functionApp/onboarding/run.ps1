using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$processId = $Request.Query.ProcessId
Write-Output $processId
Write-Output $Request
if (-not([string]::IsNullOrWhiteSpace($processId))) {

    try {
        $payload = $($Request.RawBody) | ConvertFrom-Json
    }
    catch {
        $body = "Invalid payload"
    }

    try {
        $KeyVaultName = "$env:keyVaultName"
        $offSet = $processId -replace "[a-zA-Z -]"

        $prefix = Get-Prefix -processId $processId -value $payload.a
        Write-Output "Prefix Value: [$($prefix)]"

        Write-Output "Setting Application ID"
        Set-AzKeyVaultSecret `
            -VaultName $KeyVaultName `
            -SecretName ($prefix + '-' + "applicationid") `
            -SecretValue ( ConvertTo-Key `
                -value $payload.b `
                -KeySet $processId `
                -subKey 1
        )

        Write-Output "Setting Application Key"
        Set-AzKeyVaultSecret `
            -VaultName $KeyVaultName `
            -SecretName ($prefix + '-' + "applicationkey") `
            -SecretValue ( ConvertTo-Key `
                -value $payload.c `
                -KeySet $processId `
                -subKey 2
        )

        Write-Output "Setting Tenant ID"
        Set-AzKeyVaultSecret `
            -VaultName $KeyVaultName `
            -SecretName ($prefix + '-' + "tenantid") `
            -SecretValue ( ConvertTo-Key `
                -value $payload.d `
                -KeySet $processId `
                -subKey 3
        )

        $body = "Succesfully processed request for customer ID: [$($prefix)]"
    }
    catch {
        $body = "Unable to process the request, please contact support for customer ID: [$($prefix)]"
    }

    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $body
        })
}
