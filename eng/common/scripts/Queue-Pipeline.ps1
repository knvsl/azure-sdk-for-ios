[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Mandatory = $true)]
  [string]$Organization,

  [Parameter(Mandatory = $true)]
  [string]$Project,

  [Parameter(Mandatory = $true)]
  [string]$SourceBranch,

  [Parameter(Mandatory = $true)]
  [int]$DefinitionId,

  [Parameter(Mandatory = $false)]
  [string]$VsoQueuedPipelines,

  [Parameter(Mandatory = $true)]
  [string]$AuthToken
)

. "${PSScriptRoot}\logging.ps1"
. "${PSScriptRoot}\Invoke-DevOpsAPI.ps1"

try {
  $resp = Start-Build -SourceBranch $SourceBranch -DefinitionId $DefinitionId -AuthToken $AuthToken
}
catch {
  LogError "Start-Build failed with exception:`n$_"
  exit 1
}

LogDebug "Pipeline [ $($resp.definition.name) ] queued at [ $($resp._links.web.href) ]"

if ($VsoQueuedPipelines) {
  $enVarValue = [System.Environment]::GetEnvironmentVariable($VsoQueuedPipelines)
  $QueuedPipelineLinks = if ($enVarValue) { 
    "$enVarValue<br>[$($resp.definition.name)]($($resp._links.web.href))"
  }else {
    "[$($resp.definition.name)]($($resp._links.web.href))"
  }
  $QueuedPipelineLinks
  Write-Host "##vso[task.setvariable variable=$VsoQueuedPipelines]$QueuedPipelineLinks"
}