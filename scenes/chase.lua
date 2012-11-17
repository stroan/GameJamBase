local FLYING_TIME_MIN = 2
local FLYING_TIME_MAX = 5

local RESTING_TIME_MIN = 1
local RESTING_TIME_MAX = 4

local RESOURCES = "resources/chase/manifest.lua"

local Chase = {
    width = 1800,
    treeSpacing = 150,
    treeLayer = {},
    blips = {},
    birdAnims = {},

    birdKilled = 0,
    birdScared = nil,

    currentX = 400,
    currentAngle = 0,
    facing = 1,
    walked = 0,
    stepSpeed = 100,

    walkingFrame = "man1",
    walkingFrameTime = 0,


    currentTree = nil,
    destinationTree = nil,
    destinationTime = nil,
    departTime = nil,

    timePlaying = 0,
    timeLimit = 60,

    net = nil
}
function Chase:enter()
    Assets.load(RESOURCES)
    local treeBlocks = self.width / self.treeSpacing

    local time = os.time()
    math.randomseed( time )
    print("seed", time)

    for i = 0,treeBlocks - 1 do
        table.insert(self.treeLayer, {
            tree = Tree.new(),
            x = (self.treeSpacing * i) + (math.random() * self.treeSpacing)
        })
    end

    self:newBird(3)
end

function Chase:leave()
    Assets.release(RESOURCES)
end

