#!/usr/bin/pwsh

# Set the VI mode
Set-PSReadlineOption -EditMode vi -PredictionSource History
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --cmd 'c' --hook $hook powershell) -join "`n"
})
Invoke-Expression (& starship init powershell)
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# Source it
function sdev() {
    #region conda initialize
    # !! Contents within this block are managed by 'conda init' !!
    $CondaExe = 'conda'
    if (-not (Get-Command conda -ErrorAction SilentlyContinue)) {
        $CondaExe = "~/miniconda3/bin/conda"
    }
    (& $CondaExe "shell.powershell" "hook") | Out-String | Invoke-Expression
    # (& "~/miniconda3/bin/conda" "shell.powershell" "hook") | Out-String | Invoke-Expression
    #endregion
}
