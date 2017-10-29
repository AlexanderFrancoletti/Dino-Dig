--[[ 
Dino Dig! A game jam project based on the themes "Find and put back together" and "Dinosaur".

Task: Find the scatter pieces of a dinosaur skeleton in the sand! There are 5 pieces, and
some piece might be buried further than others.

Skull - 1x1
Tail - 1x2
Hand - 1x2
Body - 2x2
Foot - 2x2 elbow piece

]]--

Gamestate = require "hump.gamestate"

--gamestates
local menu = {}
local instruction = {}
local game = {}
local lose = {}
local win = {}

--sprites

--sounds

--board assets and global variables
board = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
--First number in each location table represents depth, others represent position in board table
headLoc = {0, 0}
bodyLoc = {0, 0, 0, 0, 0}
tailLoc = {0, 0, 0}
handLoc = {0, 0, 0}
footLoc = {0, 0, 0, 0}
day = 1
total = 12
moves = total
pieces = 0


function love.load(args)
	--Set window size and initial gamestate
	love.window.setTitle("Dino Dig!")
	love.window.setMode(500, 600)
	
	Gamestate.registerEvents()
	Gamestate.switch(menu)

end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
end

function menu:draw()
	love.graphics.setColor(0, 150, 0)
	love.graphics.rectangle("fill", 100, 100, 200, 50)
	love.graphics.rectangle("fill", 100, 200, 200, 50)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Start", 120, 115, 0, 1.5, 1.5)
	love.graphics.print("Instructions", 120, 215, 0, 1.5, 1.5)

end

--Allows menu navigation
function menu:mousepressed()

	if love.mouse.getX() >= 100 and love.mouse.getX() <= 300 then
		if love.mouse.getY() >= 100 and love.mouse.getY() <= 150 then
			Gamestate.switch(game)
		end
		if love.mouse.getY() >= 200 and love.mouse.getY() <= 250 then
			Gamestate.switch(instruction)
		end
	end
end

--Draws the instructions on the instruction screen
function instruction:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.printf("There are scattered dinosaur bones all throughout the area! Find the bones by digging into the ground. Some may be buried deeper than others. You have 3 days to find all the bones. When the day ends, some sand will come back.\nClick on a space to dig there", 100, 115, 200, "left", 0, 1.5, 1.5)
	love.graphics.setColor(0, 150, 0)
	love.graphics.rectangle("fill", 100, 400, 200, 50)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Main Menu", 120, 415, 0, 1.5, 1.5)
end

--Allows menu navigation
function instruction:mousepressed()
	if love.mouse.getX() >= 100 and love.mouse.getX() <= 300 then
		if love.mouse.getY() >= 400 and love.mouse.getY() <= 450 then
			Gamestate.switch(menu)
		end
	end
end

--Will randomize the locations of each fossil piece, and make sure they don't overlap
function game:load()
	
	
end

--This will draw the board, and the game UI
function game:draw()
	love.graphics.setColor(50, 50, 0)
	love.graphics.rectangle("fill", 0, 0, 500, 600)
	love.graphics.setColor(0, 0, 0)
	--Vertical grid lines
	love.graphics.line(100, 100, 100, 700)
	love.graphics.line(400, 100, 400, 700)
	love.graphics.line(300, 100, 300, 700)
	love.graphics.line(200, 100, 200, 700)
	--Horizontal grid lines
	love.graphics.line(0, 500, 800, 500)
	love.graphics.line(0, 400, 800, 400)
	love.graphics.line(0, 300, 800, 300)
	love.graphics.line(0, 200, 800, 200)
	love.graphics.line(0, 100, 800, 100)
	love.graphics.setColor(255, 0, 0)
	love.graphics.printf("Moves: "..moves, 50, 50, 100)
	love.graphics.printf("Day: "..day, 200, 50, 100)
	love.graphics.printf("Pieces: "..pieces, 350, 50, 100)
	
end

--Checks the mouse position and updates the board state
function game:mousepressed()
	
	
	--Game progress update script
	if moves ~= 0 then 
		moves = moves - 1
	end
	if pieces == 5 then
		Gamestate.switch(win)
	end
	if moves == 0 and day ~= 3 then
		moves = total
		day = day+1
	elseif moves == 0 and day == 3 then
		Gamestate.switch(lose)
	end
end

function lose:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.printf("Lose screen", 100, 100, 50)
end

function win:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.printf("Win screen", 100, 100, 50)
end











