autoload -Uz vcs_info

# Color
GITCOLOR=#EBCB8B
VENVCOLOR=#FFFACD
ARCHCOLOR=#81A1C1
FOREGROUND=#D8DEE9

CHECK_ANDROID="$(command -v getprop ro.build.version.release)"
OS="󰌽"
if [[ -n "$CHECK_ANDROID" ]]; then
	OS="󰀲"
fi

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '?'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git*' formats " %b%a%u%c"
zstyle ':vcs_info:git*' actionformats "  %b|%a %u %c "

function exit_color() {
  local LAST_EXIT_CODE=$?
  local EXIT_COLOR=$ARCHCOLOR
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    EXIT_COLOR='#BF616A'
  fi
  echo "$EXIT_COLOR"
}

function exit_code() {
  local EXIT_CODE=$?
	local EXIT_TEXT=""
  if [[ $EXIT_CODE -ne 0 ]]; then
		EXIT_TEXT=" errcode $EXIT_CODE "
  fi
  echo "$EXIT_TEXT"
}

precmd() {
	EXIT_STATUS=$(exit_code)
	vcs_info
	if [[ "${vcs_info_msg_0_}" != "" ]]; then
		VCS=" in "
		VCS+="%F{$GITCOLOR}%B ${vcs_info_msg_0_}%b %f"
	else
		VCS=""
	fi

	if [ -n "$VIRTUAL_ENV" ]; then
		VENV="%F{$FOREGROUND} using%f "
		VENV+="%F{$VENVCOLOR}%B  ${VIRTUAL_ENV:t} %b%f"
	else
		VENV=""
	fi
}

PROMPT='%B%F{$(exit_color)} $OS  ${EXIT_STATUS} %b%f'
PROMPT+=$'$USER@$HOST'
PROMPT+='${VENV}'
PROMPT+='${VCS}'
PROMPT+=$'\n'
PROMPT+='%F{$FOREGROUND} [ %c ] %B>>>%b%k '

export VIRTUAL_ENV_DISABLE_PROMPT=1
