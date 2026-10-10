local buffers = {}

--
-- Buffer Templates
--

-- Define a new buffer. It is unlisted and will be removed once hidden.
--
-- Returns:
--   int - The identifier of the new buffer.
function buffers.create_temporary_buf()
    local buf = vim.api.nvim_create_buf(false, true)

    vim.bo[buf].bufhidden = "wipe"

    return buf
end

return buffers
