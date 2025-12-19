<#
.SYNOPSIS
    Interacts with Google Gemini AI via direct prompt, pipeline, or interactive session.

.DESCRIPTION
    A robust wrapper for the Gemini API. Supports JSON configuration, pipeline input, 
    and maintaining conversation history in interactive mode.

.PARAMETER Prompt
    The text prompt to send to the model. Can be passed via pipeline.

.PARAMETER Interactive
    Switch to start a persistent chat session in the console.

.PARAMETER ConfigPath
    Path to a JSON config file. Defaults to 'config.json' in the script's directory.

.PARAMETER ApiKey
    Overrides the API key in the config file or environment.

.PARAMETER Model
    Overrides the Model in the config file. Defaults to 'gemini-1.5-flash'.

.EXAMPLE
    "Explain recursion" | Invoke-Gemini
#>

[CmdletBinding(DefaultParameterSetName = "Standard")]
param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = "Standard")]
    [string]$Prompt,

    [Parameter(Mandatory = $true, ParameterSetName = "InteractiveMode")]
    [switch]$Interactive,

    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "$PSScriptRoot\config.json",

    [Parameter(Mandatory = $false)]
    [string]$ApiKey,

    [Parameter(Mandatory = $false)]
    [string]$Model
)

begin {
    Write-Verbose "Initializing Gemini Configuration..."
    
    # 1. Load Config File if exists
    $FileConfig = if (Test-Path $ConfigPath) {
        Get-Content $ConfigPath | ConvertFrom-Json
    } else { $null }

    # 2. Logic: Parameter > Config File > Environment Variable > Default
    $FinalApiKey = if ($ApiKey) { $ApiKey } 
                    elseif ($FileConfig.ApiKey) { $FileConfig.ApiKey } 
                    else { $env:GEMINI_API_KEY }

    $FinalModel = if ($Model) { $Model } 
                    elseif ($FileConfig.Model) { $FileConfig.Model } 
                    else { "gemini-2.5-flash" }

    if ([string]::IsNullOrWhiteSpace($FinalApiKey)) {
        throw "API Key not found. Provide via -ApiKey, config.json, or `$env:GEMINI_API_KEY."
    }

    # Internal helper for API calls
    function Execute-ApiCall {
        param([array]$Messages)
        $Body = @{ contents = $Messages } | ConvertTo-Json -Depth 10

        $Headers = @{
            "x-goog-api-key" = $FinalApiKey
        }

        $Uri = "https://generativelanguage.googleapis.com/v1beta/models/${FinalModel}:generateContent"
        
        try {
            Write-Verbose "URI: $Uri"
            $Res = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -Headers $Headers -ContentType "application/json" -ErrorAction Stop
            return $Res.candidates[0].content.parts[0].text
        } catch {
            Write-Error "API Request Failed: $($_.Exception.Message)"
            return $null
        }
    }
}

process {
    # Handle Pipeline/Standard Input
    if ($PSCmdlet.ParameterSetName -eq "Standard") {
        Write-Verbose "Processing single prompt for model: $FinalModel"
        $Payload = @(@{ role = "user"; parts = @(@{ text = $Prompt }) })
        $Response = Execute-ApiCall -Messages $Payload
        if ($Response) { $Response }
    }
}

end {
    # Handle Interactive Mode
    if ($Interactive) {
        Write-Information "Starting Interactive Session (Model: $FinalModel)"
        $ChatHistory = @()
        # Write-Host "--- Gemini Interactive (Type 'exit' to quit) ---" -ForegroundColor Cyan
        Clear-Host
        $modelMessage = "Using Model - $FinalModel"
        $modelPadding = " " * ((50 - $modelMessage.Length) / 2)
        Write-Host "=============== Gemini Interactive ===============" -ForegroundColor Cyan
        Write-Host "$($modelPadding+$modelMessage+$modelPadding)" -ForegroundColor Cyan
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "     Type 'exit', 'quit', or 'cls' (to clear)." -ForegroundColor Gray
        Write-Host ""

        while ($true) {
            $UserInput = Read-Host "`nYou"
            if ($UserInput -in "exit", "quit") { break }
            if ($UserInput -eq 'cls') {
                $ChatHistory = @()
                Clear-Host
                Write-Host "History Cleared" -ForegroundColor Yellow
                continue
            }
            if ([string]::IsNullOrWhiteSpace($UserInput)) { continue }

            $ChatHistory += @{ role = "user"; parts = @(@{ text = $UserInput }) }
            
            Write-Host "Gemini: ..." -NoNewline -ForegroundColor Green
            $Response = Execute-ApiCall -Messages $ChatHistory
            
            if ($Response) {
                Write-Host "`rGemini: $Response" -ForegroundColor Green
                $ChatHistory += @{ role = "model"; parts = @(@{ text = $Response }) }
            } else {
                # Remove failed turn to keep history valid
                $ChatHistory = $ChatHistory[0..($ChatHistory.Count - 2)]
            }
        }
    }
}
