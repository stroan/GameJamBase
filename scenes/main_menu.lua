return MenuScene.load(
    "resources/main_menu/manifest.lua",
    {
        fontName = "menu",
        title = "Controls: Arrow Keys + Enter"
    },
    {{
        message = "NEW GAME",
        action = function()
            StateStack.push(Scene.load("scenes/intro.lua"))
        end
    },
    {
        message = "EXIT",
        action = function()
            love.event.push("quit")
        end
    }})