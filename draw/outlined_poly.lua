if CLIENT then

  function magnitude(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
  end

  -- Function to normalize a vector
  function normalize(v)
    local mag = magnitude(v)
    return {x = v.x / mag, y = v.y / mag}
  end

  -- Function to add two vectors
  function add(v1, v2)
    return {x = v1.x + v2.x, y = v1.y + v2.y}
  end

  -- Function to subtract two vectors
  function subtract(v1, v2)
    return {x = v1.x - v2.x, y = v1.y - v2.y}
  end

  -- Function to scale a vector by a scalar
  function scale(v, scalar)
    return {x = v.x * scalar, y = v.y * scalar}
  end

  -- Function to calculate unit bisector vector at each vertex
  function bisector_unit_vector(p1, p2, p3)
    local v1 = normalize(subtract(p1, p2))
    local v2 = normalize(subtract(p3, p2))
    local bisector = add(v1, v2)
    return normalize(bisector)
  end

  -- Function to calculate the inner polygon
  function inner_polygon(vertices, distance_inside)
    local inner_vertices = {}
    local num_vertices = #vertices

    for i = 1, num_vertices do
        local prev_vertex = vertices[(i - 2 + num_vertices) % num_vertices + 1]
        local curr_vertex = vertices[i]
        local next_vertex = vertices[i % num_vertices + 1]

        local bisector = bisector_unit_vector(prev_vertex, curr_vertex, next_vertex)
        local inner_vertex = add(curr_vertex, scale(bisector, distance_inside))

        table.insert(inner_vertices, inner_vertex)
    end

    return inner_vertices
  end


  function DrawOutlinedPoly(verts, outline_size)
    local innerVertices = inner_polygon(verts, outline_size)
    local n = #innerVertices

    PrintTable(verts)
    PrintTable(innerVertices)

    for i = 1, n do
      local wrappingIndex = (i % n) + 1

      surface.DrawPoly({
        verts[i],
        verts[wrappingIndex],
        innerVertices[wrappingIndex],
        innerVertices[i]
      })
    end
  end

end