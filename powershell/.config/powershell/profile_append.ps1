#!/usr/bin/pwsh

# Getting brew
if (Test-Path "/home/linuxbrew/.linuxbrew/bin/brew") {
    (& /home/linuxbrew/.linuxbrew/bin/brew shellenv) | Out-String | Invoke-Expression
}

# Set the VI mode
Set-PSReadlineOption -EditMode vi -PredictionSource History
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --cmd 'c' --hook $hook powershell) -join "`n"
})
# Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# Source it
function sdev() {
    #region conda initialize
    # !! Contents within this block are managed by 'conda init' !!
    $CondaExe = 'conda'
    $CondaInfo = Get-Command conda -ErrorAction SilentlyContinue
    if (-not ($CondaInfo) -or ($CondaInfo.CommandType -eq 'Application')) {
        $CondaExe = "~/miniconda3/bin/conda"
        (& $CondaExe "shell.powershell" "hook") | Out-String | Where-Object {$_} | Invoke-Expression
    }
    # (& "~/miniconda3/bin/conda" "shell.powershell" "hook") | Out-String | Invoke-Expression
    #endregion
}

Set-Alias -Name ai -Value yazi

Set-Alias -Name ag -Value lazygit

Set-Alias -Name e -Value ./r.ps1

Set-Alias -Name n -Value nvim

function eo() {
    <#
    .SYNOPSIS
    Quickly start work journal
    #>
    [CmdletBinding()]
    Param(
        # Day offset
        [Parameter(HelpMessage = 'Day offset')]
        [String]
        $NoteDate
    )
    ./r.ps1 -Work -NoteDate $NoteDate
}

function u() {
    <#
    .SYNOPSIS
    Quickly start personal journal
    #>
    [CmdletBinding()]
    Param(
        # Date of the note
        [Parameter(HelpMessage = 'Date of the note')]
        [String]
        $NoteDate
    )
    ./r.ps1 -Personal -NoteDate $NoteDate
}

function de() {
    (Get-Command $args[0]).Definition
}

