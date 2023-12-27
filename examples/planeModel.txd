-- create txd
local txd = TXDIO():new()

local addMe = dxCreateTexture('data/addme.png', 'dxt1', true)
local newId = txd:addTexture('addme', addMe)

-- create txd
local dff = DFFIO()
dff:load('data/empty.dff') -- there's still no option to create a new DFF

-- add texture
local material = dff.clumps[1].geometryList.geometries[1]:addMaterial('addme')

-- add vertices
local data = {
    {-1, -1, 0,     0, 1,   0, 0, 0, 255},
    {-1, 1, 0,      0, 0,   255, 0, 0, 255},
    {1, 1, 0,       1, 0,   0, 255, 0, 255},
    {1, -1, 0,      1, 1,   0, 0, 255, 255},
}

local vertices = {}

for i, data in ipairs(data) do
    local position = {data[1], data[2], data[3]}
    local texCoords = {data[4], data[5]}
    local color = {data[6], data[7], data[8], data[9]}
    local vertex = dff.clumps[1].geometryList.geometries[1]:addVertex(
        position, -- position
        color, -- vertex color
        color, -- night vertex color
        texCoords -- texture coordinates
    )

    table.insert(vertices, vertex)
end

-- add triangles
dff.clumps[1].geometryList.geometries[1]:addTriangle(vertices[3], vertices[2], vertices[1], material)
dff.clumps[1].geometryList.geometries[1]:addTriangle(vertices[1], vertices[4], vertices[3], material)

-- create collision from dff
local col = COLIO()
col:generateFromGeometry("COLL",dff.clumps[1].geometryList.geometries[1],{
	textureA = 26,	--find material ID by texture name, and convert to col material
	[{255,255,255}] = 1,	--find material ID by color, and convert to col material
})

-- now replace everything
engineImportTXD(engineLoadTXD(txd:save()), 5507)
engineReplaceModel(engineLoadDFF(dff:save()), 5507)
engineReplaceCOL(engineLoadCOL(col:save()), 5507)
local ob = createObject(5507, -712.05090, 945.73853, 12.35322)
setElementPosition(localPlayer, -712.05090, 945.73853, 13.35322)