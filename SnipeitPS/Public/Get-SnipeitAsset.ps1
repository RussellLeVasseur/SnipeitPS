<#
.SYNOPSIS
Gets a list of Snipe-it Assets or specific asset

.PARAMETER search
A text string to search the assets data

.PARAMETER id
ID number of excact snipeit asset

.PARAMETER asset_tag
Exact asset tag to query

.PARAMETER asset_serial
Exact asset serialnumber to query

.PARAMETER order_number
Optionally restrict asset results to this order number

.PARAMETER model_id
Optionally restrict asset results to this asset model ID

.PARAMETER category_id
Optionally restrict asset results to this category ID

.PARAMETER manufacturer_id
Optionally restrict asset results to this manufacturer ID

.PARAMETER company_id
Optionally restrict asset results to this company ID

.PARAMETER location_id
Optionally restrict asset results to this location ID

.PARAMETER status
Optionally restrict asset results to one of these status types: RTD, Deployed, Undeployable, Deleted, Archived, Requestable

.PARAMETER status_id
Optionally restrict asset results to this status label ID

.PARAMETER sort
Specify the column name you wish to sort by

.PARAMETER order
Specify the order (asc or desc) you wish to order by on your sort column

.PARAMETER limit
Specify the number of results you wish to return. Defaults to 50. Defines batch size for -all

.PARAMETER offset
Offset to use

.PARAMETER all
A return all results, works with -offset and other parameters

.PARAMETER url
URL of Snipeit system, can be set using Set-SnipeitInfo command

.PARAMETER apiKey
Users API Key for Snipeit, can be set using Set-SnipeitInfo command

.EXAMPLE
Get-SnipeitAsset -url "https://assets.example.com"-token "token..."

.EXAMPLE
Get-SnipeitAsset -search "myMachine"-url "https://assets.example.com"-token "token..."

.EXAMPLE
Get-SnipeitAsset -search "myMachine"-url "https://assets.example.com"-token "token..."

.EXAMPLE
Get-SnipeitAsset -asset_tag "myAssetTag"-url "https://assets.example.com"-token "token..."
#>

function Get-SnipeitAsset() {
    Param(
        [parameter(ParameterSetName='Search')]
        [string]$search,

        [parameter(ParameterSetName='Get with id')]
        [int]$id,

        [parameter(ParameterSetName='Get with asset tag')]
        [string]$asset_tag,

        [parameter(ParameterSetName='Get with serial')]
        [Alias('asset_serial')]
        [string]$serial,

        [parameter(ParameterSetName='Search')]
        [string]$order_number,

        [parameter(ParameterSetName='Search')]
        [int]$model_id,

        [parameter(ParameterSetName='Search')]
        [int]$category_id,

        [parameter(ParameterSetName='Search')]
        [int]$manufacturer_id,

        [parameter(ParameterSetName='Search')]
        [int]$company_id,

        [parameter(ParameterSetName='Search')]
        [int]$location_id,

        [parameter(ParameterSetName='Search')]
        [int]$depreciation_id,

        [parameter(ParameterSetName='Search')]
        [bool]$requestable = $false,

        [parameter(ParameterSetName='Search')]
        [string]$status,

        [parameter(ParameterSetName='Search')]
        [int]$status_id,

        [parameter(ParameterSetName='Search')]
        [string]$sort = "created_at",

        [parameter(ParameterSetName='Search')]
        [ValidateSet("asc", "desc")]
        [string]$order = "desc",

        [parameter(ParameterSetName='Search')]
        [int]$limit = 50,

        [parameter(ParameterSetName='Search')]
        [int]$offset,

        [parameter(ParameterSetName='Search')]
        [switch]$all = $false,
        [parameter(mandatory = $true)]
        [string]$url,

        [parameter(mandatory = $true)]
        [string]$apiKey
    )
    Test-SnipeitAlias -invocationName $MyInvocation.InvocationName -commandName $MyInvocation.MyCommand.Name

    $SearchParameter = . Get-ParameterValue -Parameters $MyInvocation.MyCommand.Parameters -BoundParameters $PSBoundParameters


    $apiurl = "$url/api/v1/hardware"

    if ($search -and ($asset_tag -or $asset_serial -or $id)) {
         Throw "[$($MyInvocation.MyCommand.Name)] Please specify only one of -search , -asset_tag or -asset_serial parameter"
    }

    if ($id) {
       if ( $search -or $asset_serial -or $asset_tag) {
         Throw "[$($MyInvocation.MyCommand.Name)] Please specify only one of -search , -asset_tag or -asset_serial parameter"
       }
       $apiurl= "$url/api/v1/hardware/$id"
    }

    if ($asset_tag) {
       if ( $search -or $asset_serial -or $id) {
         Throw "[$($MyInvocation.MyCommand.Name)] Please specify only one of -search , -asset_tag or -asset_serial parameter"
       }
       $apiurl= "$url/api/v1/hardware/bytag/$asset_tag"
    }

    if ($asset_serial) {
       if ( $search -or $asset_tag) {
         Throw "[$($MyInvocation.MyCommand.Name)] Please specify only one of-search , -asset_tag or -asset_serial parameter"
       }
       $apiurl= "$url/api/v1/hardware/byserial/$asset_serial"
    }

    $Parameters = @{
        Uri           = $apiurl
        Method        = 'Get'
        GetParameters = $SearchParameter
        Token         = $apiKey
    }

    if ($all) {
        $offstart = $(if ($offset){$offset} Else {0})
        $callargs = $SearchParameter
        $callargs.Remove('all')

        while ($true) {
            $callargs['offset'] = $offstart
            $callargs['limit'] = $limit
            $res=Get-SnipeitAsset @callargs
            $res
            if ( $res.count -lt $limit) {
                break
            }
            $offstart = $offstart + $limit
        }
    } else {
        $result = Invoke-SnipeitMethod @Parameters
        $result
    }


}





