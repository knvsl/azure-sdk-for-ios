. "${PSScriptRoot}\logging.ps1"
. "${PSScriptRoot}\Invoke-RestAPI.ps1"

$GithubAPIBaseURI = "https://api.github.com/repos"
$DevOpsAPIAuthType = "bearer"

function Set-GitHubAPIParameters ($members,  $parameterName, $parameters, $allowEmptyMembers=$false) {
  if ($null -ne $members) {
    if ($members -is [array])
    {
      $parameters[$parameterName] = $members
    }
    else {
      $memberAdditions = @($members.Split(",") | % { $_.Trim() } | ? { return $_ })
      if (($memberAdditions.Count -gt 0) -or $allowEmptyMembers) {
        $parameters[$parameterName] = $memberAdditions
      }
    }
  }

  return $parameters
}

function Get-GitHubPullRequests {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [ValidateSet("open","closed","all")]
    $State = "open",
    $Head,
    $Base,
    [ValidateSet("created","updated","popularity","long-running")]
    $Sort,
    [ValidateSet("asc","desc")]
    $Direction,
    [ValidateNotNullOrEmpty()]
    $AuthToken
  )

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/pulls"
  if ($State -or $Head -or $Base -or $Sort -or $Direction) { $uri += '?' }
  if ($State) { $uri += "state=$State&" }
  if ($Head) { $uri += "head=$Head&" }
  if ($Base) { $uri += "base=$Base&" }
  if ($Sort) { $uri += "sort=$Sort&" }
  if ($Direction){ $uri += "direction=$Direction&" }

  return Invoke-RestMethodGet -apiURI $uri -token $AuthToken
}

# 
<#
.PARAMETER Ref
Ref to search for
Pass 'heads/<branchame> ,tags/<tag name>, or nothing
#>
function Get-GitHubSourceReferences {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    $Ref,
    [ValidateNotNullOrEmpty()]
    $AuthToken
  )

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/git/matching-refs/"
  if ($Ref) { $uri += "$Ref" }

  return Invoke-RestMethodGet -apiURI $uri -token $AuthToken
}

function Get-GitHubPullRequest {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [Parameter(Mandatory = $true)]
    $PullRequestNumber,
    [ValidateNotNullOrEmpty()]
    $AuthToken
  )

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/pulls/$PullRequestNumber"
  return Invoke-RestMethodGet -apiURI $uri -token $AuthToken
}

function New-GitHubPullRequest {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [Parameter(Mandatory = $true)]
    $Title,
    [Parameter(Mandatory = $true)]
    $Head,
    [Parameter(Mandatory = $true)]
    $Base,
    $Body=$Title,
    [Boolean]$Maintainer_Can_Modify=$false,
    [Boolean]$Draft=$false,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken
  )

  $parameters = @{
    title                 = $Title
    head                  = $Head
    base                  = $Base
    body                  = $Body
    maintainer_can_modify = $Maintainer_Can_Modify
    draft                = $Draft
  }

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/pulls"
  return Invoke-RestMethodPost -apiURI $uri -body $parameters -token $AuthToken
}

function Add-GitHubIssueComment {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [Parameter(Mandatory = $true)]
    $IssueNumber,
    [Parameter(Mandatory = $true)]
    $Comment,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken

  )
  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/issues/$IssueNumber/comments"

  $parameters = @{
    body = $Comment
  }

  return Invoke-RestMethodPost -apiURI $uri -body $parameters -token $AuthToken
}

# Will add labels to existing labels on the issue
function Add-GitHubIssueLabels {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [Parameter(Mandatory = $true)]
    $IssueNumber,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $Labels,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken
  )

  if ($Labels.Trim().Length -eq 0)
  {
    throw " The 'Labels' parameter should not not be whitespace.
    Use the 'Update-Issue' function if you plan to reset the labels"
  }

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/issues/$IssueNumber/labels"
  $parameters = @{}
  $parameters = Set-GitHubAPIParameters -members $Labels -parameterName "labels" `
  -parameters $parameters

  return Invoke-RestMethodPost -apiURI $uri -body $parameters -token $AuthToken
}

# Will add assignees to existing assignees on the issue
function Add-GitHubIssueAssignees {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [Parameter(Mandatory = $true)]
    $IssueNumber,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $Assignees,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken
  )

  if ($Assignees.Trim().Length -eq 0)
  {
    throw "The 'Assignees' parameter should not be whitespace.
    You can use the 'Update-Issue' function if you plan to reset the Assignees"
  }

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/issues/$IssueNumber/assignees"
  $parameters = @{}
  $parameters = Set-GitHubAPIParameters -members $Assignees -parameterName "assignees" `
  -parameters $parameters

  return Invoke-RestMethodPost -apiURI $uri -body $parameters -token $AuthToken
}

function Add-GitHubPullRequestReviewers {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [Parameter(Mandatory = $true)]
    $PrNumber,
    $Users,
    $Teams,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken
  )

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/pulls/$PrNumber/requested_reviewers"
  $parameters = @{}

  $parameters = Set-GitHubAPIParameters -members $Users -parameterName "reviewers" `
  -parameters $parameters

  $parameters = Set-GitHubAPIParameters -members $Teams -parameterName "team_reviewers" `
  -parameters $parameters

  return Invoke-RestMethodPost -apiURI $uri -body $parameters -token $AuthToken
}

# For labels and assignee pass comma delimited string, to replace existing labels or assignees.
# Or pass white space " " to remove all labels or assignees
function Update-GitHubIssue {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [Parameter(Mandatory = $true)]
    $IssueNumber,
    [string]$Title,
    [string]$Body,
    [ValidateSet("open","closed")]
    [string]$State,
    [int]$Milestome,
    $Labels,
    $Assignees,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken
  )

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/issues/$IssueNumber"
  $parameters = @{}
  if ($Title) { $parameters["title"] = $Title }
  if ($Body) { $parameters["body"] = $Body }
  if ($State) { $parameters["state"] = $State }
  if ($Milestone) { $parameters["milestone"] = $Milestone }

  $parameters = Set-GitHubAPIParameters -members $Labels -parameterName "labels" `
  -parameters $parameters -allowEmptyMembers $true

  $parameters = Set-GitHubAPIParameters -members $Assignees -parameterName "assignees" `
  -parameters $parameters -allowEmptyMembers $true

  return Invoke-RestMethodPatch -apiURI $uri -body $parameters -token $AuthToken
}

function Remove-GitHubSourceReferences  {
  param (
    [Parameter(Mandatory = $true)]
    $RepoOwner,
    [Parameter(Mandatory = $true)]
    $RepoName,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $Ref,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    $AuthToken
  )

  if ($Ref.Trim().Length -eq 0)
  {
    throw "You must supply a valid 'Ref' Parameter to 'Delete-GithubSourceReferences'."
  }

  $uri = "$GithubAPIBaseURI/$RepoOwner/$RepoName/git/refs/$Ref"

  return Invoke-RestMethodDelete -apiURI $uri -token $AuthToken
}