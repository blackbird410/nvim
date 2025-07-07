-- Highlight Copilot ghost text
vim.cmd([[highlight CopilotSuggestion ctermfg=8 guifg=white guibg=#5c6370]])

-- Setup Copilot plugin
require("copilot").setup({
	suggestion = {
		enabled = true,
		auto_trigger = false,
		debounce = 75,
		keymap = {
			accept = "<M-l>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
	},
	panel = { enabled = false },
})

-- User commands to control Copilot
vim.api.nvim_create_user_command("CopilotEnable", function()
	-- Force reattach in case Copilot is not yet started
	local copilot = require("copilot")
	copilot.setup({ -- optional: reapply settings
		suggestion = { auto_trigger = false },
		panel = { enabled = false },
	})

	require("copilot.suggestion").toggle_auto_trigger(true)
	vim.notify("Copilot enabled", vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("CopilotDisable", function()
	require("copilot.suggestion").toggle_auto_trigger(false)
	vim.notify("Copilot disabled", vim.log.levels.WARN)
end, {})

-- Optional: keybinding to toggle Copilot on/off
local copilot_enabled = true
vim.keymap.set("n", "<leader>ct", function()
	copilot_enabled = not copilot_enabled
	require("copilot.suggestion").toggle_auto_trigger(copilot_enabled)
	vim.notify("Copilot " .. (copilot_enabled and "enabled" or "disabled"))
end, { desc = "Toggle Copilot", silent = true })
