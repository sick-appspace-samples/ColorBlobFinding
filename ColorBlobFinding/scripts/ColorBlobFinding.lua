--[[----------------------------------------------------------------------------

  Application Name:
  ColorBlobFinding

  Description:
  Finding blue objects on dark background.
  
  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  To run this sample a device with SICK Algorithm API is necessary.
  For example InspectorP or SIM4000 with latest firmware. Alternatively the
  Emulator on AppStudio 2.2 or higher can be used.

  More Information:
  Tutorial "Algorithms - Color".

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 500

-- Creating viewer
local viewer = View.create()
viewer:setID('viewer2D')

-- Setting up graphical overlay attributes
local decoration = View.ShapeDecoration.create()
decoration:setLineColor(0, 230, 0) -- Green
decoration:setLineWidth(4)

local textDecoration = View.TextDecoration.create()
textDecoration:setSize(50)
textDecoration:setPosition(20, 50)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

-- Viewing image with text label and delay
--@show(img:Image, name:string)
local function show(img, name)
  viewer:addImage(img)
  viewer:addText(name, textDecoration)
  viewer:present()
  Script.sleep(DELAY * 2)
end

local function main()
  local img = Image.load('resources/ColorBlobFinding.bmp')
  viewer:add(img)
  viewer:present()
  Script.sleep(DELAY * 2) -- for demonstration purpose only

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

  local coloredForeground = Image.PixelRegion.getDifference(foreground, nonColoredForeground)
  show(coloredForeground:toImage(S), 'Colored foreground')

  -- Threshold on colored foreground on hue to find blue only (excluding white/gray)
  local blueRegion = H:threshold(90, 107, coloredForeground)
  show(blueRegion:toImage(H), 'Blue objects')

  -- Labelling blue objects (blobs)
  local blueObjects = blueRegion:findConnected(500)
  -- Drawing bounding box around each object
  local imgID = viewer:addImage(img)
  for i = 1, #blueObjects do
    local boundingBox = blueObjects[i]:getBoundingBoxOriented(H)
    viewer:addShape(boundingBox, decoration, nil, imgID)
    Script.sleep(DELAY) -- for demonstration purpose only
    viewer:present() -- presenting single steps
  end
  print(#blueObjects .. ' blue objects found')
  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
