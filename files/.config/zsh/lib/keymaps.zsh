function zle-line-init() {
	echoti smkx
}

function zle-line-finish() {
	echoti rmkx
}

zle -N zle-line-init
zle -N zle-line-finish

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Search history using up & down arrow by input
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
bindkey "$terminfo[kcud1]" down-line-or-beginning-search

# Backspace and Delete
bindkey "$terminfo[kbs]" backward-delete-char
bindkey "$terminfo[kdch1]" delete-char

# Move one word using ctrl + {Right,Left}
bindkey "$terminfo[kLFT5]" backward-word
bindkey "$terminfo[kRIT5]" forward-word

# Move to beginning or end
bindkey "$terminfo[khome]" beginning-of-line
bindkey "$terminfo[kend]" end-of-line

# Shift+Tab: reverse completion
bindkey "$terminfo[kcbt]" reverse-menu-complete

# Delete one word using ctrl+{backspace,delete}
bindkey '^H' backward-kill-word # ctrl+backspace
bindkey '^[[3;5~' kill-word # ctrl + delete
