local res = "resources/intro/manifest.lua"
local delay = 2

return CutScene.load(res,
  -- The animation itself
  function (c, dt)
    c:setBackgroundColor({0xFF, 0xFF, 0xFF})
    c:setLetterBoxSize(400)
    c:setLayer(1, Assets.getSprite(res, "frame1"))
    c:setCaption("I'm passing through the walls again,", Assets.getFont(res, "caption"))
    c:wait(delay)

    c:setCaption("to hunt for my queen.", Assets.getFont(res, "caption"))
    c:wait(delay)

    c:setLayer(1, Assets.getSprite(res, "frame2"))
    c:setCaption("She's losing patience with me,", Assets.getFont(res, "caption"))
    c:wait(delay)

    c:setCaption("and I with her.", Assets.getFont(res, "caption"))
    c:wait(delay)

    c:setLayer(1, Assets.getSprite(res, "frame3"))
    c:setCaption("Because, it's not like she was going to eat it anyway...", Assets.getFont(res, "caption"))
    c:wait(delay)
    c:wait(delay)
  end,
  -- What to do after termination
  function ()
    StateStack.push(Scene.load("scenes/chase.lua"))
  end)