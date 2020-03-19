[[ -f $HOME/.environment.sh ]] && source $HOME/.environment.sh

WORDCHARS=${WORDCHARS//\/}
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=$HOME/.zsh_history
setopt appendhistory extendedglob nomatch \
       INTERACTIVE_COMMENTS MAGIC_EQUAL_SUBST \
       LIST_TYPES NUMERIC_GLOB_SORT \
       HIST_IGNORE_ALL_DUPS COMPLETE_IN_WORD
unsetopt NOMATCH AUTO_PARAM_KEYS AUTO_REMOVE_SLASH FLOW_CONTROL

# Use emacs mode, but be able to chage to vi-cmd-mode
bindkey -e
bindkey "^[" vi-cmd-mode
zle -N zle-keymap-select color-cursor
function color-cursor() {
    if [ $KEYMAP = "vicmd" ]; then 
        echo -n "\e]12;white\a";
    else
        echo -n "\e]12;orange\a";
    fi
}

export EDITOR=nvim
export LESS=-i
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Keybindings
bindkey "^[Od" backward-word
bindkey "^[Oc" forward-word
bindkey "^[Oa" beginning-of-line
bindkey "^[Ob" end-of-line
# Sometimes I press shift-Tab by mistake and it changes to vi mode.
# This deactivates it.
bindkey "^[[Z" expand-or-complete
bindkey -M vicmd v edit-command-line
#
# In order to have the esc-key to react inmediately
# This can have side-effects, as it is not esc-key specific, but so far
# I haven't found any.
export KEYTIMEOUT=1

fpath=(~/.zshcompletions $fpath)                                                                                              
# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _match _prefix _files
zstyle ':completion:*' insert-unambiguous false
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' max-errors 1
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

autoload -Uz compinit
compinit
# End of lines added by compinstall

if [[ $TERM == "xterm-kitty" ]] && type kitty > /dev/null; then
    # Completion for kitty
    kitty + complete setup zsh | source /dev/stdin
    alias icat="kitty +kitten icat"
    alias kdiff="kitty +kitten diff"
fi

autoload -U zmv
autoload edit-command-line
zle -N edit-command-line

# Aliases
alias ls="ls --color=auto -F"
alias ll="ls -l"
alias sl=ls
alias mdkir=mkdir
alias topc="top -b -n 1 | head -15"
alias cal="ncal -bM"
alias vi=nvim
alias vim=nvim
alias vimwiki="vim +VimwikiIndex"
alias view="nvim -R '+set noma'"
alias vimdiff="nvim -d"
function vim-parallel() {
    vim "+:autocmd BufRead * set scrollbind | set cursorbind" "+:e $1" "+:rightb vsp $2"
}
function kspwd() {
    print -rDn $PWD/$1 | xclip -i
}
alias bib="bibsearch"
# okular (or KDE programms in general) write a lot to the terminal
function okular() {
    /usr/bin/okular $* 2>/dev/null
}

# Prompt
case $TERM in
    xterm-*|rxvt*|screen*)
        # (Re-)define the promptBeginColor in the local part of the config
        promptBeginColor='%{\e[0;36m%}'
        promptEndColor='%{\e[0m%}'
        promptMachine=%m
        precmd () {
            print -Pn "\e]0;$promptMachine: %~\a"; # Set the title
            local pwdSize=$((${COLUMNS} - ${#${(%):-[%j] %m:}} - 1))
            PROMPT="$(print '\n'$promptBeginColor$promptMachine':[%j] %'$pwdSize'<...<%~%<<\n%(!.#.$)'$promptEndColor) "
            # Ensure we have an orange cursor
            echo -n "\e]12;orange\a";
        }
        preexec () {
                #print -Pn "\e]0;%m: $2\a"
            myLocalHistory $1
        }
        ;;
    *)
        preexec () {
                myLocalHistory $1
        }
        ;;
esac

# Disable C-s to stop terminal output
stty -ixon -ixoff

function hdgrep()
{
    tr -d '\0' < .history | grep $* 2>/dev/null
    LAST_HGREP_SEARCH=$*
}

function hnrep()
{
    tr -d '\0' < .history | grep "$*" 2>/dev/null | cut -f 2- -d ' ' | nl
    LAST_HGREP_SEARCH=$*
}

function hgrep()
{
    tr -d '\0' < .history | grep "$*" 2>/dev/null | cut -f 2- -d ' '
    LAST_HGREP_SEARCH=$*
}

function localHistory()
{
  tail .history 2>/dev/null
}

function hks()
{
  local commandNr
  local hgrepOutput
  # Fuzzy detection if the last argument is a position
  if [[ $argv[-1] =~ '^[0-9]*$' ]]; then
      commandNr=$argv[-1]
      argv[-1]=()
  fi
  if [[ ${#argv[@]} == 0 ]]; then
      searchTerms=$LAST_HGREP_SEARCH
  else
      searchTerms=$*
      LAST_HGREP_SEARCH=$searchTerms
  fi
  hgrepOutput=("${(f)$(tr -d '\0' < .history | grep "$searchTerms" 2>/dev/null | cut -f 2- -d ' ')}")
  commandNr=${commandNr:--1}
  echo ${hgrepOutput[${commandNr}]}
  xclip -i <<< ${hgrepOutput[${commandNr}]}
}

# main local history function:
# - only write history if current directory belongs to me
# - only write history if useHistory filter says "1"
# - add timestamp and historyline
doNotLogCommands='^ls( |$)|^ll( |$)|^cd( |$)|^localHistory( |$)|^hgrep( |$)|^hdgrep( |$)|^hks( |$)|^bg( |$)|^fg( |$)|^less( |$)|^kspwd( |$)'
function myLocalHistory()
{
  if [[ -O $PWD ]] ; then
    HISTORYLINE="$@"
    if ! [[ $HISTORYLINE =~ $doNotLogCommands ]] ; then
      (date +%F.%H-%M-%S | tr -d '\n' ; print -r " $HISTORYLINE") >>.history
    fi
  fi
}

function mkcdir()
{
    mkdir $1
    cd $1
}

autoload -U url-quote-magic
zle -N self-insert url-quote-magic

zmodload zsh/mathfunc

type fortune > /dev/null && fortune

if [[ -e /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[default]='none'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
    ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=green'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
    ZSH_HIGHLIGHT_STYLES[function]='fg=green'
    ZSH_HIGHLIGHT_STYLES[command]='fg=green'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=green'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='none'
    ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=green'
    ZSH_HIGHLIGHT_STYLES[path]='none'
    ZSH_HIGHLIGHT_STYLES[path_prefix]='none'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='none'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='none'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='none'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[assign]='none'
    ZSH_HIGHLIGHT_STYLES[redirection]='none'
    ZSH_HIGHLIGHT_STYLES[comment]='fg=yellow,bold'
fi
 
