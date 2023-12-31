-- yPokeStats 
-- by YliNG
-- v0.1
-- https://github.com/yling

dofile "data/tables.lua" -- Tables with games data, and various data - including names
dofile "data/memory.lua" -- Functions and Pokemon table generation

-- Probably bad formatting place, but I suck at code and this makes it work
local counter = 0 -- Counter for GPT Color
local gptLoading = 0


local gamedata = getGameInfo() -- Gets game info
version, lan, gen, sel = gamedata[1],gamedata[2],gamedata[3],gamedata[4]

settings={}
settings["pos"]={} -- Fixed blocks coordinates {x,y}{x,y}
settings["pos"][1]={2,2}
settings["pos"][2]={10,sel[2]/6}
settings["pos"][3]={2,sel[2]/64*61}
settings["key"]={	"J", -- Switch mode (EV,IV,Stats)
                    "K", -- Switch status (Enemy / player)
                    "L",  -- Sub Status + (Pokemon Slot)
                    "P", -- Toggle + display
                    "H" } -- Chat GPT output


print("Welcome to yPokeStats Unified ")


if version ~= 0 and games[version][lan] ~= nil then    
    print("Game :", games[version][lan][1])
    
	status, mode, help=1,1,1 -- Default status and substatus - 1,1,1 is Player's first Pokémon
	substatus={1,1,1}
	lastpid,lastchecksum=0,0 -- Will be useful to avoid re-loading the same pokemon over and over again
	count,clockcount,totalclocktime,lastclocktime,highestclocktime,yling=0,0,0,0,0,0 -- Monitoring - useless
    lastPokemon = 0

    local prev={} -- Preparing the input tables - allows to check if a key has been pressed
    prev=input.get()
    
    function main() -- Main function - display (check memory.lua for calculations)
        nClock = os.clock() -- Set the clock (for performance monitoring -- useless)
        statusChange(input.get()) -- Check for key input and changes status
		
		if help==1 then -- Help screen display
			gui.box(settings["pos"][2][1]-5,settings["pos"][2][2]-5,sel[1]-5,settings["pos"][2][2]+sel[2]/2,"#ffffcc","#ffcc33")
			gui.text(settings["pos"][2][1],settings["pos"][2][2],"yPokemonStats","#ee82ee")
			gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16,"http://github.com/yling","#87cefa")
			gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16*2,"-+-+-+-+-","#ffcc33")
			gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16*3,settings["key"][1]..": IVs, EVs, Stats and Contest stats",table["colors"][5])
			gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16*4,settings["key"][2]..": Player team / Enemy team",table["colors"][4])
			gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16*5,settings["key"][3]..": Pokemon slot (1-6)",table["colors"][3])
			gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16*6,settings["key"][4]..": Show more data",table["colors"][2])
			gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16*7,settings["key"][5]..": Toggle this menu",table["colors"][1])
        end

		-- Moves we have, pp
		-- Names of both pokemon that are out 
		-- hit points
		-- Stats on both sides, number of pokemon??? 

            start = status==1 and games[version][lan][2]+games[version][lan][4]*(substatus[1]-1) or games[version][lan][3]+games[version][lan][4]*(substatus[2]-1) -- Set the pokemon start adress
			if memory.readdwordunsigned(start) ~= 0 or memory.readbyteunsigned(start) ~= 0 then -- If there's a PID
				if checkLast(lastpid,lastchecksum,start,gen) == 0 or pokemon["species"] == nil then -- If it's not the last loaded PID (cause you know) or if the pokemon data is empty
					pokemon = fetchPokemon(start) -- Fetch pokemon data at adress start
					count=count+1 -- Times data has been fetched from memory (for monitoring - useless)
					lastpid = gen >= 3 and pokemon["pid"] or pokemon["species"] -- Update last loaded PID
					lastchecksum = gen >= 3 and pokemon["checksum"] or pokemon["ivs"]

					myPokemon = fetchPokemon(games[version][lan][2]+games[version][lan][4]*(substatus[1]-1))
					enemyPokemon = fetchPokemon(games[version][lan][3]+games[version][lan][4]*(substatus[2]-1))
                end
                
                -- Permanent display --
				labels = mode == 4 and table["contests"] or table["labels"] -- Load contests labels or stats labels
				tmpcolor = status == 1 and "green" or "red" -- Dirty tmp var for status and substatus color for player of enemy
				tmpletter = status == 1 and "P" or "E" -- Dirty tmp var for status and substatus letter for player of enemy
				tmptext = tmpletter..substatus[1].." ("..table["modes"][mode]..")" -- Dirty tmp var for current mode
                helditem = pokemon["helditem"] == 0 and "none" or table["items"][gen][pokemon["helditem"]]
				
				-- Color change to show ChatGPT is working
				local colorOption = counter % 4
				local gptColor
				if colorOption == 0 then
					gptColor = "red"
				elseif colorOption == 1 then
					gptColor = "green"
				elseif colorOption == 2 then
					gptColor = "blue"
				else
					gptColor = "yellow"
				end


                -- GEN 1 & 2
				if gen <= 2 then
					for i=1,5 do -- For each DV
						gui.text(settings["pos"][1][1]+(i-1)*sel[1]/5,settings["pos"][1][2],table["gen1labels"][i], table["colors"][i]) -- Display label
						gui.text(settings["pos"][1][1]+sel[1]/5/4+(i-1)*sel[1]/5,settings["pos"][1][2], pokemon[table["modesorder"][mode]][i], table["colors"][i])
                        gui.text(settings["pos"][1][1]+sel[1]*4/10,settings["pos"][3][2], tmptext, tmpcolor) -- Display current status (using previously defined dirty temp vars)
						local shiny = pokemon["shiny"] == 1 and "Shiny" or "Not shiny"
						local shinycolor = pokemon["shiny"] == 1 and "green" or "red"
						gui.text(settings["pos"][1][1]+sel[1]*7/10,settings["pos"][3][2],shiny,shinycolor)

					end
                    
                -- GEN 3, 4 and 5
				else
					for i=1,6 do -- For each IV
						gui.text(settings["pos"][1][1]+(i+1)*sel[1]/8,settings["pos"][1][2],labels[i], table["colors"][i]) -- Display label
						gui.text(settings["pos"][1][1]+sel[1]/8/2+(i+1)*sel[1]/8,settings["pos"][1][2], pokemon[table["modesorder"][mode]][i], table["colors"][i]) -- Display current mode stat
						if mode ~= 4 then -- If not in contest mode
							if pokemon["nature"]["inc"]~=pokemon["nature"]["dec"] then -- If nature changes stats
								if i==table["statsorder"][pokemon["nature"]["inc"]+2] then -- If the nature increases current IV
									gui.text(settings["pos"][1][1]+sel[1]/8/2+sel[1]/8*(i+1),settings["pos"][1][2]+3, "__", "green") -- Display a green underline
									elseif i==table["statsorder"][pokemon["nature"]["dec"]+2] then -- If the nature decreases current IV
									gui.text(settings["pos"][1][1]+sel[1]/8/2+sel[1]/8*(i+1),settings["pos"][1][2]+3, "__", "red") -- Display a red underline
								end
								else -- If neutral nature
								if i==table["statsorder"][pokemon["nature"]["inc"]+1] then -- If current IV is HP
									gui.text(settings["pos"][1][1]+sel[1]/8/2+sel[1]/8*(i+1),settings["pos"][1][2]+3, "__", "grey") -- Display grey underline
								end
							end
						end
					end
                    gui.text(settings["pos"][1][1],settings["pos"][1][2], tmptext, tmpcolor) -- Display current status (using previously defined dirty temp vars)
                    gui.text(settings["pos"][1][1]+sel[1]*4/10,settings["pos"][3][2], "PID: "..bit.tohex(lastpid)) -- Last PID
				end






				if input.get()["C"] then
					CKeyMemory = 1
					gptLoading = 1 -- GPT Loading Text Counter
					isMyPokemonDead = 0 
					isEnemyPokemonDead = 0
					
				else 
					if (CKeyMemory == 1) then
						-- Function to build the Pokémon status string
						local function getPokemonStatus(pokemon)
							local stats = {unpack(pokemon["stats"], 2)} -- Excluding the first element from the stats
							local status = tostring(pokemon["speciesname"]) .. " - " .. tostring(pokemon["hp"]["current"]) .. "/" .. tostring(pokemon["hp"]["max"]) .. " " .. tostring(stats) .. " "
							for i = 1, 4 do -- For each move
								if table["move"][pokemon["move"][i]] ~= nil then 
									status = status .. table["move"][pokemon["move"][i]].."#".. i .. " ("..pokemon["pp"][i]..") "
								end
							end
							return status
						end
						
						-- New fetchPokemon to over come lastpid check
						myPokemon = fetchPokemon(games[version][lan][2] + games[version][lan][4] * (substatus[1] - 1))
    					enemyPokemon = fetchPokemon(games[version][lan][3] + games[version][lan][4] * (substatus[2] - 1))

						-- Building status strings for my Pokémon and enemy Pokémon
						local currentPokemonStatus = getPokemonStatus(myPokemon)
						local enemyPokemonStatus = getPokemonStatus(enemyPokemon)

						myCurrentHP = myPokemon["hp"]["current"]
						enemyCurrentHP = enemyPokemon["hp"]["current"]
						if my_current_hp == 0 then
							isMyPokemonDead = 1
						end
						
						if enemy_current_hp == 0 then
							isEnemyPokemonDead = 1
						end
						
					
						-- Combining and printing the statuses
						local combined = currentPokemonStatus .. '** ' .. enemyPokemonStatus
						print("\n")
						print(combined)

						local python_script_path = "ChatGPTCall.py" -- Path to the Python script (updated to match the correct filename)
						local input_data = combined -- Data to send to Python

						-- Function to call the Python script and get a response
						local function call_python(data)
							local command = "echo '" .. data .. "' | python " .. python_script_path
							local handle = io.popen(command)
							local result = handle:read("*a")
							handle:close()
							return result
						end

						print(vba.framecount())
						response_from_python = call_python(input_data)
						gptText = string.sub(response_from_python, 1,-5) .. "!"
						moveNumber = tonumber(string.sub(response_from_python, -3, -3))
						print("Response from Python: " .. response_from_python .."|")
						print(moveNumber)
						
					
						
						

						gptLoading = 0 -- Counter for displaying GPT loading text
						counter = counter + 1 --Counter for UI color change
						CKeyMemory = 0
						inputListener = 1
						storedFrame = emu.framecount()

					end
				end
				
				if (counter == 0 and gptLoading == 0) then
					gptText = "Press C to ask ChatGPT"
				elseif (gptLoading == 1) then
					gptText = "Loading... :)"
				
				end
					
				
				

				






				


				
				
                
                -- All gens
				gui.text(settings["pos"][1][1], settings["pos"][1][2]+sel[2]/16, gptText, gptColor) -- Pkmn National Number, Species name and HP
                frame = version == "POKEMON EMER" and "F. E/R: "..emu.framecount().."/"..memory.readdwordunsigned(0x020249C0) or "F. E: "..emu.framecount()
                gui.text(settings["pos"][3][1],settings["pos"][3][2], frame) -- Emu frame counter
				
                -- "More" menu --
				if more == 1 then
					gui.box(settings["pos"][2][1]-5,settings["pos"][2][2]-5,sel[1]-5,settings["pos"][2][2]+sel[2]/2,"#ffffcc","#ffcc33") -- Cute box 
                    -- For gen 3, 4, 5
					if gen >= 3 then 
						naturen = pokemon["nature"]["nature"] > 16 and pokemon["nature"]["nature"]-16 or pokemon["nature"]["nature"] -- Dirty trick to use types colors for natures
						naturecolor = table["typecolor"][naturen] -- Loading the tricked color
						gui.text(settings["pos"][2][1],settings["pos"][2][2], "Nature")
						gui.text(settings["pos"][2][1]+sel[2]/4,settings["pos"][2][2],table["nature"][pokemon["nature"]["nature"]+1],naturecolor)
                         -- Fetching held item name (if there's one)
						pokerus = pokemon["pokerus"] == 0 and "no" or "yes" -- Jolly little yes or no for Pokerus
						ability = gen == 3 and table["gen3ability"][pokemon["species"]][pokemon["ability"]+1] or pokemon["ability"] -- Fetching proper ability id for Gen 3
						
						gui.text(settings["pos"][2][1]+sel[1]/2,settings["pos"][2][2], "OT ID : "..pokemon["OTTID"])
						gui.text(settings["pos"][2][1]+sel[1]/2,settings["pos"][2][2]+sel[2]/16, "OT SID : "..pokemon["OTSID"])
						gui.text(settings["pos"][2][1]+sel[1]/2,settings["pos"][2][2]+2*sel[2]/16, "XP : "..pokemon["xp"])
						gui.text(settings["pos"][2][1]+sel[1]/2,settings["pos"][2][2]+3*sel[2]/16, "Item : "..helditem)
						gui.text(settings["pos"][2][1]+sel[1]/2,settings["pos"][2][2]+4*sel[2]/16, "Pokerus : "..pokerus)
						gui.text(settings["pos"][2][1]+sel[1]/2,settings["pos"][2][2]+5*sel[2]/16, "Friendship : "..pokemon["friendship"])
						gui.text(settings["pos"][2][1]+sel[1]/2,settings["pos"][2][2]+6*sel[2]/16, "Ability : "..table["ability"][ability])
                        
                    -- For gen 1 & 2
					else
                        gui.text(settings["pos"][2][1],settings["pos"][2][2], "TID: "..pokemon["TID"].." / Item: "..helditem)
						if version == "POKEMON YELL" and status == 1 and pokemon["species"] == 25 or gen == 2 then
							gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16*2, "Friendship : "..pokemon["friendship"])
						end
                    end
                    
                    -- For all gens
					gui.text(settings["pos"][2][1],settings["pos"][2][2]+sel[2]/16, "H.Power")
					gui.text(settings["pos"][2][1]+sel[2]/4,settings["pos"][2][2]+sel[2]/16, table["type"][pokemon["hiddenpower"]["type"]+1].." "..pokemon["hiddenpower"]["base"], table["typecolor"][pokemon["hiddenpower"]["type"]+1])
					gui.text(settings["pos"][2][1],settings["pos"][2][2]+3*sel[2]/16, "Moves:")
					for i=1,4 do -- For each move
						if table["move"][pokemon["move"][i]] ~= nil then 
							gui.text(settings["pos"][2][1],settings["pos"][2][2]+(i+3)*sel[2]/16, table["move"][pokemon["move"][i]].." - "..pokemon["pp"][i].."PP") -- Display name and PP
						end
					end
				end
            else -- No PID found
				if status == 1 then -- If player team just decrement n
					substatus[1] = 1
				elseif status == 2 then -- If enemy
					if substatus[2] == 1 then -- If was trying first enemy go back to player team
						status = 1
					else -- Else decrement n
						substatus[2] = 1
					end
				else -- Shouldn't happen but hey, warn me if it does
					print("Something's wrong.")
				end
				gui.text(settings["pos"][1][1],settings["pos"][1][2],"No Pokemon", "red") -- Beautiful red warning
			end
		
		-- Script performance (useless)
		clocktime = os.clock()-nClock
		clockcount = clockcount + 1
		totalclocktime = totalclocktime+clocktime
		lastclocktime = clocktime ~= 0 and clocktime or lastclocktime
		highestclocktime = clocktime > highestclocktime and clocktime or highestclocktime
		meanclocktime = totalclocktime/clockcount
		if yling==1 then -- I lied, there's a secret key to display script performance, but who cares besides me? (It's Y)
			gui.text(settings["pos"][2][1],2*settings["pos"][2][2],"Last clock time: "..numTruncate(lastclocktime*1000,2).."ms")
			gui.text(settings["pos"][2][1],2*settings["pos"][2][2]+sel[2]/16,"Mean clock time: "..numTruncate(meanclocktime*1000,2).."ms")
			gui.text(settings["pos"][2][1],2*settings["pos"][2][2]+2*sel[2]/16,"Most clock time: "..numTruncate(highestclocktime*1000,2).."ms")
			gui.text(settings["pos"][2][1],2*settings["pos"][2][2]+3*sel[2]/16,"Data fetched: "..count.."x")
        end
	end
