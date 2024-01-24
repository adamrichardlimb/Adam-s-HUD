if CLIENT then
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

    AHUD:DrawScrolling(triangleVerts)
    AHUD:DrawScrolling(squareVerts)
  end
end