#!/usr/bin/env bash
set -e

SELF=$(basename $0)
SELFDIR=$(readlink -f $(dirname $0))


# Install and setup tmux
#stow -v -d $SELFDIR -t $HOME tmux
#git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
#echo "tmux setup done"

# Install and setup nvim. Disabling temporarily till an issue with Focal is
# figured out
#stow -v -d $SELFDIR -t $HOME nvim
#nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1
#echo "nvim setup done"

# Install and setup fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/fzf
${HOME}/fzf/install --all
echo "fzf setup done"

# Install and setup bashrc
grep -qF -- .bashrc.extra $HOME/.bashrc || echo "source $SELFDIR/bash/.bashrc.extra" >> $HOME/.bashrc
echo ".bashrc setup done"
