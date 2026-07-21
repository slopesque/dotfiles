local strings = {}

-- Functions

-- Supress all breaklines inside the text.
--
-- This also removes indentation following breaklines. Assumes no identation is
-- utilized on the very first line.
--
-- @param text string The text to process
-- @return string The processed string.
function strings.oneline_str(text)
    local processed_text = text

    processed_text = string.gsub(processed_text, "\n%s*", " ")

    return processed_text
end


-- Shorten the string so that it may fit on a given size.
--
-- If the string is too large, it is reduced to `max_length` - 3 and ... is
-- added at the end of the string.
--
-- @param text string The text to process
-- @param max_length number The maximum size we want to the stirng to fit in
-- @return string The processed string.
function strings.shorten_str(text, max_length)
    local processed_text = text

    if #processed_text > max_length then
        processed_text = string.sub(processed_text, 0, max_length - 3) .. "..."
    end

    return processed_text
end


-- Pretty-print the string so that it may fit on one reduced line.
--
-- Calls in order the following functions over the string :
--    - oneline_str
--    - shorten_str
--
-- Typically, we want the string to fit in the Neovim built-in status line.
--
-- @param text string The text to process
-- @param max_length number The maximum size we want to the stirng to fit in
-- @return string The processed string.
function strings.pretty_print_str(text, max_length)
    local processed_text = text

    processed_text = strings.oneline_str(processed_text)
    processed_text = strings.shorten_str(processed_text, max_length)

    return processed_text
end

return strings
