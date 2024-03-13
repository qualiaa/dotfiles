#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.exports ] && source ~/.exports
[ -f ~/.dircolors ] && eval `dircolors ~/.dircolors`
PS1='[\u@\h \W]\$ '
