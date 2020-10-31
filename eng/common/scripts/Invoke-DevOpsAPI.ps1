. "${PSScriptRoot}\logging.ps1"
. "${PSScriptRoot}\Invoke-RestAPI.ps1"

$DevOpsAPIBaseURI = "https://dev.azure.com/{0}/{1}/_apis/{2}/{3}?{4}api-version=6.0"
$GitHubAPIAuthType = "Basic"

function Start-DevOpsBuild {
  param (
    $Organization="azure-sdk",
    $Project="internal",
    [Parameter(Mandatory = $true)]
    $SourceBranch,
    [Parameter(Mandatory = $true)]
    $DefinitionId,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken # Base 64 Encoded PAT
  )

  $uri = "$DevOpsAPIBaseURI" -F $Organization, $Project , "build" , "builds"

  $body = @{
    sourceBranch = $SourceBranch
    definition = @{ id = $DefinitionId }
  }

  return Invoke-RestMethodPost -apiURI $uri -body $body -token $AuthToken
}

function Update-DevOpsBuild {
  param (
    $Organization="azure-sdk",
    $Project="internal",
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $BuildId,
    $Status,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken # Base 64 Encoded PAT
  )

  $uri = "$DevOpsAPIBaseURI" -F $Organization, $Project , "build" , "builds/$BuildId"
  $body = @{}

  if ($Status) { $body["status"] = $Status}

  return Invoke-RestMethodPatch -apiURI $uri -body $body -token $AuthToken
}

function Get-DevOpsBuilds {
  param (
    $Organization="azure-sdk",
    $Project="internal",
    $BranchName, #Should start with 'refs/heads/'
    $Definitions, # Comma seperated string of definition IDs
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken # Base 64 Encoded PAT
  )

  $query = ""

  if ($branchName) { $query += "branchName=$BranchName&" }
  if ($definitions) { $query += "definitions=$Definitions&" }
  $uri = "$DevOpsAPIBaseURI" -F $Organization, $Project , "build" , "builds", $query

  return Invoke-RestMethodGet -apiURI $uri -token $AuthToken
}
