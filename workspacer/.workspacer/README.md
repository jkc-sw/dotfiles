# Install

## Pre-requisites

- scoop
- git (`scoop install git`)
- workspacer (`scoop bucket add extras && scoop install workspacer`)
- conda (`scoop install miniconda3 && conda config --set auto_activate_base False`)
- dploy (`conda activate base && pip install dploy`)

## Install

Clone the repo with

```powershell
mkdir $ENV:USERPROFILE/repos
cd repos
git clone https://github.com/jkc-sw/dotfiles
```

Then open a powershell window with admin right

```powersherr
cd $ENV:USERPROFILE/repos/dotfiles
dploy stow workspacer "$ENV:USERPROFILE"
```
