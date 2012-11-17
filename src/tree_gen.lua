local BRANCH_LENGTH = 60
local MIN_BRANCH_LENGTH = 15
local BRANCH_ANGLE = (math.pi / 2)

local function makeTree(branchLength, maxDepth, bias, depth, branch)
    if not branch then
        branch = { 
            length = branchLength * 4,
            angle = 0
        }
    end

    if depth == nil then
        depth = 0
    end

    if bias == nil then
        bias = (math.pi / 8) - (math.random() * (math.pi / 4))
    end

    local newBranches = {}
    if depth < maxDepth then
        local len = (branchLength / math.pow(2, depth));
        local branch1 = {
            length = MIN_BRANCH_LENGTH + len,-- + ((0.5 - math.random()) * len),
            angle = bias + (math.pi / 8) + ((math.pi / 4) * math.random())
        }
        table.insert(newBranches, branch1)
        makeTree(branchLength, maxDepth, bias, depth + 1, branch1)

        local branch2 = {
            length = MIN_BRANCH_LENGTH + len,-- + ((0.5 - math.random()) * len),
            angle = bias + (math.pi / -8) - ((math.pi / 4) * math.random())
        }
        table.insert(newBranches, branch2)
        makeTree(branchLength, maxDepth, bias, depth + 1, branch2)

    end
    branch.children = newBranches
    return branch
end

Tree = {}
Tree.__index = Tree
function Tree:new()
    local totalDepth = math.ceil(5 + (math.random() * 2))
    local o = {
        branches = makeTree(30 + math.random() * 30, totalDepth),
        totalDepth = totalDepth,
        tilt = 0,
        animT = math.random()
    }
    setmetatable(o, Tree)
    return o
end

function Tree:update(dt)
    self.animT = self.animT + dt
    self.tilt = math.sin(self.animT) * (math.pi / 180)
end

function Tree:draw(x, y)
    love.graphics.setColor(0, 0, 0)
    love.graphics.push()
    love.graphics.translate(x,y)
    self:drawBranch((self.totalDepth + 1) * 2, self.branches)
    love.graphics.pop()
end

function Tree:drawBranch(size, branch)
    love.graphics.setLineWidth(size)
    love.graphics.setLineStyle("smooth")
    love.graphics.rotate(branch.angle + self.tilt)
    love.graphics.line(0, 0, 0, -branch.length)
    for _,v in ipairs(branch.children) do
        love.graphics.push()
        love.graphics.translate(0,-branch.length)
        self:drawBranch(size - 2, v)
        love.graphics.pop()
    end
end

function Tree:getTrunkHeight()
    return self.branches.length
end