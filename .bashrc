[ -z "$PS1" ] && return

HISTCONTROL=ignoredups:ignorespace

shopt -s histappend

HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Update and clean Ubuntu system packages
updateUbuntu() {
  echo "🔄 Updating package list..."
  sudo apt update || return 1

  echo "⬆️ Upgrading packages..."
  sudo apt upgrade -y || return 1

  echo "🚀 Running full upgrade..."
  sudo apt full-upgrade -y || return 1

  echo "🧹 Removing unused packages..."
  sudo apt autoremove -y || return 1

  echo "🧼 Cleaning package cache..."
  sudo apt clean

  echo "✅ System update complete!"

  # Bash-compatible reboot prompt
  read -p "🔁 Reboot now? (y/N): " REBOOT
  if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    sudo reboot
  fi
}

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias rb='~/scripts/restart_blog.sh'
alias uup='updateUbuntu'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
