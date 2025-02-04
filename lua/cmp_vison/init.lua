local M = {}

M.new = function()
	return setmetatable({}, { __index = M })
end

M.complete = function(self, params, callback)
	local bufnr = params.context.bufnr
	local schema = vim.fn.getbufvar(bufnr, 'vison_schema', '')
	if schema == '' then
		return callback()
	end
	local offset_0 = self:_invoke({1, ''})
	if type(offset_0) ~= 'number' then
		return callback()
	end
	local result = self:_invoke({0, string.sub(params.context.cursor_before_line, offset_0 + 1)})
	if type(result) ~= 'table' then
		return callback()
	end

	local text_edit_range = {
		start = {line = params.context.cursor.line, character = offset_0},
		['end'] = {line = params.context.cursor.line, character = params.context.cursor.character},
	}

	local items = {}
	for _, v in ipairs(result) do
		if type(v) == 'string' then
			table.insert(items, {
				label = v,
				kind = 15,
				textEdit = { range = text_edit_range, newText = v },
			})
		elseif type(v) == 'table' then
			table.insert(items, {
				label = v.abbr or v.word,
				kind = 15,
				textEdit = { range = text_edit_range, newText = v.word },
				labelDetails = { detail = v.kind, description = v.menu },
			})
		end
	end
	callback({ items = items })
end

M._invoke = function(_self, args)
	local prev_pos = vim.api.nvim_win_get_cursor(0)
	local result = vim.api.nvim_call_function('vison#complete', args)
	local next_pos = vim.api.nvim_win_get_cursor(0)
	if prev_pos[1] ~= next_pos[1] or prev_pos[2] ~= next_pos[2] then
		vim.api.nvim_win_set_cursor(0, prev_pos)
	end
	return result
end

return M
