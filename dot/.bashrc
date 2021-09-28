#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.exports ] && source ~/.exports
[ -f ~/.dircolors ] && eval `dircolors ~/.dircolors`
PS1='[\u@\h \W]\$ '

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_dir="$HOME/.anaconda3"
__conda_setup="$("$__conda_dir/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$__conda_dir/etc/profile.d/conda.sh" ]; then
        . "$__conda_dir/etc/profile.d/conda.sh"
    else
        export PATH="$__conda_dir/bin:$PATH"
    fi
fi
unset __conda_setup __conda_dir
# <<< conda initialize <<<

