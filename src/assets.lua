Assets = {sets = {}}

function Assets.load(manifestPath)
    if Assets.sets[manifestPath] then
        Assets.sets[manifestPath].refCount = Assets.sets[manifestPath].refCount + 1
    else
        local manifest = loadfile(manifestPath)()
        local set = {
            sprites = {},
            fonts = {},
            sounds = {},
            refCount = 1
        }

        for k,v in pairs(manifest.sprites or {}) do
            set.sprites[k] = love.graphics.newImage(v)
        end

        for k,v in pairs(manifest.fonts or {}) do
            set.fonts[k] = love.graphics.newFont(v)
        end

        for k,v in pairs(manifest.sounds or {}) do
            set.sounds[k] = love.audio.newSource(v, "static")
        end

        Assets.sets[manifestPath] = set
    end
end

function Assets.release(manifestPath)
    if Assets.sets[manifestPath] then
      Assets.sets[manifestPath].refCount = Assets.sets[manifestPath].refCount - 1
      if Assets.sets[manifestPath].refCount < 1 then
        Assets.sets[manifestPath] = nil
      end
    end
end

function Assets.getSprite(manifestPath, name)
    return Assets.sets[manifestPath].sprites[name]
end

function Assets.getFont(manifestPath, name)
    return Assets.sets[manifestPath].fonts[name]
end

function Assets.getSound(manifestPath, name)
    return Assets.sets[manifestPath].sounds[name]
end