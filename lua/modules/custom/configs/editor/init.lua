local config = {}

function config.package_info()
    require("package-info").setup(
        {
            icons = {
                enable = true,
                style = {
                    up_to_date = "|  ",
                    outdated = "|  "
                }
            },
            autostart = true
        }
    )
end

function config.lvim_dependencies()
    require("lvim-dependencies").setup({
        jsts = {
            az = {
                nie = {"iznenadaaaaaaaa"}
            }
        }
    })
end


return config
