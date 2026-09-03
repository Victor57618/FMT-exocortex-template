param(
    [Parameter(Position = 0)]
    [string]$Protocol,

    [Parameter(Position = 1)]
    [string]$Hook
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Protocol) -or [string]::IsNullOrWhiteSpace($Hook)) {
    [Console]::Error.WriteLine('Usage: load-extensions.ps1 <protocol> <hook>')
    [Console]::Error.WriteLine('Example: load-extensions.ps1 protocol-close checks')
    exit 2
}

function Resolve-IweWorkspace {
    $candidateNames = @('IWE_WORKSPACE', 'WORKSPACE_DIR', 'IWE_ROOT', 'IWE')

    foreach ($name in $candidateNames) {
        $candidate = [Environment]::GetEnvironmentVariable($name)
        if (-not [string]::IsNullOrWhiteSpace($candidate) -and
            (Test-Path -LiteralPath (Join-Path $candidate 'extensions') -PathType Container)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $fallback = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
    if (Test-Path -LiteralPath (Join-Path $fallback 'extensions') -PathType Container) {
        return $fallback
    }

    return $null
}

$workspace = Resolve-IweWorkspace
if ([string]::IsNullOrWhiteSpace($workspace)) {
    exit 1
}

$extensionsDirectory = Join-Path $workspace 'extensions'
$escapedProtocol = [Regex]::Escape($Protocol)
$escapedHook = [Regex]::Escape($Hook)
$namePattern = "^$escapedProtocol\.$escapedHook(?:\..+)?\.md$"

$files = @(
    Get-ChildItem -LiteralPath $extensionsDirectory -File |
        Where-Object { $_.Name -match $namePattern } |
        Sort-Object -Property FullName
)

if ($files.Count -eq 0) {
    exit 1
}

$files | ForEach-Object { $_.FullName }
exit 0
