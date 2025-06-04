param (
    [string]$q,
    [string]$t,
    [string]$m,
    [string]$c
)

$jsonPath = Join-Path $PSScriptRoot "toolmap.json"

# Create empty structure
$data = @{
    metadata = @{}
    commands = @{}
}

# Load existing JSON if available
if (Test-Path $jsonPath) {
    $existing = Get-Content $jsonPath -Raw | ConvertFrom-Json
    foreach ($key in $existing.PSObject.Properties.Name) {
        $value = $existing.$key
        if ($key -eq "metadata" -or $key -eq "commands") {
            $data[$key] = @{}
            foreach ($tool in $value.PSObject.Properties.Name) {
                $arr = @()
                foreach ($item in $value.$tool) { $arr += $item }
                $data[$key][$tool] = $arr
            }
        }
    }
}

# ------------------------
# QUERY MODE
# ------------------------
if ($q) {
    $input = $q.ToLower().Trim()
    $matchedTools = @{}

    foreach ($tool in $data['metadata'].Keys) {
        foreach ($keyword in $data['metadata'][$tool]) {
            $keywordLower = $keyword.ToLower()
            $score = 0

            if ($keywordLower -eq $input) {
                $score = 100
            } elseif ($keywordLower -like "*$input*" -or $input -like "*$keywordLower*") {
                $score = 80
            } elseif ($keywordLower -replace '\s','' -like "*$($input -replace '\s','')*") {
                $score = 70
            } elseif ($tool -eq $input) {
                $score = 100
            } elseif ($tool -like "*$input*" -or $input -like "*$tool*") {
                $score = 70
            }

            if ($score -ge 70) {
                if (-not $matchedTools.ContainsKey($tool) -or $matchedTools[$tool] -lt $score) {
                    $matchedTools[$tool] = $score
                }
            }
        }
    }

    if ($matchedTools.Count -eq 0) {
        Write-Host "No match found for input: $input"
        exit 1
    }

    $sortedMatches = $matchedTools.GetEnumerator() | Sort-Object Value -Descending

    foreach ($match in $sortedMatches) {
        $tool = $match.Key
        Write-Host ""
        Write-Host "Matched Tool: $tool"
        Write-Host "------------------"
        $data['commands'][$tool]
    }

    exit 0
}

# Add/Update Tool
if ($t) {
    if (-not $data['metadata'].ContainsKey($t)) {
        $data['metadata'][$t] = @()
        Write-Host "Created new metadata entry for: $t"
    }

    if (-not $data['commands'].ContainsKey($t)) {
        $data['commands'][$t] = @()
        Write-Host "Created new commands entry for: $t"
    }

    if ($m) {
        if (-not ($data['metadata'][$t] -contains $m)) {
            $data['metadata'][$t] += ,$m
            Write-Host "Added metadata: $m"
        } else {
            Write-Host "Metadata already exists: $m"
        }
    }

    if ($c) {
        if (-not ($data['commands'][$t] -contains $c)) {
            $data['commands'][$t] += ,$c
            Write-Host "Added command: $c"
        } else {
            Write-Host "Command already exists: $c"
        }
    }

    # Save JSON
    $data | ConvertTo-Json -Depth 5 | Set-Content $jsonPath -Encoding UTF8
    Write-Host "toolmap.json updated."
    exit 0
}

# Check for -list argument
if ($args -contains "-l") {
    $toolMapPath = Join-Path $PSScriptRoot "toolmap.json"
    if (Test-Path $toolMapPath) {
        try {
            $toolMap = Get-Content $toolMapPath -Raw | ConvertFrom-Json
            if ($toolMap.metadata.PSObject.Properties.Count -eq 0) {
                Write-Host "No tools found in the 'metadata' section of toolmap.json."
            } else {
                Write-Host "Available tools:"
                $toolMap.metadata.PSObject.Properties.Name | Sort-Object | ForEach-Object {
                    Write-Host "- $_"
                }
            }
        } catch {
            Write-Error "Failed to parse toolmap.json: $_"
        }
    } else {
        Write-Error "toolmap.json not found in the script directory."
    }
    exit
}



Write-Host "`nUsage:"
Write-Host "  toolhelper -q <query>"
Write-Host "  toolhelper -t <tool> [-m <metadata>] [-c <command>]"
Write-Host "  toolhelper -l"
exit 1
