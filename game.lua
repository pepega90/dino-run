local composer = require("composer")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
require "common"

local physics = require("physics")
physics.start()
physics.setGravity(0, 20)

math.randomseed(os.time())

-- change background
display.setDefault("background", 0.5, 0.5, 0.5)

-- function untuk dino lompat
local function makeDinoJump(event)
    if event.phase == "began" and dino_run.isGround then
        dino_run:setLinearVelocity(0, -400)
        dino_run:setSequence("idle")
        dino_run:play()
        audio.play(jumpSfx)
        dino_run.isGround = false
    end
    return true
end

-- event listener untuk deteksi ketika dino menyentuh tanah
local function onCollision(event)
    if event.phase == "began" then
        if event.object1 == dino_run or event.object2 == dino_run then
            dino_run:setSequence("run")
            dino_run:play()
            dino_run.isGround = true
        end
    end
end

local function moveTree()
    local currentTime = system.getTimer()
    local deltaTime = (currentTime - previousTime) / 1000 -- Calculate delta time in seconds
    previousTime = currentTime

    local speed = 200                       -- Speed in pixels per second
    tree.x = tree.x - (speed * deltaTime)   -- Move tree using delta time

    if tree.x < -300 then                   -- Check if the tree has moved off-screen
        tree.x = display.contentWidth + 250 -- Reset tree position to the right side of the screen
        score = score + 10
        scoreText.text = "Score = " .. score
    end
end

local function moveAwan()
    local currentTime = system.getTimer()
    local deltaTime = (currentTime - previousTimeAwan) / 1000 -- Calculate delta time in seconds
    previousTimeAwan = currentTime

    local speed = 40                        -- Speed in pixels per second
    awan.x = awan.x - (speed * deltaTime)   -- Move tree using delta time

    if awan.x < -250 then                   -- Check if the tree has moved off-screen
        awan.x = display.contentWidth + 150 -- Reset tree position to the right side of the screen
        awan.y = math.random(22, 100)
    end
end

local function moveBird()
    local currentTime = system.getTimer()
    local deltaTime = (currentTime - previousTimeBird) / 1000 -- Calculate delta time in seconds
    previousTimeBird = currentTime

    local speed = 60                        -- Speed in pixels per second
    bird.x = bird.x - (speed * deltaTime)   -- Move tree using delta time

    if bird.x < -250 then                   -- Check if the tree has moved off-screen
        bird.x = display.contentWidth + 120 -- Reset tree position to the right side of the screen
        bird.y = math.random(22, 100)
    end
end

local function stopGame()
    -- Stop the game by removing event listeners
    Runtime:removeEventListener("enterFrame", moveTree)
    Runtime:removeEventListener("enterFrame", moveAwan)
    Runtime:removeEventListener("enterFrame", moveBird)
    Runtime:removeEventListener("touch", makeDinoJump)
    Runtime:removeEventListener("collision", onCollision)

    -- Stop animations
    dino_run:pause()
    bird:pause()
end

-- function to restart the game
local function restartGame(event)
    if event.phase == "ended" then
        -- Reset dino position and animation
        dino_run.x = 50
        dino_run.y = ground.y - (94 * 0.7) / 2
        dino_run:setSequence("run")
        dino_run:play()
        dino_run.isGround = true

        -- Reset tree position
        tree.x = display.contentWidth + 250

        -- Reset bird position
        bird.x = display.contentWidth + 140
        bird.y = math.random(22, 100)
        bird:play()

        -- Reset awan position
        awan.x = display.contentWidth + 150
        awan.y = math.random(22, 100)

        -- Reset score
        score = 0
        scoreText.text = "Score = " .. score

        -- Re-enable the game loop
        Runtime:addEventListener("enterFrame", moveTree)
        Runtime:addEventListener("enterFrame", moveAwan)
        Runtime:addEventListener("enterFrame", moveBird)
        Runtime:addEventListener("touch", makeDinoJump)
        Runtime:addEventListener("collision", onCollision)

        -- Remove the game over text and restart button
        event.target:removeSelf() -- remove restart button
        gameOverText:removeSelf() -- remove game over text
    end
    return true
