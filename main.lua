require 'third_party.all'
require 'src.scene'
require 'src.state_stack'
require 'src.tree_gen'

function love.load()
    math.randomseed( os.time() )
    local splash = Scene.load("scenes/splash.lua")
    StateStack.push(splash)
end

function love.update(dt)
    StateStack.update(dt)
end

function love.draw()
    StateStack.draw()
end