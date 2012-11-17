require 'src.cut_scene'
require 'src.menu_scene'

Scene = {}

function Scene.load(scenePath)
    b, err = loadfile(scenePath)
    if not b then
        error(err)
    end
    return b()
end