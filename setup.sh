#!/usr/bin/env bash
set -e

# TODO(Vishal): Configure via commandline args
install_build_essential=true
install_tmux=true
install_powerline_font=false
install_nvim=false
install_fzf=false
install_bashrc=false
install_docker=false
install_vscode=false

SELF=$(basename $0)
SELFDIR=$(readlink -f $(dirname $0))
CURRENT_DIR=$(pwd)

if [ -d "$HOME/Downloads" ]; then
  DOWNLOAD_DIR=$HOME/Downloads
else
  DOWNLOAD_DIR=$SELFDIR/Downloads
  mkdir -p $DOWNLOAD_DIR
fi

cd $DOWNLOAD_DIR

if [ "$install_build_essential" = true ]; then
  sudo apt-get install build-essential cmake git ninja-build ccache curl \
  libeigen3-dev
  echo "Installed build essential packages"
fi

# Install and setup tmux
if [ "$install_tmux" = true ]; then
  sudo apt-get install tmux
  stow -v -d $SELFDIR -t $HOME tmux
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
  echo "tmux setup done."

  if [ "$install_powerline_font" = true ]; then
    curl -sL -o $DOWNLOAD_DIR/FuraMono-Bold-Powerline.otf https://github.com/powerline/fonts/blob/master/FiraMono/FuraMono-Bold%20Powerline.otf
    curl -sL -o $DOWNLOAD_DIR/FuraMono-Medium-Powerline.otf https://github.com/powerline/fonts/blob/master/FiraMono/FuraMono-Medium%20Powerline.otf
    curl -sL -o $DOWNLOAD_DIR/FuraMono-Regular-Powerline.otf https://github.com/powerline/fonts/blob/master/FiraMono/FuraMono-Regular%20Powerline.otf

    local_font_dir=$HOME/.local/share/fonts
    mkdir -p $local_font_dir
    mv $DOWNLOAD_DIR/FuraMono*.otf $local_font_dir
    fc-cache -f $local_font_dir
    echo "Downloaded font and updated font cache."
  fi
fi

# Install and setup nvim. Disabling temporarily till an issue with Focal is
# figured out
if [ "$install_nvim" = true ]; then
  sudo apt-get install neovim
  stow -v -d $SELFDIR -t $HOME nvim
  nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1
  echo "nvim setup done."
fi

# Install and setup fzf
if [ "$install_fzf" = true ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/fzf
  ${HOME}/fzf/install --all
  echo "fzf setup done."
fi

# Install and setup bashrc
if [ "$install_bashrc" = true ]; then
  grep -qF -- .bashrc.extra $HOME/.bashrc || echo "source $SELFDIR/bash/.bashrc.extra" >> $HOME/.bashrc
  echo ".bashrc setup done."
fi

# Install and setup docker
if [ "$install_docker" = true ]; then
  echo "Downloading and installing Docker"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  sleep 1
  sudo usermod -aG docker $USER
  newgrp docker
  echo "docker install and setup done."
fi

# Install VSCode
if [ "$install_vscode" = true ]; then
  curl -sL -o vscode-latest.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
  sudo apt install ./vscode-latest.deb
  echo "vscode install done."
fi