else -- Game not in the data table
    if games[version]["E"] ~= nil then
        print("This version is supported, but not in this language. Check gamesdata.lua to add it.")
    else
        print("This game isn't supported. Is it a hackrom ? It might work but you'll have to add it yourself. Check gamesdata.lua")
    end
    print("Version: "..version)
    print("Language: "..bit.tohex(lan))
end





print('hi')




print('hello')

while true do
    gui.register(main)
	if inputListener == 1 then
		joypad.set(1, {A=true})
		emu.frameadvance()
		emu.frameadvance()
		emu.frameadvance()
		emu.frameadvance()
		emu.frameadvance()
		if moveNumber == 1 then
			print("Number 1 works")
			joypad.set(1, {up=true})
			emu.frameadvance()
			joypad.set(1, {left=true})
			emu.frameadvance()
			emu.frameadvance()
			joypad.set(1, {A=true})
			print("Path 1: Pressed A")
			emu.frameadvance()
			inputListener = 0
		end
		if moveNumber == 2 then
			print("Number 2 works")
			joypad.set(1, {up=true})
			emu.frameadvance()
			joypad.set(1, {left=true})
			emu.frameadvance()
			emu.frameadvance()
			joypad.set(1, {right=true})
			emu.frameadvance()
			emu.frameadvance()
			joypad.set(1, {A=true})
			print("Path 2: Pressed Right, then A")
			emu.frameadvance()
			inputListener = 0
		end
		if moveNumber == 3 then
			print("Number 3 works")
			joypad.set(1, {up=true})
			emu.frameadvance()
			joypad.set(1, {left=true})
			emu.frameadvance()
			emu.frameadvance()
			joypad.set(1, {down=true})
			emu.frameadvance()
			emu.frameadvance()
			joypad.set(1, {A=true})
			print("Path 3: Pressed Down, then A")
			emu.frameadvance()
			inputListener = 0
		end
		if moveNumber == 4 then
			print("Number 4 works")
			joypad.set(1, {up=true})
			emu.frameadvance()
			joypad.set(1, {left=true})
			emu.frameadvance()
			emu.frameadvance()
			joypad.set(1, {down=true})
			emu.frameadvance()
			joypad.set(1, {right=true})
			emu.frameadvance()
			emu.frameadvance()
			joypad.set(1, {A=true})
			emu.frameadvance()
			print("Path 4: Pressed Down, then Right, then A")
			inputListener = 0
		end
	end
	emu.frameadvance()
end
