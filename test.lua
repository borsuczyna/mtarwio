local dff = DFFIO()
dff:load('data/empty.dff')
-- dff.clumps[1].geometryList.geometries[1]:clearGeometry()

local material = dff.clumps[1].geometryList.geometries[1]:addMaterial('test')
-- print('added material with id', material)

local a = dff.clumps[1].geometryList.geometries[1]:addVertex(
	{-1, -1, 1}, -- position
	{80, 80, 80, 255}, -- color
	{255, 255, 255, 255}, -- night color
	{0, 1}, -- texcoord
    material -- material
)

local b = dff.clumps[1].geometryList.geometries[1]:addVertex(
	{-1, 1, 1},
	{80, 80, 80, 255},
	{255, 255, 255, 255},
	{0, 0},
    material
)

local c = dff.clumps[1].geometryList.geometries[1]:addVertex(
    {1, 1, 1},
    {80, 80, 80, 255},
    {255, 255, 255, 255},
    {1, 0},
    material
)

local d = dff.clumps[1].geometryList.geometries[1]:addVertex(
    {1, -1, 1},
    {80, 80, 80, 255},
    {255, 255, 255, 255},
    {1, 1},
    material
)

-- print(a, b, c, d)

dff.clumps[1].geometryList.geometries[1]:addTriangle(c, b, a, material)
dff.clumps[1].geometryList.geometries[1]:addTriangle(a, d, c, material)

-- dff:save('elo.dff')

local col = COLIO()
col:generateFromGeometry("COLL",dff.clumps[1].geometryList.geometries[1],{
	textureA = 26,	--find material ID by texture name, and convert to col material
	[{255,255,255}] = 1,	--find material ID by color, and convert to col material
})

-- setClipboard(inspect(dff.clumps[1].geometryList.geometries[1].materialList.materials[1]))

engineImportTXD(engineLoadTXD('data/plane.txd'), 5507)	
engineReplaceModel(engineLoadDFF(dff:save()), 5507)
engineReplaceCOL(engineLoadCOL(col:save()), 5507)
dff:save('empty.dff')
local ob = createObject(5507, -712.05090, 945.73853, 12.35322)
setElementPosition(localPlayer, -712.05090, 945.73853, 13.35322)