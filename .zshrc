# looks and colours
autoload -U colors
colors
export PS1=%{$fg[$NCOLOR]%}%B%n%b%{$reset_color%}:%{$fg[blue]%}%B%c/%b%{$reset_color%}

# ls colours
if [ "x$(uname)" = 'xLinux' ]; then
    alias ls='ls --color=auto'
else
    export LSCOLORS=GxFxCxDxBxegedabagaced
    alias ls='ls -G'
fi
alias ll='ls -lh'

# Completion
autoload -U compinit
compinit
setopt hash_list_all
setopt completealiases
setopt complete_in_word
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+l:|=* r:|=*' # ignore case and complete in middle of word

# history
HISTFILE=~/.zsh_history         # where to store history
HISTSIZE=1000                   # long history
SAVEHIST=1000                   # long history
setopt append_history           # append
setopt hist_ignore_all_dups     # no duplicate
unsetopt hist_ignore_space      # ignore space prefixed commands
setopt hist_reduce_blanks       # trim blanks
setopt hist_verify              # show before executing history commands
setopt inc_append_history       # add commands as they are typed, don't wait until shell exit 
setopt share_history            # share hist between sessions
bindkey '^R' history-incremental-pattern-search-backward # What's ZSH's default?

# keyboard
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line

# various
setopt auto_cd                  # if command is a path, cd into it
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks
setopt correct                  # try to correct spelling of commands
unsetopt rm_star_silent         # ask for confirmation for `rm *' or `rm path/*'

# Default editor
export EDITOR=$(which vim)
export VISUAL=$(which vim)

# SSH socket symlink for nested tmux operaion
if test -S $SSH_AUTH_SOCK; then
    if echo "$SSH_AUTH_SOCK" | grep -Eq '/tmp/ssh-[a-zA-Z0-9]+/agent.[0-9]+'; then
        ln -sf "$SSH_AUTH_SOCK" "/tmp/ssh-agent-$USER-screen"
        export SSH_AUTH_SOCK="/tmp/ssh-agent-$USER-screen"
    fi
fi
