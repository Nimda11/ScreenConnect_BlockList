param(
    [Parameter(Mandatory = $true)]
    [string]$DatabasePath,

    [string]$AllowListPath = $null,

    [int]$QueryDays = 28,

    [int]$BanAttempts = 10,

    [string]$BlockListPath = "blocklist.txt",

    [switch]$EnableDebug
)

function Main {
    # Check if the SQLite database file exists
    if (-not (Test-Path $DatabasePath)) {
        Write-Error "Database path does not exist: $DatabasePath"
        exit
    }

    # Initialize debug log if enabled
    $debugLog = @()
    if ($EnableDebug) {
        $debugLog += "Debug mode enabled"
        $debugLog += "DatabasePath: $DatabasePath"
        $debugLog += "QueryDays: $QueryDays"
        $debugLog += "BanAttempts: $BanAttempts"
        $debugLog += "BlockListPath: $BlockListPath"
        if ($AllowListPath) {
            $debugLog += "AllowListPath: $AllowListPath"
        }
    }

    # Construct and run the query
    $query = "SELECT hex(NetworkAddress) as Address FROM SecurityEvent WHERE OperationResult = 2 AND datetime(Time) >= datetime('now', '-$QueryDays days') GROUP BY Address HAVING COUNT(*) >= $BanAttempts;"
    $debugLog += "Running query: $query"
    $results = & sqlite3.exe $DatabasePath $query

    if (-not $results) {
        $debugLog += "No results returned from the database."
        Write-DebugLog -DebugLog $debugLog -EnableDebug $EnableDebug
        exit
    }

    # Convert hex results to IP addresses
    $ipAddresses = $results | ForEach-Object {
        [System.Net.IPAddress]::Parse(([Convert]::ToInt64($_, 16)).ToString()).IPAddressToString
    }

    # Filter out allowlisted addresses if an allowlist is provided
    if ($AllowListPath -and (Test-Path $AllowListPath)) {
        $allowList = Get-Content $AllowListPath
        $ipAddresses = $ipAddresses | Where-Object { $_ -notin $allowList }
    }

    # Limit to the most recent 4000 addresses if necessary
    $ipAddresses = $ipAddresses | Select-Object -Last 4000

    # Write the blocklist to file
    $ipAddresses | Out-File $BlockListPath
    $debugLog += "Blocklist updated with $($ipAddresses.Count) IP addresses."

    # Write debug log if enabled
    Write-DebugLog -DebugLog $debugLog -EnableDebug $EnableDebug
}

function Write-DebugLog {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$DebugLog,

        [Parameter(Mandatory = $true)]
        [bool]$EnableDebug
    )

    if ($EnableDebug) {
        $debugLog | Out-File "debug.txt"
        $debugLog | ForEach-Object { Write-Host $_ }
    }
}

Main
