function fish_prompt
    set -l last_status $status

    # Reload Matugen colours every prompt
    if test -f ~/.config/fish/matugen-colors.fish
        source ~/.config/fish/matugen-colors.fish
    else
        # Fallbacks
        set -g matu_primary a8c8ff
        set -g matu_secondary bdc7dc
        set -g matu_tertiary dbbce1
        set -g matu_error ff6b6b
        set -g matu_on_surface e1e2e9
        set -g matu_on_surface_variant c4c6cf
        set -g matu_outline 8e9199
    end

    # Arch / hostname
    set_color $matu_primary
    echo -n "󰣇 "

    set_color $matu_on_surface
    echo -n (hostname)

    # Directory
    set_color $matu_outline
    echo -n "  "

    set_color $matu_secondary
    echo -n "󰉋 "

    set_color $matu_on_surface
    echo -n (prompt_pwd)

    # Git branch
    if command -sq git
        set -l branch (git branch --show-current 2>/dev/null)

        if test -n "$branch"
            set_color $matu_outline
            echo -n "  "

            set_color $matu_tertiary
            echo -n " $branch"
        end
    end

    # Failed command indicator
    if test $last_status -ne 0
        set_color $matu_outline
        echo -n "  "

        set_color $matu_error
        echo -n "󰅙 $last_status"
    end

    echo

    # Prompt arrow
    set_color $matu_primary
    echo -n "❯ "

    set_color normal
end
