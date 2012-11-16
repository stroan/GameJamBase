require 'src.cut_scene'
require 'src.menu_scene'

Scene = {}

function Scene.load(scenePath)
    return loadfile(scenePath)()
end