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

# Fix 'Home' (Pos1) key to go to the start of the line
bindkey "^[[H" beginning-of-line  # for xterm, iTerm, and similar terminals
bindkey "^[[1~" beginning-of-line # for some other terminals
# Make the Del key delete characters after the cursor (forward delete)
bindkey "^[[3~" delete-char