function Chase:update(dt)
    if love.keyboard.isDown("escape") and self.timePlaying > 1 then
        StateStack.pop()
        return
    end

    if self.wonGame ~= nil then
        self.wonGame = self.wonGame - dt
        if self.wonGame < 0 then
            print("you won")
            StateStack.pop()
        end
        return
    end

    self.timePlaying = self.timePlaying + dt
    if (self.timeLimit - self.timePlaying < 0) then
        self.wonGame = 5
    end

    if self.alertTime ~= nil then
        self.alertTime = self.alertTime - dt
        if self.alertTime < 0 then
            self.alertTime = nil
        end
    end

    -- Update player position.
    if love.keyboard.isDown("right") and self.currentX >= 0 then
        local dx = dt * self.stepSpeed
        self.currentX = self.currentX + dx
        self.walked = self.walked + dx
        self.facing = 1
        self.walkingFrameTime = self.walkingFrameTime + dt
    end

    if love.keyboard.isDown("left") and self.currentX <= self.width then
        local dx = dt * self.stepSpeed
        self.currentX = self.currentX - dx
        self.walked = self.walked + dx
        self.facing = 0
        self.walkingFrameTime = self.walkingFrameTime + dt
    end

    if love.keyboard.isDown("up") then
        self.currentAngle = self.currentAngle + (dt * (math.pi / 2))
    end

    if love.keyboard.isDown("down") then
        self.currentAngle = self.currentAngle - (dt * (math.pi / 2))
    end

    if love.keyboard.isDown(" ") and self.net == nil then

        local a = Assets.getSound(RESOURCES, "gun")
        a:rewind()
        a:play()

        self.net = {
            x = self.currentX,
            y = 440,
            vx = math.cos(self.currentAngle) * 30,
            vy = math.sin(self.currentAngle) * -30,
            duration = 1
        }
        if self.facing == 0 then
            self.net.vx = -self.net.vx
        end
    end

    if self.walked > 30 then
        table.insert(self.blips, {
            x = self.currentX,
            y = 440,
            currentSize = 0,
            maxSize = 250,
            scary = true,
            color = {100,0,0,150}
        })
        local a = Assets.getSound(RESOURCES, "step")
        a:rewind()
        a:play()
        self.walked = 0
    end

    if self.walkingFrameTime > 0.2 then
        self.walkingFrameTime = 0
        if self.walkingFrame == "man1" then
            self.walkingFrame = "man2"
        else
            self.walkingFrame = "man1"
        end
    end

    local birdX, birdY = nil, nil
    if self.departTime ~= nil then
        local tree = self.treeLayer[self.currentTree]
        birdX = tree.x
        birdY = 450 - tree.tree:getTrunkHeight()
    end

    local newBirdAnims = {}
    for i,v in ipairs(self.birdAnims) do
        if v.endTime > 0 then
            v.endTime = v.endTime - dt
            v.x = v.x + (v.vx * dt)
            v.y = v.y + (v.vy * dt)
            table.insert(newBirdAnims, v)
        end

        if self.net ~= nil then
            local n = self.net
            if birdX ~= nil and math.sqrt(math.pow(n.x - v.x,2) + math.pow(n.y - v.y,2)) < 10 then

                local a = Assets.getSound(RESOURCES, "hit")
                a:rewind()
                a:play()

                self.birdKilled = self.birdKilled + 1
                self:newBird(2)
            end
        end
    end
    self.birdAnims = newBirdAnims


    -- Update bird
    if self.destinationTime ~= nil then
        self.destinationTime = self.destinationTime - dt
        if self.destinationTime < 0 then
            self.birdWaiting = false
            self.destinationTime = nil
            self.currentTree = self.destinationTree
            self.departTime = RESTING_TIME_MIN + ((RESTING_TIME_MAX - RESTING_TIME_MIN) * math.random())

            local tree = self.treeLayer[self.currentTree]

            local a = Assets.getSound(RESOURCES, "cheep")
            a:rewind()
            a:play()

            table.insert(self.blips, {
                x = tree.x,
                y = 450 - tree.tree:getTrunkHeight(),
                currentSize = 0,
                maxSize = 50,
                scary = false,
                color = {0,255,255,150}
            })
        end
    else 
        self.departTime = self.departTime - dt
        if self.departTime < 0 then
            local tree = self.treeLayer[self.currentTree]
            self.departTime = nil
            self.destinationTime = FLYING_TIME_MIN + ((FLYING_TIME_MAX - FLYING_TIME_MIN) * math.random())
            self.destinationTree = (((table.maxn(self.treeLayer) - 1) + (self.currentTree - 1) + (2 - math.ceil(math.random() * 4))) % table.maxn(self.treeLayer)) + 1
            self.currentTree = nil

            local a = Assets.getSound(RESOURCES, "cheep")
            a:rewind()
            a:play()

            table.insert(self.blips, {
                x = tree.x,
                y = 450 - tree.tree:getTrunkHeight(),
                currentSize = 0,
                maxSize = 50,
                scary = false,
                color = {0,255,255,150}
            })

            table.insert(self.birdAnims, {
                x = tree.x,
                y = 450 - tree.tree:getTrunkHeight(),
                vx = 200,
                vy = -200,
                endTime = 2
            })

            local dtree = self.treeLayer[self.destinationTree]

            table.insert(self.birdAnims, {
                x = dtree.x - (200 * self.destinationTime),
                y = (450 - dtree.tree:getTrunkHeight()) - (200 * self.destinationTime),
                vx = 200,
                vy = 200,
                endTime = self.destinationTime
            })
        end
    end

    -- Sway trees
    for i,v in ipairs(self.treeLayer) do
        v.tree:update(dt)
    end

    -- Update net
    if self.net ~= nil then
        local n = self.net
        n.x = n.x + n.vx
        n.y = n.y + n.vy
        n.vy = n.vy + (dt * 40)
        n.duration = n.duration - dt
        if n.duration < 0 or n.y > 440 then
            self.net = nil
        end
        if birdX ~= nil and math.sqrt(math.pow(birdX - n.x,2) + math.pow(birdY - n.y,2)) < 20 then

            local a = Assets.getSound(RESOURCES, "hit")
            a:rewind()
            a:play()

            self.birdKilled = self.birdKilled + 1
            self:newBird(2)
        end
    end

    -- Update blips
    local newBlips = {}
    for i,v in ipairs(self.blips) do
        if v.currentSize < v.maxSize then
            table.insert(newBlips, v)
            v.currentSize = v.currentSize + (150 * dt)
            if v.scary and birdX ~= nil and math.sqrt(math.pow(birdX - v.x,2) + math.pow(birdY - v.y,2)) < v.currentSize then
                self:newBird(5)
                self.alertTime = 5
            end
        end
    end
    self.blips = newBlips
end

