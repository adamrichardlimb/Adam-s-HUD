if CLIENT then

  function HealthAsDegrees(val)
    local pct = val/100
    local toReturn = math.floor(360 * pct)
    return toReturn
  end

  function AHUD:DrawHealthArea()
    local healthBoxSize = AHUD.ScrW * 0.075
    local healthBoxStartX, healthBoxStartY = AHUD.ScrW * AHUD.Padding, (AHUD.ScrH * (1 - AHUD.Padding)) - healthBoxSize

    local healthBoxContentBounds = AHUD:DrawOutlinedTexturedRect(healthBoxStartX, healthBoxStartY, healthBoxSize, healthBoxSize, 1)
    local healthBoxContentSize = (healthBoxContentBounds[2].x - healthBoxContentBounds[1].x)
    local healthWheelSize = healthBoxContentSize/2 - (healthBoxContentSize * 0.05)
    local healthBoxMidX = healthBoxContentBounds[1].x + healthBoxContentSize/2
    local healthBoxMidY = healthBoxContentBounds[1].y + healthBoxContentSize/2

    AHUD.playerAlive = (LocalPlayer():Team() ~= TEAM_SPECTATOR and LocalPlayer():Alive())

    if (AHUD.playerAlive) then
      local playerHealth = LocalPlayer():Health()

      --Create shake animation upon hit
      draw.SimpleText(playerHealth, "PD2_24", healthBoxMidX, healthBoxMidY, AHUD.ColTextWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

      draw.Arc(healthBoxMidX, healthBoxMidY, healthWheelSize, 10, 0, HealthAsDegrees(playerHealth), 90, 1, color_white)

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
          AHUD.HealthAnimTickNumber = AHUD.HealthAnimValue - playerHealth
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

        draw.Arc(healthBoxMidX, healthBoxMidY, healthWheelSize, 10, HealthAsDegrees(LocalPlayer():Health()), HealthAsDegrees(AHUD.HealthAnimValue), 90,1, damageArcColor)

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
      draw.Arc(healthBoxMidX, healthBoxMidY, healthWheelSize, 10, 0, 360, 90,1, AHUD.ColTextWhite)
      surface.SetMaterial( AHUD.MatWhite )
      surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
    end
  end
end