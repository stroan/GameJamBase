local FLYING_TIME_MIN = 2
local FLYING_TIME_MAX = 5

local RESTING_TIME_MIN = 3
local RESTING_TIME_MAX = 4

local Chase = {
    width = 1800,
    treeSpacing = 150,
    treeLayer = {},
    blips = {},
    birdAnims = {},

    currentX = 400,
    currentAngle = 0,
    walked = 0,
    stepSpeed = 60,

    currentTree = nil,
    destinationTree = nil,
    destinationTime = nil,
    departTime = nil,
}
function Chase:enter()
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

    self.destinationTree = 5 + (math.ceil(math.random() * table.maxn(self.treeLayer)) - 5)
    self.destinationTime = FLYING_TIME_MIN + ((FLYING_TIME_MAX - FLYING_TIME_MIN) * math.random())
end

function Chase:leave()

end

function Chase:update(dt)
    -- Update player position.

    if love.keyboard.isDown("right") and self.currentX >= 0 then
        local dx = dt * self.stepSpeed
        self.currentX = self.currentX + dx
        self.walked = self.walked + dx
    end

    if love.keyboard.isDown("left") and self.currentX <= self.width then
        local dx = dt * self.stepSpeed
        self.currentX = self.currentX - dx
        self.walked = self.walked + dx
    end

    if love.keyboard.isDown("up") then
        self.currentAngle = self.currentAngle + (dt * (math.pi / 10))
    end

    if love.keyboard.isDown("down") then
        self.currentAngle = self.currentAngle - (dt * (math.pi / 10))
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
        self.walked = 0
    end

    -- Update bird
    if self.destinationTime ~= nil then
        self.destinationTime = self.destinationTime - dt
        if self.destinationTime < 0 then
            self.destinationTime = nil
            self.currentTree = self.destinationTree
            self.departTime = RESTING_TIME_MIN + ((RESTING_TIME_MAX - RESTING_TIME_MIN) * math.random())

            local tree = self.treeLayer[self.currentTree]

            table.insert(self.blips, {
                x = tree.x,
                y = 450 - tree.tree:getTrunkHeight(),
                currentSize = 0,
                maxSize = 50,
                scary = false,
                color = {0,255,0,150}
            })
        end
    else 
        self.departTime = self.departTime - dt
        if self.departTime < 0 then
            local tree = self.treeLayer[self.currentTree]
            self.departTime = nil
            self.destinationTime = FLYING_TIME_MIN + ((FLYING_TIME_MAX - FLYING_TIME_MIN) * math.random())
            self.destinationTree = math.ceil(math.random() * table.maxn(self.treeLayer))

            table.insert(self.blips, {
                x = tree.x,
                y = 450 - tree.tree:getTrunkHeight(),
                currentSize = 0,
                maxSize = 50,
                scary = false,
                color = {0,0,255,150}
            })

            table.insert(self.birdAnims, {
                x = tree.x,
                y = 450 - tree.tree:getTrunkHeight(),
                vx = 100,
                vy = 100,
                endTime = 2
            })
        end
    end

    local newBirdAnims = {}
    for i,v in ipairs(self.birdAnims) do
        if v.endTime > 0 then
            v.x = v.x + (v.vx * dt)
            v.y = v.y + (v.vy * dt)
            table.insert(newBirdAnims, v)
        end
    end
    self.birdAnims = newBirdAnims

    -- Sway trees
    for i,v in ipairs(self.treeLayer) do
        v.tree:update(dt)
    end

    -- Update blips
    local newBlips = {}
    for i,v in ipairs(self.blips) do
        if v.currentSize < v.maxSize then
            table.insert(newBlips, v)
            v.currentSize = v.currentSize + (150 * dt)
        end
    end
    self.blips = newBlips
end

function Chase:draw()
    love.graphics.setBackgroundColor(20,20,60)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 0, 450, 800, 150)

    love.graphics.setColor(150,150,175)
    love.graphics.circle("fill", 550, 75, 100, 20)

    local x = self.currentX - 400
    local k = 0
    for i,v in ipairs(self.treeLayer) do
        if v.x > x - 200 and v.x < x + 1000 then
            v.tree:draw(v.x - x, 450)
            k = k  +1
        end
    end

    love.graphics.setColor(255,255,255)
    love.graphics.circle("fill", 400, 440, 20, 20)

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

    for i,v in ipairs(self.birdAnims) do
        love.graphics.setColor(0,0,0,255)
        love.graphics.circle("fill", v.x - x, v.y, v.currentSize)
    end
end

return Chase