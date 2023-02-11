return {
    rustfmt = {
        rangeFormatting = {
            enable = true
        }
    },
    imports = {
        granularity = {
            group = "module",
        },
        prefix = "self",
    },
    cargo = {
        loadOutDirsFromCheck = true,
        buildScripts = {
            enable = true,
        },
    },
    procMacro = {
        enable = true
    },
}
