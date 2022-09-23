source ~/Programs/zsh-git-prompt/zshrc.sh
export PATH=/home/geraldo/Dropbox/Código/Enviroment/Scripts/Menus:$PATH
#export EDITOR=nvim
export EDITOR=vim
stty -ixon

ranger() {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}
# Luke's config for the Zoomer Shell

parse_git_branch() {
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' #|  grep -q ^ || echo " ..."
}

# Enable colors and change prompt: 
autoload -U colors && colors
NEWLINE=$'\n'

OPEN="%B%{$fg[red]%}["
NAME="%{$fg[yellow]%}%n"
AT="%{$fg[magenta]%}@"
MYHOST="%{$fg[green]%}%M "
FILEPATH="%{$fg[blue]%} in %(3~|.../%2~|%~)"
CLOSE="%{$fg[red]%}]"
#GIT="%{$fg[green]%} on $(git_super_status) "
GIT="%{$fg[green]%} on "
#TIME="%{$fg[blue]%}at [%*]"
TIME=""

PROMPT_INPUT="%{$reset_color%}${NEWLINE}%{$fg[blue]%}%B%  >> %b$ "
PROMPT_COMMAND="%{$reset_color%}${NEWLINE}%{$fg[yellow]%} >> %b$ "

PROMPT_BODY="$OPEN$NAME$AT$MYHOST$FILEPATH$CLOSE$GIT"
#PROMPT_BODY="$OPEN$NAME$AT$MYHOST$FILEPATH$CLOSE"
#PS1="$PROMPT_BODY%{$fg[green]%} on$(parse_git_branch) $TIME$PROMPT_INPUT"
#PS1="$PROMPT_BODY$(git_super_status)$PROMPT_INPUT"
function precmd {
      PS1="$PROMPT_BODY$(git_super_status) $TIME$PROMPT_INPUT"
    }
PS1="$PROMPT_BODY$(git_super_status) $TIME$PROMPT_INPUT"

#PS1="%b%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M%{$fg[magenta]%}%~%{$fg[red]%}]%{$fg[green]%}$(parse_git_branch)%{$fg[blue]%} [%T]%{$reset_color%}${NEWLINE}%{$fg[blue]%} >> %b$ "


# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
DISABLE_AUTO_TITLE="true"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

setopt  autocd autopushd 
# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
#_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

#PROMPT_COMMAND='echo -e "\e[?16;0;200c"'
# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[5 q'
      #PS1="$PROMPT_BODY%{$fg[green]%} on$(parse_git_branch) $TIME$PROMPT_COMMAND"
      PS1="$PROMPT_BODY$(git_super_status) $TIME$PROMPT_COMMAND"
      #PS1="$PROMPT_BODY$PROMPT_COMMAND"
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[1 q'
      #PS1="$PROMPT_BODY%{$fg[green]%} on$(parse_git_branch) $TIME$PROMPT_INPUT"
      PS1="$PROMPT_BODY$(git_super_status) $TIME$PROMPT_INPUT"
      #PS1="$PROMPT_BODY$PROMPT_INPUT"
  fi
  zle reset-prompt
}
zle -N zle-keymap-select

# zle-line-init() {
#    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
#    echo -ne "\e[5 q"
#}
#zle -N zle-line-init
#echo -ne "\e[1 q" # Use beam shape cursor on startup.
#preexec() { echo -ne "\e[1 q" ;} # Use beam shape cursor for each new prompt.




# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

# my-accept-line () {
#    zle accept-line
#    zle reset-prompt
#}
#zle -N my-accept-line
#bindkey '^M' my-accept-line

addAll(){
  git add *
  git status
  zle accept-line
}


showStatus (){
  echo '\n--------'
  echo Branches:
  git branch
  echo Status:
  echo '--------\n'
  git status
  zle accept-line
}

zle -N showStatus
bindkey '^b' showStatus
zle -N addAll
bindkey '^A' addAll



# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

alias r='ranger'
alias ls='ls --color=auto'
#alias vim='nvim'


# Load zsh-syntax-highlighting; should be last.
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

source ~/Programs/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/Programs/zsh-autosuggestions/zsh-autosuggestions.zsh
