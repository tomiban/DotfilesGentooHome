function findhall
    find ~/ -not \( -wholename "/home/lucas/.local/share/icons" -prune -o -wholename "/mnt/archlinux/HOME" -prune \)  -iname """*$argv[1]*""" 2> /dev/null
end



