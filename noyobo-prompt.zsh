# noyobo prompt (extracted from Oh My Zsh theme; no OMZ required)
# Source from ~/.zshrc:  source ~/.zsh/noyobo-prompt.zsh

autoload -Uz colors && colors
setopt PROMPT_SUBST

function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function parse_git_dirty() {
  local STATUS
  local -a FLAGS
  FLAGS=('--porcelain')
  if [[ "${DISABLE_UNTRACKED_FILES_DIRTY:-}" == "true" ]]; then
    FLAGS+='--untracked-files=no'
  fi
  case "${GIT_STATUS_IGNORE_SUBMODULES:-}" in
    git) ;;
    *) FLAGS+="--ignore-submodules=${GIT_STATUS_IGNORE_SUBMODULES:-dirty}" ;;
  esac
  STATUS=$(__git_prompt_git status ${FLAGS} 2> /dev/null | tail -n 1)
  if [[ -n $STATUS ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

function git_prompt_info() {
  if ! __git_prompt_git rev-parse --git-dir &> /dev/null; then
    return 0
  fi

  local ref
  ref=$(__git_prompt_git symbolic-ref --short HEAD 2> /dev/null) \
  || ref=$(__git_prompt_git describe --tags --exact-match HEAD 2> /dev/null) \
  || ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) \
  || return 0

  local upstream
  if (( ${+ZSH_THEME_GIT_SHOW_UPSTREAM} )); then
    upstream=$(__git_prompt_git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null) \
    && upstream=" -> ${upstream}"
  fi

  echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref:gs/%/%%}${upstream:gs/%/%%}$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[magenta]%}⤵%{$reset_color%}  %{$fg[blue]%}git:(%{$fg_bold[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) 🖌"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[blue]%}) 💊"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) 💟"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[blue]%}) 😍"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%}) 😜"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[blue]%}) 😵"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}) 😴"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[blue]%}) 😱"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[blue]%}) 🤕"

# Single-quoted multiline with trailing `\` does NOT join lines in zsh — it puts `\` + newline into PROMPT and breaks the layout.
# One real newline between the two rows: time/git line → arrow/cwd line (matches original OMZ theme).
PROMPT='%{$fg_bold[blue]%}#%{$reset_color%} %(#,%{$bg[yellow]%}%{$fg[black]%}%n%{$reset_color%},%{$fg[white]%}%n) %{$fg_bold[green]%}🕑  %* $(git_prompt_info) %(?,, code: %{$fg[red]%}%?%{$reset_color%})'$'\n''%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg_bold[cyan]%}%c%{$reset_color%} %{$fg_bold[magenta]%}$ %{$reset_color%}'
