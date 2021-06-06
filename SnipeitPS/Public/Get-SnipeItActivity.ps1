<#
.SYNOPSIS
Gets and search Snipe-it Activity history

.DESCRIPTION
Gets a list of Snipe-it activity history

.PARAMETER search
A text string to search the Activity history

.PARAMETER target_type
Type of target. One from following list 'Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User'

.PARAMETER target_id
Needed if target_type is specified

.PARAMETER item_type
Type of target. One from following list 'Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User'

.PARAMETER item_id
Needed if target_type is specified

.PARAMETER action_type
Type of action. One from following list "add seats", "checkin from", 'checkout' or 'update'

.PARAMETER offset
Result offset to use

.PARAMETER all
A return all results, works with -offset and other parameters

.PARAMETER url
URL of Snipeit system, can be set using Set-SnipeItInfo command

.PARAMETER apiKey
Users API Key for Snipeit, can be set using Set-SnipeItInfo command

.EXAMPLE
Get-SnipeItAccessory -search Keyboard

.EXAMPLE
Get-SnipeItAccessory -id 1

#>

function Get-SnipeItActivity() {
    Param(

        [string]$search,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User')]
        [string]$target_type,

        [Parameter(Mandatory=$false)]
        [int]$target_id,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Accessory','Asset','AssetMaintenance','AssetModel','Category','Company','Component','Consumable','CustomField','Depreciable','Depreciation','Group','Licence','LicenseSeat','Location','Manufacturer','Statuslabel','Supplier','User')]
        [string]$item_type,

        [Parameter(Mandatory=$false)]
        [int]$item_id,

        [ValidateSet("add seats", "checkin from", 'checkout','update')]
        [string]$action_type ,

        [int]$limit = 50,

        [int]$offset,

        [switch]$all = $false,

        [parameter(mandatory = $true)]
        [string]$url,

        [parameter(mandatory = $true)]
        [string]$apiKey
    )

    if(($target_type -and -not $target_id) -or
        ($target_id -and -not $target_type)) {
        throw "Please specify both target_type and target_id"
    }

    if(($item_type -and -not $item_id) -or
        ($item_id -and -not $item_type)) {
        throw "Please specify both item_type and item_id"
    }

    $SearchParameter = . Get-ParameterValue $MyInvocation.MyCommand.Parameters


    $Parameters = @{
        Uri           = "$url/api/v1/reports/activity"
        Method        = 'Get'
        GetParameters = $SearchParameter
        Token         = $apiKey
    }

    if ($all) {
        $offstart = $(if($offset){$offset} Else {0})
        $callargs = $SearchParameter
        $callargs.Remove('all')

        while ($true) {
            $callargs['offset'] = $offstart
            $callargs['limit'] = $limit
            $res=Get-SnipeItActivity @callargs
            $res
            if ($res.count -lt $limit) {
                break
            }
            $offstart = $offstart + $limit
        }
    } else {
        $result = Invoke-SnipeitMethod @Parameters
        $result
    }
}





