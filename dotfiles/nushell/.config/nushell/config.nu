#!/usr/bin/nu


# Carapace-based command completions
if ("~/.cache/carapace/init.nu" | path exists) {
    source ~/.cache/carapace/init.nu
}


# Configuration files
source ~/.config/nushell/theme/theme.nu
source ~/.config/nushell/prompt/prompt.nu
source ~/.config/nushell/scripts/commands.nu
source ~/.config/nushell/alias.nu
source ~/.config/nushell/startup.nu
