-- Import dependency
local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

require("backgroundList")
require("data")

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local variables go Here

local back;
local middle;
local front;

local resizer = display.contentHeight/320

local numOfBackgrounds = #getBackgroundList(); --Number you want to include
local bgPreview;
local chosenBG;
local counter;
local container;

local buttons;
local rightButton;
local leftButton;
local selectButton;

local pbackground;
local preview;

local sorryclosed;
local stopgaptext;
local firsttime = true;

local notifications;
-- -------------------------------------------------------------------------------

-- Non-scene functions go Here
function setUpNotifications()
    local boughtNotice = display.newImageRect("img/icons/UIIcons/buy.png", 150, 150)
    boughtNotice.x = display.contentCenterX
    boughtNotice.y = display.contentCenterY
    boughtNotice.alpha = 0

    notifications = boughtNotice
    return notifications
end

function buyNotice()
    notifications.alpha = 1
    transition.fadeOut( notifications, { time=500 } )
end


function getChosenBG()
    return chosenBG
end

function buttonClicked(event)
    print(event.target.name)
    if event.phase == "ended" then
        if event.target.name == "right" then
            counter = counter%numOfBackgrounds+1
            updatePreview()
            print(getBackgroundInfo(counter)[1])
        elseif event.target.name == "left" then
            if counter == 1 then
                counter = numOfBackgrounds
            else
                counter = counter-1
            end
            print(getBackgroundInfo(counter)[1])
            updatePreview()
        else
            buyNotice()
            chosenBG = getBackgroundInfo(counter)[1]
            saveBackground()
        end
    end
end

function updatePreview()
    bgPreview = getBackgroundInfo(counter)
    
    width = bgPreview[2]*resizer
    height = bgPreview[3]*resizer
    imageDir = bgPreview[1]

    container:remove(pbackground)
    pbackground = display.newImage(imageDir)
    pbackground:scale(display.contentWidth/pbackground.width, display.contentHeight/pbackground.height )
    container:insert(pbackground)
end

-- -------------------------------------------------------------------------------

function widget.newPanel(options)                                    
    pbackground = display.newImage(options.imageDir)
    container = display.newContainer(options.width, options.height)
    
    if options.type == "preview" then
        pbackground:scale(display.contentWidth/pbackground.width, display.contentHeight/pbackground.height )
    end

    container:insert(pbackground)
    container.x = display.contentCenterX + options.x
    container.y = display.contentCenterY + options.y
    container.name = options.name
    return container
end

function setUpPreview()
    counter = 1
    bgPreview = getBackgroundInfo(counter)

    preview = widget.newPanel {
        name = "preview",
        x = 0*resizer,
        y = 0*resizer,
        width = display.contentWidth,
        height = display.contentHeight,
        imageDir = bgPreview[1]
    }

    preview.x, preview.y = display.contentCenterX, display.contentCenterY
end

function setUpButtons()
    buttons = display.newGroup()

    rightButton = widget.newPanel {
        name = "right",
        width = 800*resizer,
        height = 718*resizer,
        imageDir = "img/icons/UIIcons/rightbutton.png",
        x = 225*resizer,
        y = 0*resizer
    }

    rightButton.x, rightButton.y = display.contentCenterX + (225*resizer), display.contentCenterY

    rightButton:scale(
                (display.contentWidth/rightButton.width)*0.2,
                (display.contentHeight/rightButton.height)*0.2
                )

    buttons:insert(rightButton)

    leftButton = widget.newPanel {
        name = "left",
        width = 800*resizer,
        height = 700*resizer,
        imageDir = "img/icons/UIIcons/leftbutton.png",
        x = -225*resizer,
        y = 0*resizer
    }

    leftButton.x, leftButton.y = display.contentCenterX - (225*resizer), display.contentCenterY

    leftButton:scale(
                (display.contentWidth/leftButton.width)*0.2,
                (display.contentHeight/leftButton.height)*0.2
                )

    buttons:insert(leftButton)

    selectButton = widget.newPanel {
        name = "select",
        width = 300*resizer,
        height = 72*resizer,
        imageDir = "img/icons/UIIcons/select.png",
        x = 0*resizer,
        y = 125*resizer
    }

    selectButton.x, selectButton.y = display.contentCenterX, display.contentCenterY + (125*resizer)

    selectButton:scale(
                (display.contentWidth/selectButton.width)*0.30,
                (display.contentHeight/selectButton.height)*0.15
                )

    buttons:insert(selectButton)

end

function addBGListeners()
    -- Set up all Event Listeners
    rightButton:addEventListener("touch", buttonClicked)
    leftButton:addEventListener("touch", buttonClicked)
    selectButton:addEventListener("touch", buttonClicked)
end

-- -------------------------------------------------------------------------------

-- Scene functions go Here

function scene:create( event )
	local sceneGroup = self.view

    -- Setup layer
    back = display.newGroup()
    middle = display.newGroup()
    front = display.newGroup()

    -- Set preview
    setUpButtons()
    setUpPreview()

    -- Set monster
    monster = getMonster()
    setMonsterLocation(0,50)
        
    addBGListeners()



    notifications = setUpNotifications()
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
        --- UNTIL BUG IS FIXED
        firstTime = getVisitedCustBG()
        if firstTime == true then
            sorryclosed = widget.newPanel {
            name = "bug",
            x = 0*resizer,
            y = 0*resizer,
            width = 400*resizer,
            height = 200*resizer,
            imageDir = "img/icons/UIIcons/sorryclosed.png"
            }
            sorryclosed.x = display.contentCenterX
            sorryclosed.y = display.contentCenterY
            sorryclosed:scale(0.5*resizer, 0.5*resizer)

            stopgaptext = display.newText("Go to another scene and\ncome back for temp Bug fix!", display.contentCenterX+15*resizer, display.contentCenterY-100*resizer, 400*resizer, 0, "Helvetica", 30*resizer, "center")
            stopgaptext:setFillColor( 0.0, 0.0, 0.0 )
            stopgaptext.alpha = 1
        end
        -- Add display objects into group
        -- ============BACK===============
        back:insert(preview)
        -- ===========MIDDLE==============
        middle:insert(buttons)
        -- ===========FRONT===============
        front:insert(monster)
        front:insert(notifications)
        -- ===============================
        sceneGroup:insert(back)
        sceneGroup:insert(middle)
        sceneGroup:insert(front)
        ---

        composer.showOverlay("menubar")
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
	local sceneGroup = self.view
    --temp for bug
    if sorryclosed ~= nil then
        sorryclosed:removeSelf()
    end
    if stopgaptext ~= nil then
        stopgaptext:removeSelf()
    end
	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene