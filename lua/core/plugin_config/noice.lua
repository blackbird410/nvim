require("noice").setup({
	lsp = {
		progress = { enabled = true },
		signature = { enabled = true },
		hover = { enabled = true },
		message = {
			enabled = true,
			view = "mini",
		},
	},
	presets = {
		lsp_doc_border = true,
	},
})
