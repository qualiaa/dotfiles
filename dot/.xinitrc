[ -f ~/.xprofile ] && ~/.xprofile

exec i3 > .root_out 2> .root_err