function Chase:draw()
    local x = self.currentX - 400

    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(Assets.getSprite(RESOURCES, "background"), 0, 0)
    love.graphics.setColor(10,10,10)
    love.graphics.rectangle("fill", 0, 450, 800, 150)

    for i,v in ipairs(self.birdAnims) do
        love.graphics.setColor(255,255,255,255)
        love.graphics.draw(Assets.getSprite(RESOURCES, "bird"), v.x - x, v.y)
    end

    local k = 0
    for i,v in ipairs(self.treeLayer) do
        if v.x > x - 200 and v.x < x + 1000 then
            v.tree:draw(v.x - x, 450)
            if i == self.currentTree then
                love.graphics.setColor(255,255,255,255)
                love.graphics.draw(Assets.getSprite(RESOURCES, "bird"), v.x - x, 450 - v.tree:getTrunkHeight())
            end
            k = k  +1
        end
    end

    local sx = 1
    if self.facing == 0 then
        sx = -1
    end
    love.graphics.setColor(255,255,255)
    --love.graphics.circle("fill", 400, 440, 20, 20)
    love.graphics.push()
    love.graphics.translate(400, 410)
    if self.facing == 0 then
        love.graphics.scale(-1,1)
    end
    love.graphics.draw(Assets.getSprite(RESOURCES, self.walkingFrame), -20, 0)
    love.graphics.translate(0,27)
    love.graphics.rotate(- self.currentAngle)
    love.graphics.draw(Assets.getSprite(RESOURCES, "gun"), 0, -5)
    love.graphics.pop()

    love.graphics.setLineWidth(5)
    for i,v in ipairs(self.blips) do
        local tx = v.x - x
        if tx < 0 then
            tx = 0
        elseif tx > 800 then
            tx = 800
        end
        love.graphics.setColor(v.color)
        love.graphics.circle("line", tx, v.y, v.currentSize, 30)
    end

    if self.net ~= nil then
        love.graphics.setColor(255,255,255,255)
        love.graphics.setLineWidth(2)
        local tx, ty = self.net.x - x, self.net.y
        love.graphics.line(tx, ty, tx + (self.net.vx), ty + (self.net.vy))
    end

    love.graphics.setColor(255,255,255,255)
    for i = 1,self.birdKilled do
        love.graphics.draw(Assets.getSprite(RESOURCES, "bird"), 20 * i, 550)
    end

    local f = Assets.getFont(RESOURCES, "timer")
    local msg = string.format("Time: %ds", self.timeLimit - self.timePlaying)
    local w = f:getWidth(msg)
    love.graphics.setFont(f)
    love.graphics.print(msg, 400 - (w / 2), 550)

    if self.birdWaiting then
        msg = string.format("Next bird in: %ds", self.destinationTime)
        local w = f:getWidth(msg)
        love.graphics.print(msg, 400 - (w / 2), 500)
    end

    if self.wonGame ~= nil then
        local f = Assets.getFont(RESOURCES, "notification")
        local msg = string.format("YOU KILLED %d BIRDS", self.birdKilled)
        local w = f:getWidth(msg)
        love.graphics.setFont(f)
        love.graphics.print(msg, 400 - (w / 2), 300)
    elseif self.timePlaying < 2 then
        local f = Assets.getFont(RESOURCES, "notification")
        local msg = "KILL THE BIRDS TO FEED YOUR QUEEN"
        local w = f:getWidth(msg)
        love.graphics.setFont(f)
        love.graphics.print(msg, 400 - (w / 2), 300)
    elseif self.alertTime ~= nil then
        local f = Assets.getFont(RESOURCES, "notification")
        local msg = "YOU SCARED AWAY THE BIRDS"
        local w = f:getWidth(msg)
        love.graphics.setFont(f)
        love.graphics.print(msg, 400 - (w / 2), 300)
    end
end

function Chase:newBird(wait)
    self.birdWaiting = true
    self.destinationTree = 5 + (math.ceil(math.random() * table.maxn(self.treeLayer)) - 5)
    self.destinationTime = wait
    self.departTime = nil
    self.currentTree = nil
end

return Chase