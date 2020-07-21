local vec2 = require "vector"

function genPoints(num)
    local lm = love.math
    local space = 20
    local res = {}
    local w, h = love.graphics.getDimensions()
    for i = 1, num do
        --local px = love.math.random() < 0.5 and lm.random(-space, 0) or lm.random(w + 1, w + space)
        --local py = love.math.random() < 0.5 and lm.random(-space, 0) or lm.random(h + 1, h + space)

        local px, py
        repeat
            px = lm.random(-space + -100, w + space + 100)
            py = lm.random(-space + -100, h + space + 100)
        until (px < 0 or px > w) or (py < 0 or py > h)
       
        --repeat
            --py = lm.random(-space, h + space)
        --until py < 0 or py > h

        print("px, py", px, py)
        --repeat
            --py = lm.random(-space, h + space)
        --until py > 0 and px < h
        --py = 10
        
        res[i] = {
            x = px,
            y = py,
        }
    end
    return res
end

local updatePointsTime = love.timer.getTime()

function drawPoints(points)
    for i = 1, #points do
        local p = points[i]
        love.graphics.setColor(p.pix[3], p.pix[4], p.pix[5], p.pix[6])
        love.graphics.points(p.x, p.y)
    end
end

function drawText2Canvas()
    local canvas = love.graphics.newCanvas()
    local font = love.graphics.setNewFont(55)
    local w, h = love.graphics.getDimensions()

    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.setColor{1, 1, 1, 1}
    --love.graphics.printf("Some message", 0, (h - font:getHeight()) / 2, 1000, "center")
    local msg = "Cubrik"
    local tx = (w - font:getWidth(msg)) / 2
    local ty = (h - font:getHeight()) / 2
    print("ty", ty)
    love.graphics.print(msg, tx, (h - font:getHeight()) / 2)

    love.graphics.setCanvas()
    return canvas
end

function setupEffect()
    updatePointsTime = love.timer.getTime()

    textCanvas = drawText2Canvas()
    local imgData = textCanvas:newImageData()

    local textPoints = {}
    imgData:mapPixel(function(x, y, r, g, b, a)
        if r ~= 0 and g ~= 0 and b ~= 0 then
            table.insert(textPoints, { x, y, r, g, b, a})
        end
        return r, g, b, a
    end)

    print("#textPoints", #textPoints)

    points = genPoints(#textPoints)

    for k, v in pairs(points) do
        v.pix = textPoints[k]
        v.dir = vec2(v.pix[1] - v.x, v.pix[2] - v.y):normalizeInplace()
    end
end

love.load = function()
    setupEffect()
end

function updatePoints(points)
    --local newpoints = {}
    for k, v in pairs(points) do
        if not v.done then
            --local dx, dy = math.abs(v.x - v.pix[1]), math.abs(v.y - v.pix[2])
            v.x, v.y = v.x + v.dir.x, v.y + v.dir.y
            local dx, dy = math.abs(v.x - v.pix[1]), math.abs(v.y - v.pix[2])
            if dx <= 1 or dy <= 1 then
                v.done = true
                v.x = v.pix[1]
                v.y = v.pix[2]
                --print("done")
            else
                v.x, v.y = v.x + v.dir.x, v.y + v.dir.y
            end
            --table.insert(newpoints, v)
        end
    end
    --return newpoints
    return points
end

local pause = false

love.keypressed = function(_, key)
    if key == "r" then
        setupEffect()
        love.graphics.setColor{1, 1, 1}
    elseif key == "p" then
        pause = not pause
    end
end

love.draw = function()
    drawPoints(points)
    --love.graphics.draw(textCanvas)
end

love.update = function(dt)
    if not pause then
        local now = love.timer.getTime()
        if now - updatePointsTime >= 0.01 then
            updatePointsTime = now
            updatePoints(points)
        end
    end
end
