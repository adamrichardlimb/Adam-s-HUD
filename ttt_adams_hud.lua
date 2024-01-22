--[[
	Adams HUD

	A HUD for TTT which seeks to make relevant information clear to the player and bring an aesthetic to TTT.
	This HUD is HEAVILY inspired by CGNick's Payday 2 HUD, which he has stated he considers freeware and only asks you credit him.
	Here's a list of things I stole:

	- Colours
	- Role names
	- Round states
	- Bordered Circle Code
	- The timer trick to get the game to not complain about GAMEMODE not being defined
	- HUDPaint Function

]]--

if CLIENT then
	timer.Simple( 0, function()
		-- Here we go...
		AHUD = {}

		-- Define static stuff we likely will not change
		AHUD.ScrW = ScrW()
		AHUD.ScrH = ScrH()
		AHUD.MatWhite = Material("vgui/white")
		AHUD.Padding = 0.025
		AHUD.Margin = 0.0125
		AHUD.LastDisplayedHealth = -1
		surface.CreateFont( "PD2_24", { font = "Tenby Five", antialias = true, size = 39 } )

		--How long should the health drain animation last?
		--I keep this at 1
		AHUD.HealthAnimFadeInterval = 0.25
		AHUD.HealthAnimTickLength = 0.15
		AHUD.HealthAnimTickInterval = -1
		AHUD.HealthAnimTickCount = -1
		AHUD.HealthAnimTickNumber = -1
		AHUD.HealthAnimNextTick = -1
		AHUD.HealthAnimValue = -1

		-- From the PD2 HUD
		AHUD.ColBlack = Color( 0, 0, 0, 175 )
		AHUD.ColOvertime = Color( 255, 255, 0, 200 )
		AHUD.ColTextBlack = Color( 0, 0, 0, 255 )
		AHUD.ColTextWhite = Color( 255, 255, 255, 200 )
		AHUD.ColTextRed = Color( 255, 100, 100, 200 )
		AHUD.ColTextFade = Color( 255, 255, 255, 50 )

		AHUD.ColRoles = {
			[0] = Color( 200, 255, 150, 220 ),
			[1] = Color( 255, 100, 100, 220 ),
			[2] = Color( 100, 200, 255, 220 ),
		}

		AHUD.Roles = {
			[0] = "INNOCENT",
			[1] = "TRAITOR",
			[2] = "DETECTIVE",
		}

		AHUD.RoundStates = {
			[ROUND_WAIT]   = "round_wait",
			[ROUND_PREP]   = "round_prep",
			[ROUND_ACTIVE] = "round_active",
			[ROUND_POST]   = "round_post"
		}


		-- Draws an arc on your screen.
		-- startang and endang are in degrees,
		-- radius is the total radius of the outside edge to the center.
		-- cx, cy are the x,y coordinates of the center of the arc.
		-- addang adds an additional angle to where the arc starts - 90 ensures it stars at the top
		-- roughness determines how many triangles are drawn. Number between 1-360; 2 or 3 is a good number.
		function draw.Arc(cx,cy,radius,thickness,startang,endang, addang, roughness,color)
			surface.SetDrawColor(color)
			surface.DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang + addang,endang + addang,roughness))
		end

		function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness)
			local triarc = {}
			-- local deg2rad = math.pi / 180

			-- Define step
			local roughness = math.max(roughness or 1, 1)
			local step = roughness

			-- Correct start/end ang
			local startang,endang = startang or 0, endang or 0

			if startang > endang then
				step = math.abs(step) * -1
			end

			-- Create the inner circle's points.
			local inner = {}
			local r = radius - thickness
			for deg=startang, endang, step do
				local rad = math.rad(deg)
				-- local rad = deg2rad * deg
				local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
				table.insert(inner, {
					x=ox,
					y=oy,
					u=(ox-cx)/radius + .5,
					v=(oy-cy)/radius + .5,
				})
			end

			-- Create the outer circle's points.
			local outer = {}
			for deg=startang, endang, step do
				local rad = math.rad(deg)
				-- local rad = deg2rad * deg
				local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
				table.insert(outer, {
					x=ox,
					y=oy,
					u=(ox-cx)/radius + .5,
					v=(oy-cy)/radius + .5,
				})
			end

			-- Triangulize the points.
			for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
				local p1,p2,p3
				p1 = outer[math.floor(tri/2)+1]
				p3 = inner[math.floor((tri+1)/2)+1]
				if tri%2 == 0 then --if the number is even use outer.
					p2 = outer[math.floor((tri+1)/2)]
				else
					p2 = inner[math.floor((tri+1)/2)]
				end

				table.insert(triarc, {p1,p2,p3})
			end

			-- Return a table of triangles to draw.
			return triarc
		end

		function surface.DrawArc(arc)
			for k,v in ipairs(arc) do
				surface.DrawPoly(v)
			end
		end

		function AHUD:DrawHealthArea()
			local healthBoxSize = AHUD.ScrW * 0.05
			local healthBoxStartX, healthBoxStartY = AHUD.ScrW * AHUD.Padding, (AHUD.ScrH * (1 - AHUD.Padding)) - healthBoxSize
			local healthWheelSize = healthBoxSize/2 - (healthBoxSize * 0.05)
			local healthWheelX = healthBoxStartX + healthBoxSize/2
			local healthWheelY = healthBoxStartY + healthBoxSize/2

			local healthBoxMidX = healthBoxStartX + healthBoxSize/2
			local healthBoxMidY = healthBoxStartY + healthBoxSize/2

			surface.SetDrawColor(AHUD.ColBlack)
			surface.DrawRect(healthBoxStartX, healthBoxStartY, healthBoxSize, healthBoxSize)

			AHUD.playerAlive = (LocalPlayer():Team() ~= TEAM_SPECTATOR and LocalPlayer():Alive())

			if (AHUD.playerAlive) then
				local playerHealth = LocalPlayer():Health()

				--Create shake animation upon hit
				draw.SimpleText(playerHealth, "PD2_24", healthBoxMidX, healthBoxMidY, AHUD.ColTextWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				local playerHealthAsDegrees = 360 * (playerHealth/100)
				draw.Arc(healthBoxMidX, healthBoxMidY, healthWheelSize, 10, 0, playerHealthAsDegrees, 90, 1, AHUD.ColRoles[0])

				--This is the grey animated part
				--If someone is healing, don't do this - either they got it from a mod/health station
				--Mods can just be instant, it's magic after all
				--Health stations heal slowly so an animation would probably be too slow
				--If you have instant heals on your server I'm judging you, bad balance!
				if (AHUD.LastDisplayedHealth ~= playerHealth and AHUD.LastDisplayedHealth > playerHealth) then
					-- Set up values for the amount of health lost
					AHUD.HealthAnimTickCount = 0
					AHUD.HealthAnimTickNumber = AHUD.LastDisplayedHealth - playerHealth
					-- This will trigger the block below
					AHUD.HealthAnimValue = AHUD.LastDisplayedHealth

					--First interval is just a colour fade, then the interval is set to deplete
					AHUD.HealthAnimNextTick = CurTime() + AHUD.HealthAnimFadeInterval
				end

				if (AHUD.HealthAnimValue ~= playerHealth and AHUD.HealthAnimValue ~= -1) then

					local damageArcColor = AHUD.ColTextFade

					--If no interval set, we still need to fade
					if AHUD.HealthAnimTickInterval == -1 then
						local factor = (AHUD.HealthAnimNextTick - CurTime())/AHUD.HealthAnimFadeInterval
						damageArcColor = Color( 255, 255 - 150*(factor), 255 - 150*(factor), 50 + 200*(factor))
					end

					draw.Arc(healthBoxMidX, healthBoxMidY, healthWheelSize, 10, math.floor(360*(AHUD.HealthAnimValue/100)), playerHealthAsDegrees, 90,1, damageArcColor)

					if (CurTime() > AHUD.HealthAnimNextTick) then
						AHUD.HealthAnimTickCount = AHUD.HealthAnimTickCount + 1
						AHUD.HealthAnimValue = AHUD.HealthAnimValue - 1
						AHUD.HealthAnimTickInterval = AHUD.HealthAnimTickLength * (1 - math.ease.InCirc(AHUD.HealthAnimTickCount/AHUD.HealthAnimTickNumber))
						AHUD.HealthAnimNextTick = CurTime() + AHUD.HealthAnimTickInterval
					end
				else
					--Reset these as a sanity check
					AHUD.HealthAnimTickInterval = -1
					AHUD.HealthAnimTickCount = -1
					AHUD.HealthAnimTickNumber = -1
					AHUD.HealthAnimNextTick = -1
					AHUD.HealthAnimValue = -1
				end

				AHUD.LastDisplayedHealth = playerHealth
			else
				draw.Arc(healthBoxMidX, healthBoxMidY, healthWheelSize, 10, 0, 100, 90,1, AHUD.ColTextWhite)
				surface.SetMaterial( AHUD.MatWhite )
				surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
			end
		end

		-- Main section of the HUD with the health, status, armour, credits, ammo, etc
		function AHUD:CreateMainSection()
			AHUD:DrawHealthArea()

		end

		-- Stolen from CGNicks Payday 2 HUD, he's said it's freeware now but got to give credit to the OG
		function GAMEMODE:HUDPaint()
			local client = LocalPlayer()

			hook.Call( "HUDDrawTargetID", GAMEMODE )

			MSTACK:Draw(client)

			--if (not client:Alive()) or client:Team() == TEAM_SPEC then
			--SpecHUDPaint(client)

			--return
			--end

			RADAR:Draw(client)
			TBHUD:Draw(client)
			WSWITCH:Draw(client)

			VOICE.Draw(client)
			--DISGUISE.Draw(client)

			hook.Call( "HUDDrawPickupHistory", GAMEMODE )
		end

		hook.Add("HUDPaint", "ADAMS_HUD", function()

			AHUD:CreateMainSection()

		end)
	end)
end