end


-- function to display game over screen
local function showGameOver()
    stopGame()

    gameOverText = display.newText("Permainan Berakhir", display.contentCenterX, display.contentCenterY - 80,
        pixelFont,
        40)

    -- Add a restart button
    local restartButton = display.newText("Restart", display.contentCenterX, display.contentCenterY,
        pixelFont, 30)
    restartButton:setFillColor(unpack(YELLOW))
    restartButton:addEventListener("touch", restartGame)
end

-- event untuk check collision
local function onGameOver(event)
    local phase = event.phase

    if phase == "began" then
        local ob1 = event.object1
        local ob2 = event.object2

        if (ob1.id == "dino" and ob2.id == "tree") or (ob1.id == "tree" and ob2.id == "dino") then
            showGameOver() -- Call game over function when collision detected
        end
    end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
    local sceneGroup = self.view

    -- game variable
    pixelFont = "./font/Pixel Font.ttf"
    previousTime = system.getTimer()
    previousTimeAwan = system.getTimer()
    previousTimeBird = system.getTimer()
    score = 0
    scoreText = display.newText(sceneGroup, "Score = " .. score, -37, 28, pixelFont, 20)
    gameOverText = nil

    -- load assets
    jumpSfx = audio.loadSound("./sfx/jump.mp3")
    ground = display.newImageRect(sceneGroup, "./img/garis.png", 2400, 24)
    ground.x = display.contentCenterX
    ground.y = display.contentCenterY + 80
    groundRect = display.newRect(sceneGroup, 0, ground.y + 30, 100, 24)
    groundRect:setFillColor(0.5)
    physics.addBody(groundRect, "static", { friction = 0.5, bounce = 0 })

    -- environment
    awan = display.newImageRect(sceneGroup, "./img/awan.png", 84, 27)
    awan:scale(0.7, 0.7)
    awan.x = display.contentWidth + 150
    awan.y = math.random(22, 100)

    bird_sheet = graphics.newImageSheet("./img/burung.png", {
        width = 184 / 2,
        height = 80,
        numFrames = 2
    })
    bird = display.newSprite(sceneGroup, bird_sheet, {
        {
            name = "fly",
            start = 1,
            count = 2,
            time = 400,
            loopCount = 0,
            loopDirection = "forward"
        }
    })
    bird:scale(0.4, 0.4)
    bird.x = display.contentWidth + 140
    bird.y = math.random(22, 100)
    bird:play()

    tree = display.newImageRect(sceneGroup, "./img/tree.png", 49, 93)
    tree:scale(0.7, 0.7)
    tree.y = 215
    tree.x = display.contentWidth + 250
    physics.addBody(tree, "dynamic", { radius = 10 })
    tree.gravityScale = 0
    tree.id = "tree"

    dino_sprite = graphics.newImageSheet("./img/dino_run.png",
        {
            width = 440 / 5,
            height = 94,
            numFrames = 5
        })

    dino_run = display.newSprite(sceneGroup, dino_sprite, {
        {
            name = "idle",
            start = 1,
            count = 1,
            time = 500,
            loopCount = 0,
            loopDirection = "forward"
        }
        ,
        {
            name = "run",
            start = 1,
            count = 4,
            time = 500,
            loopCount = 0,
            loopDirection = "forward"
        }
    })

    dino_run.x = 50
    dino_run.y = ground.y - (94 * 0.7) / 2
    dino_run:scale(0.7, 0.7)
    dino_run:setSequence("run")

    physics.addBody(dino_run, "dynamic", { density = 1.0, friction = 0.3, bounce = 0 })
    dino_run.isFixedRotation = true
    dino_run.id = "dino"
    dino_run.isGround = true
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        dino_run:play()
    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
        Runtime:addEventListener("touch", makeDinoJump)
        Runtime:addEventListener("enterFrame", moveTree)
        Runtime:addEventListener("enterFrame", moveAwan)
        Runtime:addEventListener("enterFrame", moveBird)
        Runtime:addEventListener("collision", onGameOver)
        Runtime:addEventListener("collision", onCollision)
    end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
