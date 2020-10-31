. "${PSScriptRoot}\logging.ps1"

function Get-RestAPIHeaders ($token) {
  $headers = @{
    Authorization = "${GitHubAPIAuthType}${DevOpsAPIAuthType} $token"
  }
  return $headers
}

function Invoke-RestMethodPost {
  param (
    [Parameter(Mandatory = $true)]
    $apiURI,
    [Parameter(Mandatory = $true)]
    $body,
    [Parameter(Mandatory = $true)]
    $token
  )

  try {
    if ($body.Count -gt 0) {
      $resp = Invoke-RestMethod `
      -Method POST `
      -Body ($body | ConvertTo-Json) `
      -Uri $apiURI `
      -Headers (Get-RestAPIHeaders -token $token) `
      -MaximumRetryCount 3
  
      return $resp
    }
    else {
      $warning = "{0} with Uri [ $apiURI ] did not fire request because of empty body." -f (Get-PSCallStack)[1].FunctionName
      LogWarning $warning
      return $null
    }
  }
  catch {
    $warning = "{0} with Uri [ $apiURI ] failed. `nBody: [ {1} ]" -f (Get-PSCallStack)[1].FunctionName , ($body | Out-String)
    LogWarning $warning
    throw 
  }
}

function Invoke-RestMethodPatch {
  param (
    [Parameter(Mandatory = $true)]
    $apiURI,
    [Parameter(Mandatory = $true)]
    $body,
    [Parameter(Mandatory = $true)]
    $token
  )

  try {
    if ($body.Count -gt 0) {
      $resp = Invoke-RestMethod `
      -Method PATCH `
      -Body ($body | ConvertTo-Json) `
      -Uri $apiURI `
      -Headers (Get-RestAPIHeaders -token $token) `
      -MaximumRetryCount 3

      return $resp
    }
    else {
      $warning = "{0} with Uri [ $apiURI ] did not fire request because of empty body." -f (Get-PSCallStack)[1].FunctionName
      LogWarning $warning
      return $null
    }
  }
  catch {
    $warning = "{0} with Uri [ $apiURI ] failed. `nBody: [ {1} ]" -f (Get-PSCallStack)[1].FunctionName , ($body | Out-String)
    LogWarning $warning
    throw 
  }
}

function Invoke-RestMethodDelete {
  param (
    [Parameter(Mandatory = $true)]
    $apiURI,
    [Parameter(Mandatory = $true)]
    $token
  )

  try {
    $resp = Invoke-RestMethod `
    -Method DELETE `
    -Uri $apiURI `
    -Headers (Get-RestAPIHeaders -token $token) `
    -MaximumRetryCount 3

    return $resp
  }
  catch {
    $warning = "{0} with Uri [ $apiURI ] failed." -f (Get-PSCallStack)[1].FunctionName
    LogWarning $warning
    throw
  }
}

function Invoke-RestMethodGet {
  param (
    [Parameter(Mandatory = $true)]
    $apiURI,
    $token
  )

  try {
    if ($token)
    {
      $resp = Invoke-RestMethod `
        -Method GET `
        -Uri $apiURI `
        -Headers (Get-RestAPIHeaders -token $token) `
        -MaximumRetryCount 3
    }
    else {
      $resp = Invoke-RestMethod `
        -Method GET `
        -Uri $apiURI `
        -MaximumRetryCount 3
    }
    return $resp
  }
  catch {
    $warning = "{0} with Uri [ $apiURI ] failed." -f (Get-PSCallStack)[1].FunctionName
    LogWarning $warning
    throw 
  }
}