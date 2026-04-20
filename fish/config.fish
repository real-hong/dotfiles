set -x EDITOR nvim
set -x GTK_IM_MODULE fcitx
set -x QT_IM_MODULE fcitx
set -x XMODIFIERS "@im=fcitx"

fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/go/bin"

alias nv=nvim
alias cat=bat
alias ls=exa
alias ll="exa -lgH"
alias grep="grep -E --color=auto"

function is_ubuntu
  test -r /etc/os-release; or return 1
  set -l os_id (sh -c '. /etc/os-release && printf "%s" "$ID"')
  test "$os_id" = ubuntu
end

if is_ubuntu
  alias cat=batcat
end

starship init fish | source
zoxide init fish | source
mcfly init fish | source
