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

--Faded black bg
--Had to make a whole vtf for this just cause I couldn't get opacity working lol
resource.AddFile("materials/AHUD_MATFADE.vmt")

if CLIENT then
	timer.Simple( 0, function()
		-- Here we go...
		AHUD = {}

		AHUD.BOX_TOP_LEFT = 0
		AHUD.BOX_TOP_RIGHT = 1
		AHUD.BOX_BOTTOM_LEFT = 2
		AHUD.BOX_BOTTOM_RIGHT = 3

		-- Define static stuff we likely will not change
		AHUD.ScrW = ScrW()
		AHUD.ScrH = ScrH()
		AHUD.MatWhite = Material("vgui/white")

		AHUD.MatFade = Material("AHUD_MATFADE")

		AHUD.Padding = 0.025
		AHUD.Margin = 0.0125
		AHUD.LastDisplayedHealth = -1
		surface.CreateFont( "PD2_12", { font = "Tenby Five", antialias = true, size = 17 } )
		surface.CreateFont( "PD2_14", { font = "Tenby Five", antialias = true, size = 18 } )
		surface.CreateFont( "PD2_16", { font = "Tenby Five", antialias = true, size = 23 } )
		surface.CreateFont( "PD2_20", { font = "Tenby Five", antialias = true, size = 32.5 } )
		surface.CreateFont( "PD2_24", { font = "Tenby Five", antialias = true, size = 39 } )

		--How long should the health drain animation last
		AHUD.HealthAnimFadeInterval = 0.35
		AHUD.HealthAnimTickLength = 0.05
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

		function AHUD:DrawTriangleBox(x, y, width, height, corner)
			corner = corner or AHUD.BOX_TOP_LEFT

			local triangleVerts = {}
			local squareVerts = {}

			-- Triangle always starts at half the height of the box
			local triangleHeight = (3/8) * height
			local boxPadding = width * AHUD.Padding

			--Find where our next vertex is
			if corner == AHUD.BOX_TOP_LEFT then
				//Start at halfway down
				table.insert(triangleVerts, {
					x=x,
					y=y + triangleHeight
				})

				//Top left of the overall box
				table.insert(triangleVerts, {
					x=x,
					y=y
				})

				//Then to the right
				//The triangle goes as much to the right as it does down
				//So we add y/2 - this is not a typo!
				table.insert(triangleVerts, {
					x = x + triangleHeight,
					y = y
				})

				//Fortunately - we don't have to transform the triangle verts
				table.insert(squareVerts, {
					x = x + boxPadding + triangleHeight,
					y = y
				})

				table.insert(squareVerts, {
					x = x + width,
					y = y
				})

				table.insert(squareVerts, {
					x = x + width,
					y = y + height
				})

				table.insert(squareVerts, {
					x = x,
					y = y + height
				})

				table.insert(squareVerts, {
					x = x,
					y = y + boxPadding + triangleHeight
				})

			elseif corner == AHUD.BOX_TOP_RIGHT then
				//We have to write clockwise, so start at the highest point furthest to the left
				table.insert(triangleVerts, {
					x=x + width - triangleHeight,
					y=y
				})

				//Top right of the overall box
				table.insert(triangleVerts, {
					x=x + width,
					y=y
				})

				//Then down
				table.insert(triangleVerts, {
					x = x + width,
					y = y + triangleHeight
				})

				//Then shift everything to the right so the arrow points to the center
				for index, tbl in ipairs(triangleVerts) do
					triangleVerts[index] = {
						x = tbl.x - width,
						y = tbl.y
					}
				end

			elseif corner == AHUD.BOX_BOTTOM_LEFT then
				//Start on the bottom line, shifted to the right
				table.insert(triangleVerts, {
					x = x + triangleHeight,
					y = y + height
				})

				//Move to the left
				table.insert(triangleVerts, {
					x = x,
					y = y + height
				})

				//Then up
				table.insert(triangleVerts, {
					x = x,
					y = y + triangleHeight
				})

				//Then shift everything up so the arrow points to the center
				for index, tbl in ipairs(triangleVerts) do
					PrintTable(triangleVerts[index])
					triangleVerts[index] = {
						x = tbl.x,
						y = tbl.y - height
					}
				end
			elseif corner == AHUD.BOX_BOTTOM_RIGHT then
				//Start halfway down the right side
				table.insert(triangleVerts, {
					x = x + width,
					y = y + triangleHeight
				})

				//Then the bottom right
				table.insert(triangleVerts, {
					x = x + width,
					y = y + height
				})

				//Then the bottom line minus the triangle height
				table.insert(triangleVerts, {
					x = x + triangleHeight,
					y = y + height
				})

				//Then shift everything up and to the left so the arrow points to the center
				for index, tbl in ipairs(triangleVerts) do
					triangleVerts[index] = {
						x = tbl.x - width,
					 	y = tbl.y - height
					}
				end
			end

			surface.DrawPoly(triangleVerts)
			surface.DrawPoly(squareVerts)
		end

		function AHUD:DrawHealthArea()
			local healthBoxSize = AHUD.ScrW * 0.05
			local healthBoxStartX, healthBoxStartY = AHUD.ScrW * AHUD.Padding, (AHUD.ScrH * (1 - AHUD.Padding)) - healthBoxSize
			local healthWheelSize = healthBoxSize/2 - (healthBoxSize * 0.05)
			local healthWheelX = healthBoxStartX + healthBoxSize/2
			local healthWheelY = healthBoxStartY + healthBoxSize/2

			local healthBoxMidX = healthBoxStartX + healthBoxSize/2
			local healthBoxMidY = healthBoxStartY + healthBoxSize/2

			surface.SetDrawColor(color_white)
			surface.SetMaterial(AHUD.MatFade)
			surface.DrawTexturedRect(healthBoxStartX, healthBoxStartY, healthBoxSize, healthBoxSize)

			AHUD:DrawTriangleBox(AHUD.ScrW/2, AHUD.ScrH/2, 200, 100, AHUD.BOX_TOP_LEFT)

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

					--If the current animation hasn't ended, do not trigger a new animation
					--Instead, animate down to the new value
					if (AHUD.HealthAnimValue ~= -1) then
						print("Health anim value", AHUD.HealthAnimValue)
						AHUD.HealthAnimTickNumber = AHUD.HealthAnimValue - playerHealth
						print("New number", AHUD.HealthAnimTickNumber)
					else
						AHUD.HealthAnimTickNumber = AHUD.LastDisplayedHealth - playerHealth
						-- This will trigger the block below
						AHUD.HealthAnimValue = AHUD.LastDisplayedHealth
						--First interval is just a colour fade, then the interval is set to deplete
						AHUD.HealthAnimNextTick = CurTime() + AHUD.HealthAnimFadeInterval
					end
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

		--Upon weapon switch
		function WSWITCH:Draw(client)
			if not self.Show then return end

			local weps = self.WeaponCache

			local x = AHUD.ScrW * (1 - AHUD.Padding)
			local y = AHUD.ScrH * (1 - AHUD.Padding)

			local sel = false

			for k, v in pairs(weps) do

				local wep = weps[#weps-(k-1)]

				if self.Selected == (#weps-(k-1)) then
					sel = true
				end

				draw.RoundedBox( 10, x - 184, y - 20, 20, 20, AHUD.ColBlack )
				if sel then
					draw.RoundedBox( 8, x - 182, y - 18, 16, 16, AHUD.ColRoles[ROLE] or AHUD.ColTextWhite )
				end

				surface.SetDrawColor( AHUD.ColBlack )
				surface.DrawRect( x - 160, y - 20, 160, 20 )

				draw.SimpleText( wep.Slot+1, "PD2_12", x - 175, y - 11, sel and AHUD.ColTextBlack or AHUD.ColTextFade, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( wep.Slot+1, "PD2_12", x - 174, y - 11, sel and AHUD.ColTextBlack or AHUD.ColTextFade, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( string.upper(LANG.TryTranslation(wep:GetPrintName() or wep.PrintName or "...")), "PD2_16", x - 158, y - 11, sel and AHUD.ColTextWhite or AHUD.ColTextFade, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

				sel = false

				y = y - 24
			end
		end

		-- Main section of the HUD with the health, status, armour, credits, ammo, etc
		function AHUD:CreateMainSection()
			AHUD:DrawHealthArea()

		end

		-- Stolen from CGNicks Payday 2 HUD, he's said it's freeware now but got to give credit to the OG
		function GAMEMODE:HUDPaint()
			local client = LocalPlayer()
			ROLE = LocalPlayer():GetRole()

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