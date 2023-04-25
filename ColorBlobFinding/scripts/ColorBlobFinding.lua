
--Start of Global Scope---------------------------------------------------------

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 1000

-- Creating viewer
local viewer = View.create()

-- Setting up graphical overlay attributes
local decoration = View.ShapeDecoration.create()
decoration:setLineColor(0, 230, 0) -- Green
decoration:setLineWidth(4)

local textDecoration = View.TextDecoration.create()
textDecoration:setSize(50)
textDecoration:setPosition(20, 50)
textDecoration:setColor(0, 220, 0)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

--- Viewing image with text label and delay
---@param img Image
---@param name string
local function show(img, name)
  viewer:clear()
  viewer:addImage(img)
  viewer:addText(name, textDecoration)
  viewer:present()
  Script.sleep(DELAY)
end

local function main()
  local img = Image.load('resources/ColorBlobFinding.bmp')
  show(img, 'Input image')

  -- Converting to HSV color space (Hue, Saturation, Value)
  local H,  S, V = Image.toHSV(img)
  show(H, 'Hue') -- View image with text label and delay
  show(S, 'Saturation')
  show(V, 'Value')

  -- Threshold on intensity value to find foreground (all objects)
  local foreground = V:threshold(50, 255)
  show(foreground:toImage(V), 'Foreground')

  -- Threshold on saturation to differentiate between colored and non-colored objects
  local nonColoredForeground = S:threshold(0, 40, foreground)
  show(nonColoredForeground:toImage(S), 'Non-colored foreground')

  local coloredForeground = foreground:getDifference(nonColoredForeground)
  show(coloredForeground:toImage(S), 'Colored foreground')

  -- Threshold on colored foreground on hue to find blue only (excluding white/gray)
  local blueRegion = H:threshold(90, 107, coloredForeground)
  show(blueRegion:toImage(H), 'Blue objects')

  -- Labelling blue objects (blobs)
  local blueObjects = blueRegion:findConnected(500)
  -- Drawing bounding box around each object
  viewer:clear()
  viewer:addImage(img)
  local boundingBoxes = blueObjects:getBoundingBoxOriented(H)
  viewer:addShape(boundingBoxes, decoration)
  viewer:present() -- presenting single steps

  print(#blueObjects .. ' blue objects found')
  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
