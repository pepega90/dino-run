local composer = require("composer")

local scene = composer.newScene()
require "common"

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- change background
display.setDefault("background", 0.5, 0.5, 0.5)

-- event method
local function playGame()
    composer.gotoScene("game", { time = 900, effect = "crossFade" });
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
    local sceneGroup = self.view
    -- game variable
    local pixelFont = "./font/Pixel Font.ttf"
    menuText = display.newText(sceneGroup, "Dino Run", display.contentCenterX, display.contentCenterY - 100,
        pixelFont, 40)
    playText = display.newText(sceneGroup, "Play", display.contentCenterX, display.contentCenterY, pixelFont,
        30)
    credit = display.newText(sceneGroup, "made by aji mustofa @pepega90", display.contentCenterX,
        display.contentHeight - 25,
        pixelFont, 20)
    credit:setFillColor(unpack(YELLOW))
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif (phase == "did") then
        playText:addEventListener("touch", playGame)
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
