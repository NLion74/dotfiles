# Load Zinit
source ~/.zsh/zinit/zinit.zsh

# Syntax highlighting
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

# Autosuggestions
zinit ice wait'0' lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# Auto Completions
zinit ice wait lucid
zinit light zsh-users/zsh-completions

# Aliases
alias la='ls -a'

# History config
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY           # Don’t overwrite history, append to it
setopt SHARE_HISTORY            # Share history across all sessions
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first
setopt HIST_IGNORE_DUPS         # Don’t record duplicates
setopt HIST_IGNORE_ALL_DUPS     # Remove old duplicate commands
setopt HIST_FIND_NO_DUPS        # Don’t show dupes when searching
setopt HIST_REDUCE_BLANKS       # Remove superfluous spaces
setopt HIST_VERIFY              # Don't execute until you hit enter again
setopt INC_APPEND_HISTORY       # Write to history immediately
setopt EXTENDED_HISTORY         # Add timestamps

export HISTTIMEFORMAT="%F %T "


# Fix 'Home' (Pos1) key to go to the start of the line
bindkey "^[[H" beginning-of-line  # for xterm, iTerm, and similar terminals
bindkey "^[[1~" beginning-of-line # for some other terminals
# Make the Del key delete characters after the cursor (forward delete)
bindkey "^[[3~" delete-char

# Starlight Prompt
eval "$(starship init zsh)"
