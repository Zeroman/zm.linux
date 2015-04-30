
if compctl >/dev/null 2>&1; then
    compctl -s '$(zm --help)' zm
else
    complete -F _longopt zm 
fi
