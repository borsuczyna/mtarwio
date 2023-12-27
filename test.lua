local dff = DFFIO()
dff:load('data/empty.dff')
-- dff.clumps[1].geometryList.geometries[1]:clearGeometry()

local material = dff.clumps[1].geometryList.geometries[1]:addMaterial('test')
local material2 = dff.clumps[1].geometryList.geometries[1]:addMaterial('color')
-- print('added material with id', material)

local a = dff.clumps[1].geometryList.geometries[1]:addVertex(
	{-1, -1, 1}, -- position
	{80, 80, 80, 255}, -- color
	{80, 80, 80, 255}, -- night color
	{0, 1}, -- texcoord
    material -- material
)

local b = dff.clumps[1].geometryList.geometries[1]:addVertex(
	{-1, 1, 1},
	{80, 80, 80, 255},
	{80, 80, 80, 255},
	{0, 0},
    material
)

local c = dff.clumps[1].geometryList.geometries[1]:addVertex(
    {1, 1, 1},
    {80, 80, 80, 255},
    {80, 80, 80, 255},
    {1, 0},
    material
)

local d = dff.clumps[1].geometryList.geometries[1]:addVertex(
    {1, -1, 1},
    {80, 80, 80, 255},
    {80, 80, 80, 255},
    {1, 1},
    material
)

local a2 = dff.clumps[1].geometryList.geometries[1]:addVertex(
	{-1, -1, 0}, -- position
	{80, 80, 80, 255}, -- color
	{80, 80, 80, 255}, -- night color
	{0, 1}, -- texcoord
    material2 -- material
)

local b2 = dff.clumps[1].geometryList.geometries[1]:addVertex(
	{-1, 1, 0},
	{80, 80, 80, 255},
	{80, 80, 80, 255},
	{0, 0},
    material2
)

local c2 = dff.clumps[1].geometryList.geometries[1]:addVertex(
    {1, 1, 0},
    {80, 80, 80, 255},
    {80, 80, 80, 255},
    {1, 0},
    material2
)

local d2 = dff.clumps[1].geometryList.geometries[1]:addVertex(
    {1, -1, 0},
    {80, 80, 80, 255},
    {80, 80, 80, 255},
    {1, 1},
    material2
)

-- print(a, b, c, d)

dff.clumps[1].geometryList.geometries[1]:addTriangle(c, b, a, material)
dff.clumps[1].geometryList.geometries[1]:addTriangle(a, d, c, material)
dff.clumps[1].geometryList.geometries[1]:addTriangle(c2, b2, a2, material2)
dff.clumps[1].geometryList.geometries[1]:addTriangle(a2, d2, c2, material2)

-- dff:save('elo.dff')

local col = COLIO()
col:generateFromGeometry("COLL",dff.clumps[1].geometryList.geometries[1],{
	textureA = 26,	--find material ID by texture name, and convert to col material
	[{255,255,255}] = 1,	--find material ID by color, and convert to col material
})

local txd = TXDIO()
txd:load("data/plane.txd")

-- local dds = txd:getTexture('color')
-- local texture = dxCreateTexture(dds)
local changeMe = dxCreateTexture('data/changeme.png', 'dxt1', true)
local addMe = dxCreateTexture('data/addme.png', 'dxt1', true)
txd:setTexture('test', changeMe)
local newid = txd:addTexture('new', addMe)

-- local ddsData = dxGetTexturePixels(changeMe, 'dds', 'dxt1', true)
local dds = txd:getTexture('color')
local texture = dxCreateTexture(dds)
local width, height = txd:getTextureDimensions('color')

-- local testTexture = dxCreateTexture(txd:getTexture('test'))
-- local testWidth, testHeight = txd:getTextureDimensions('test')

addEventHandler('onClientRender', root, function()
    dxDrawImage(0, 0, 60, 60, texture)
    dxDrawImage(60, 0, 60, 60, changeMe)
--     dxDrawImage(0, height, testWidth, testHeight, testTexture)
end)
-- txd:save('testtt.txd')

-- iprint(txd:listTextures())

-- setClipboard(inspect(dff.clumps[1].geometryList.geometries[1].materialList.materials[1]))

txd:save('test2.txd')
engineImportTXD(engineLoadTXD(txd:save()), 5507)
engineReplaceModel(engineLoadDFF(dff:save()), 5507)
engineReplaceCOL(engineLoadCOL(col:save()), 5507)
-- dff:save('empty.dff')
local ob = createObject(5507, -712.05090, 945.73853, 12.35322)
setElementPosition(localPlayer, -712.05090, 945.73853, 13.35322)