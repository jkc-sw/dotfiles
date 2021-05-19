#!/usr/bin/pwsh

# Set the VI mode
Set-PSReadlineOption -EditMode vi
Invoke-Expression (& starship init powershell)

