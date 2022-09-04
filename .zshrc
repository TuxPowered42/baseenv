# PATH
if [ $(uname) = 'Darwin' ]; then
  PATH=/opt/homebrew/Cellar/python@3.9/3.9.10/Frameworks/Python.framework/Versions/3.9/bin:$PATH
  PATH=/opt/homebrew/bin:$PATH
  PATH=/opt/homebrew/sbin:$PATH
  PATH=/usr/local/bin:/usr/local/sbin:$PATH # Override BSD commands
fi
export GOPATH=$HOME/workspace/go
PATH=$GOPATH:$PATH
export PATH

# SSH
if [ $(uname) = 'Darwin' ]; then
    # On MacOS there are 2 ssh-agents started as system services.
    # One for private use and the other one for the corporate YubiKey.
    export SSH_AUTH_SOCK="/opt/homebrew/var/run/yubikey-agent.sock" # The default socket is corporate
    alias ssh-add_tuxpowered="SSH_AUTH_SOCK=/private/tmp/ssh-agent-tuxpowered ssh-add"
else
    # On other systems start the ssh-agent manually
    export SSH_AUTH_SOCK="/tmp/ssh-agent-tuxpowered"
    alias ssh-add_tuxpowered="ssh-add"
    if ! pgrep ssh-agent > /dev/null; then
        ssh-agent -a $SSH_AUTH_SOCK > /dev/null
    fi
fi

setopt extendedglob
ssh-add_tuxpowered -l > /tmp/added_keys
for KEY in .ssh/id_tuxpowered^*pub; do
    if ! grep -q $(cut -d ' ' -f 3 "$KEY.pub") /tmp/added_keys; then
        ssh-add_tuxpowered $KEY
    fi
done

# looks and colours
autoload -U colors
colors
export PS1=%{$fg[$NCOLOR]%}%B"[%*] %m"%b%{$reset_color%}" "%{$fg[blue]%}%B%c/%b%{$reset_color%}" # "

# ls colours
if [ "x$(uname)" = 'xLinux' ]; then
    alias ls='ls --color=auto'
else
    export LSCOLORS=GxFxCxDxBxegedabagaced
    alias ls='ls -G'
fi

# Completion
autoload -U compinit
compinit
setopt hash_list_all
setopt completealiases
setopt complete_in_word
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+l:|=* r:|=*' # ignore case and complete in middle of word

## History wrapper
function omz_history {
  local clear list
  zparseopts -E c=clear l=list

  if [[ -n "$clear" ]]; then
    # if -c provided, clobber the history file
    echo -n >| "$HISTFILE"
    echo >&2 History file deleted. Reload the session to see its effects.
  elif [[ -n "$list" ]]; then
    # if -l provided, run as if calling `fc' directly
    builtin fc "$@"
  else
    # unless a number is provided, show all history events (starting from 1)
    [[ ${@[-1]-} = *[0-9]* ]] && builtin fc -l "$@" || builtin fc -l "$@" 1
  fi
}

## History file configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data

# keyboard
bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[3~"   delete-char
bindkey  "^[[4~"   end-of-line

# various
setopt auto_cd                  # if command is a path, cd into it
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks
setopt correct                  # try to correct spelling of commands
unsetopt rm_star_silent         # ask for confirmation for `rm *' or `rm path/*'

# Default editor
export EDITOR=$(which vim)
export VISUAL=$(which vim)

alias history='omz_history -i'
alias ll='ls -lh'
alias ntssh="TERM=xterm ssh"
alias ssh-zarya="ssh  -D 42669 -A vegeta@zarya.tuxpowered.net"
alias flush-dns="sudo killall -HUP mDNSResponder"

ZSHRC_LOCAL=~/.zshrc_local
if [ -f $ZSHRC_LOCAL ]; then
  . $ZSHRC_LOCAL
fi
