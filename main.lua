--[[ 
Dino Dig! A game jam project based on the themes "Find and put back together" and "Dinosaur".

Task: Find the scatter pieces of a dinosaur skeleton in the sand! There are 5 pieces, and
some piece might be buried further than others.

Skull - 1x1
Tail - 1x2
Hand - 2x1
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

--Allows different sequences of random numbers for the board
math.randomseed(os.time())

--sprites
menubg = love.graphics.newImage("Assets/Art/Titlecard.png")
winbg = love.graphics.newImage("Assets/Art/Winscreen.png")
losebg = love.graphics.newImage("Assets/Art/Losescreen.png")
dig1 = love.graphics.newImage("Assets/Art/recLight.png")
dig2 = love.graphics.newImage("Assets/Art/recDark.png")
dig3 = love.graphics.newImage("Assets/Art/recDarkest.png")
gameUI = love.graphics.newImage("Assets/Art/UI-BG.png")
headspr = love.graphics.newImage("Assets/Art/temphead1.png")
handspr = { love.graphics.newImage("Assets/Art/temphand1.png"), love.graphics.newImage("Assets/Art/temphand2.png") }
tailspr = { love.graphics.newImage("Assets/Art/temptail1.png"), love.graphics.newImage("Assets/Art/temptail2.png") }
legspr = { love.graphics.newImage("Assets/Art/templeg1.png"), love.graphics.newImage("Assets/Art/templeg2.png"), love.graphics.newImage("Assets/Art/templeg3.png") }
bodyspr = { love.graphics.newImage("Assets/Art/tempbody1.png"), love.graphics.newImage("Assets/Art/tempbody2.png"), love.graphics.newImage("Assets/Art/tempbody3.png"), love.graphics.newImage("Assets/Art/tempbody4.png") }
tentspr = love.graphics.newImage("Assets/Art/tent.png")

boardImages = {}
i = 1
while i <= 25 do
	boardImages[i] = dig1
	i = i+1
end
boardImages[13] = tentspr
--sounds
digsfx = love.audio.newSource("Assets/Sound/Digging noise.wav", "static")
--bgm = love.audio.newSource("Assets/Sound/bgm.wav", "stream")

--board assets and global variables
board = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
--First number in each location table represents depth, others represent position in board table
headLoc = {2, 0, 0}
bodyLoc = {1, 0, 0, 0, 0, 0}
tailLoc = {1, 0, 0, 0}
handLoc = {2, 0, 0, 0}
legLoc = {2, 0, 0, 0, 0}
day = 1
total = 12
moves = total
pieces = 0

--Weird, but having the random generation here allows it to actually function
bodytable = {1, 2, 3, 4, 6, 9, 11, 14, 16, 17, 18, 19}
legtable = {1, 2, 3, 4, 6, 9, 11, 13, 14, 16, 17, 18, 19}
handtable = {1, 2, 3, 4, 6, 7, 8, 9, 11, 14, 16, 17, 18, 19, 21, 22, 23, 24}
tailtable = {1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20}
headtable = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25}
--Choose largest options first
bodyorigin = math.random(#bodytable)
legorigin = math.random(#legtable)
bodyLoc[3] = bodytable[bodyorigin]
bodyLoc[4] = bodytable[bodyorigin]+1
bodyLoc[5] = bodytable[bodyorigin]+5
bodyLoc[6] = bodytable[bodyorigin]+6
legLoc[3] = legtable[legorigin]+1
legLoc[4] = legtable[legorigin]+5
legLoc[5] = legtable[legorigin]+6

handorigin = 0
tailorigin = 0
headorigin = 0

k = true
while k do
	handorigin = math.random(#handtable)
	hL = handtable[handorigin]
	if hL ~= legLoc[3] and hL ~= legLoc[4] and hL ~= legLoc[5] and hL ~= legLoc[3]-1 and hL ~= legLoc[4]-1 then 
		k = false
	end
end
handLoc = {2, 0, handtable[handorigin], handtable[handorigin]+1}

k = true
while k do
	headorigin = math.random(#headtable)
	heL = headtable[headorigin]
	if heL ~= legLoc[3] and heL ~= legLoc[4] and heL ~= legLoc[5] and heL ~= handLoc[3] and heL ~= handLoc[4] then 
		k = false
	end
end
headLoc = {2, 0, headtable[headorigin]}

k = true
while k do
	tailorigin = math.random(#tailtable)
	tL = tailtable[tailorigin]
	if tL ~= bodyLoc[3] and tL ~= bodyLoc[4] and tL ~= bodyLoc[5] and tL ~= bodyLoc[6] and tL ~= bodyLoc[3]-5  and tL ~= bodyLoc[4]-5 then 
		k = false
	end
end
tailLoc = {1, 0, tailtable[tailorigin], tailtable[tailorigin]+5}

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
	love.graphics.reset()
	love.graphics.draw(menubg)
end

--Allows menu navigation
function menu:mousepressed()

	if love.mouse.getX() >= 20 and love.mouse.getX() <= 180 then
		if love.mouse.getY() >= 80 and love.mouse.getY() <= 145 then
			Gamestate.switch(game)
		end
		if love.mouse.getY() >= 195 and love.mouse.getY() <= 260 then
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
--[[
--Will randomize the locations of each fossil piece, and make sure they don't overlap
function game:load()
	--Body cannot fit into 5, 7, 8, 10, 12, 13, 15, 20, 21-25
	--Leg cannot fit into 5, 7, 8, 10, 12, 15, 20, 21-25
	--Hand cannot fit into 5, 10, 12, 13, 15, 20, 25
	--Tail cannot fit into 8, 13, 21-25
	--Head cannot fit into 13
	bodytable = {1, 2, 3, 4, 6, 9, 11, 14, 16, 17, 18, 19}
	legtable = {1, 2, 3, 4, 6, 9, 11, 13, 14, 16, 17, 18, 19}
	handtable = {1, 2, 3, 4, 6, 7, 8, 9, 11, 14, 16, 17, 18, 19, 21, 22, 23, 24}
	tailtable = {1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20}
	headtable = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25}
	--Choose largest options first
	--bodyorigin = math.random(#bodytable)
	--legorigin = math.random(#legtable)
	legorigin = 1
	bodyorigin = 12
	bodyLoc[3] = bodytable[bodyorigin]
	bodyLoc[4] = bodytable[bodyorigin]+1
	bodyLoc[5] = bodytable[bodyorigin]+5
	bodyLoc[6] = bodytable[bodyorigin]+6
	legLoc[3] = legtable[legorigin]+1
	legLoc[4] = legtable[legorigin]+5
	legLoc[5] = legtable[legorigin]+6
	
	handorigin = 0
	tailorigin = 0
	headorigin = 0
	
	k = true
	while k do
		handorigin = math.random(#handtable)
		hL = handtable[handorigin]
		if hL ~= legLoc[3] and hL ~= legLoc[4] and hL ~= legLoc[5] and hL ~= legLoc[3]+1 and hL ~= legLoc[4]+1 then 
			k = false
		end
	end
	handLoc = {2, 0, handtable[handorigin], handtable[handorigin]+1}
	
	k = true
	while k do
		headorigin = math.random(#headtable)
		heL = headtable[headorigin]
		if heL ~= legLoc[3] and heL ~= legLoc[4] and heL ~= legLoc[5] and heL ~= handLoc[3] and heL ~= handLoc[4] then 
			k = false
		end
	end
	headLoc = {2, 0, headtable[headorigin]}
	
	k = true
	while k do
		tailorigin = math.random(#tailtable)
		tL = tailtable[tailorigin]
		if tL ~= bodyLoc[3] and tL ~= bodyLoc[4] and tL ~= legLoc[5] and tL ~= bodyLoc[6] and tL ~= bodyLoc[3]-5  and tL ~= bodyLoc[4]-5 then 
			k = false
		end
	end
	tailLoc = {1, 0, tailtable[tailorigin], tailtable[tailorigin]+5}

end
]]
--This will draw the board, and the game UI
function game:draw()
	love.graphics.draw(gameUI)
	x = 1
	y = 0
	while x <= 25 do
		love.graphics.draw(boardImages[x], ((x-1)%5)*100, (y%5)*100+100)
		--[[
		love.graphics.setColor(0, 0, 255)
		love.graphics.printf(""..(x), ((x-1)%5)*100, (y%5)*100+100, 100)
		love.graphics.reset()
		]]--
		if x%5 == 0 then
			y = y+1
		end
		x = x+1
	end
	--Vertical grid lines
	love.graphics.setColor(0, 0, 0)
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
	love.graphics.reset()
end

--Updates the Day/Move number
function updatemove()
	if moves ~= 0 then 
		moves = moves - 1
	end
	if moves == 0 and day ~= 3 then
		moves = total
		day = day+1
		filled = 0
		f = math.random(25)
		while filled < 2 do
			if board[f] > 0 then
				board[f] = board[f]-1
				if board[f] == 1 then
					boardImages[f] = dig2
				elseif board[f] == 0 then
					boardImages[f] = dig1
				end
				filled = filled+1
			end
			f = math.random(25)
		end
		filled = 0
	end
end

function DIV(a,b)
    return (a - a % b) / b
end

--subroutine for changing the board images
function checkdepth(a, x, y)
	if a == 1 then
		if x+y == bodyLoc[3] and bodyLoc[2] ~= 4 then
			bodyLoc[2] = bodyLoc[2] + 1
			return bodyspr[1]
		elseif x+y == bodyLoc[4] and bodyLoc[2] ~= 4 then
			bodyLoc[2] = bodyLoc[2] + 1
			return bodyspr[2]
		elseif x+y == bodyLoc[5] and bodyLoc[2] ~= 4 then
			bodyLoc[2] = bodyLoc[2] + 1
			return bodyspr[3]
		elseif x+y == bodyLoc[6] and bodyLoc[2] ~= 4 then
			bodyLoc[2] = bodyLoc[2] + 1
			return bodyspr[4]
		elseif x+y == tailLoc[3] and tailLoc[2] ~= 2 then
			tailLoc[2] = tailLoc[2] + 1
			return tailspr[1]
		elseif x+y == tailLoc[4] and tailLoc[2] ~= 2 then
			tailLoc[2] = tailLoc[2] + 1
			return tailspr[2]
		else
			return dig2
		end
	elseif a == 2 then
		if x+y == legLoc[3] and legLoc[2] ~= 3 then
			legLoc[2] = legLoc[2] + 1
			return legspr[1]
		elseif x+y == legLoc[4] and legLoc[2] ~= 3 then
			legLoc[2] = legLoc[2] + 1
			return legspr[2]
		elseif x+y == legLoc[5] and legLoc[2] ~= 3 then
			legLoc[2] = legLoc[2] + 1
			return legspr[3]
		elseif x+y == handLoc[3] and handLoc[2] ~= 2 then
			handLoc[2] = handLoc[2] + 1
			return handspr[1]
		elseif x+y == handLoc[4] and handLoc[2] ~= 2 then
			handLoc[2] = handLoc[2] + 1
			return handspr[2]
		elseif x+y == headLoc[3] and headLoc[2] ~= 1 then
			headLoc[2] = headLoc[2] + 1
			return headspr
		else
			return dig3
		end
	end
end

--Checks the mouse position and updates the board state
function game:mousepressed()
	x = DIV(love.mouse.getX(), 100)+1
	y = love.mouse.getY()
	if y > 100 then
		y = 5*DIV(y-100, 100)
		if board[x+y] < 2 and x+y ~= 13 then
			board[x+y] = board[x+y] + 1
			updatemove()
			if board[x+y] == 1 then
				image = checkdepth(1, x, y)
				boardImages[x+y] = image
				elseif board[x+y] == 2 then
				image = checkdepth(2, x, y)
				boardImages[x+y] = image
			end
		end
	end
	
	if headLoc[2] == 1 then 
		pieces = pieces + 1
		headLoc[2] = 900
	end
	if handLoc[2] == 2 then 
		pieces = pieces + 1
		handLoc[2] = 900
	end
	if tailLoc[2] == 2 then 
		pieces = pieces + 1
		tailLoc[2] = 900
	end
	if legLoc[2] == 3 then 
		pieces = pieces + 1
		legLoc[2] = 900
	end
	if bodyLoc[2] == 4 then 
		pieces = pieces + 1
		bodyLoc[2] = 900
	end
	
	if pieces == 5 then
		Gamestate.switch(win)
	elseif moves == 0 and day == 3 then
		Gamestate.switch(lose)
	end
	
end

function lose:draw()
	love.graphics.reset()
	love.graphics.draw(losebg)
end

function win:draw()
	love.graphics.reset()
	love.graphics.draw(winbg)
end
