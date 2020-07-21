local vec2 = require "vector"

function genPoints(num)
    local res = {}
    local w, h = love.graphics.getDimensions()
    for i = 1, num do
        local px, py = love.math.random(1, w), love.math.random(1, h)
        res[i] = {
            x = px,
            y = py,
        }
    end
    return res
end

function drawPoints(points)
    for i = 1, #points do
        local p = points[i]
        love.graphics.points(p.x, p.y)
    end
end

function drawText2Canvas()
    local canvas = love.graphics.newCanvas()
    local font = love.graphics.setNewFont(55)
    local w, h = love.graphics.getDimensions()
    love.graphics.setCanvas(canvas)
    --love.graphics.printf("Some message", 0, (h - font:getHeight()) / 2, 1000, "center")
    local msg = "Some message"
    local tx = (w - font:getWidth(msg)) / 2
    local ty = (h - font:getHeight()) / 2
    print("ty", ty)
    love.graphics.print(msg, tx, (h - font:getHeight()) / 2)
    love.graphics.setCanvas()
    return canvas
end

love.load = function()
    textCanvas = drawText2Canvas()
    local imgData = textCanvas:newImageData()

    local textPoints = {}
    imgData:mapPixel(function(x, y, r, g, b, a)
        --io.write(r, " ", g, " ", b," ",  a)
        --io.write("\n")
        --table.insert(textPoints,
        if r ~= 0 and g ~= 0 and b ~= 0 then
            table.insert(textPoints, { x, y, r, g, b})
        end
        return r, g, b, a
    end, 0, 0, imgData:getWidth(), imgData:getHeight())

    print("#textPoints", #textPoints)

    points = genPoints(#textPoints)

    for k, v in pairs(points) do
        v.pix = textPoints[k]
        v.dir = vec2(v.pix[1] - v.x, v.pix[2] - v.y):normalizeInplace()
        print("dirx", dirx, "diry", diry)
        --print(v.x, v.y, v.pix.x, v.pix.y)
    end
end

function updatePoints(points)
    --local newpoints = {}
    for k, v in pairs(points) do
        if not v.done then
            local dx, dy = math.abs(v.x - v.pix[1]), math.abs(v.y - v.pix[2])
            if dx > 0.1 or dy > 0.1 then
                v.x, v.y = v.x + v.dir.x, v.y + v.dir.y
            else
                v.done = true
                v.x = v.pix[1]
                v.y = v.pix[2]
                print("done")
            end
            --table.insert(newpoints, v)
        end
    end
    --return newpoints
    return points
end

love.draw = function()
    drawPoints(points)
    --love.graphics.draw(textCanvas)
end

local updatePointsTime = love.timer.getTime()

love.update = function(dt)
    local now = love.timer.getTime()
    if now - updatePointsTime >= 0.01 then
        updatePointsTime = now
        points = updatePoints(points)
    end
end
