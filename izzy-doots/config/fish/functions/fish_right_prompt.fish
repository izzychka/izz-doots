function fish_right_prompt
    if test -f ~/.config/fish/matugen-colors.fish
        source ~/.config/fish/matugen-colors.fish
    end

    set_color $matu_outline
    echo -n " "(date "+%H:%M")
    set_color normal
end
