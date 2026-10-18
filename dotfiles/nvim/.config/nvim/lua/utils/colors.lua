local colors = {}

colors.RED = "\27[31m"
colors.RESET = "\27[0m"

-- Color some text using a color.
--
-- The result is meant to be displayed in a TUI (which what Neovim usually does
-- lmao)
--
-- @param text string a string
-- @param color string a value in colors or a custom shell color magic value
-- @return string text, colored in color
function colors.wrap_in(text, color)
    return colors.RED .. text .. colors.RESET
end

return colors
