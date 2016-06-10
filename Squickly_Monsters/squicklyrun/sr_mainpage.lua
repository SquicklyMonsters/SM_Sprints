-- Import dependency
local composer = require( "composer" )
local scene = composer.newScene()
require( "squicklyrun.sr_background" )

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------
-- Local variables go Here

local screen;
local player;

-- -------------------------------------------------------------------------------
-- Scene functions go Here

function scene:create( event )
	local sceneGroup = self.view

	setupBackground()
	setupGround()
	setupObstaclesAndEnemies()
	setupSprite()
	setupScoreAndGameOver()

	screen = getScreenLayer()
	player = getPlayerLayer()

	sceneGroup:insert( screen )
	-- sceneGroup:insert( player )

	timer.performWithDelay(1, update, -1)
	Runtime:addEventListener("touch", touched, -1)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
        composer.showOverlay("menubar")
		restartGame()
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
        --composer.hideOverlay()
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene