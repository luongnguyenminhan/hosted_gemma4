#!/usr/bin/env pwsh
param(
  [string]$Url = "http://localhost:8000",
  [string]$Model = "gemma-4-e4b-uncensored",
  [string]$Prompt = "Viết hàm Python kiểm tra số nguyên tố.",
  [int]$MaxTokens = 256,
  [double]$Temperature = 0.7,
  [switch]$Stream
)

Write-Host "[health] $Url/health" -ForegroundColor Cyan
try {
  $h = Invoke-RestMethod -Uri "$Url/health" -TimeoutSec 5
  Write-Host ($h | ConvertTo-Json -Compress)
} catch {
  Write-Host "health check failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

$body = @{
  model       = $Model
  messages    = @(@{ role = "user"; content = $Prompt })
  max_tokens  = $MaxTokens
  temperature = $Temperature
  stream      = [bool]$Stream
} | ConvertTo-Json -Depth 5 -Compress

Write-Host "`n[chat] POST $Url/v1/chat/completions" -ForegroundColor Cyan
Write-Host "body: $body" -ForegroundColor DarkGray

if ($Stream) {
  $tmp = New-TemporaryFile
  Set-Content -Path $tmp -Value $body -Encoding ascii
  curl.exe -sN -X POST "$Url/v1/chat/completions" `
    -H "Content-Type: application/json" `
    --data-binary "@$tmp"
  Remove-Item $tmp -Force
} else {
  $resp = Invoke-RestMethod -Uri "$Url/v1/chat/completions" `
    -Method POST -ContentType "application/json" -Body $body -TimeoutSec 600
  Write-Host "`n[reply]" -ForegroundColor Green
  Write-Host $resp.choices[0].message.content
  Write-Host "`n[usage]" -ForegroundColor Cyan
  $resp.usage | Format-List
}
