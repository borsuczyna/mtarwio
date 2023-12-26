local dff = DFFIO()
dff:load('data/empty.dff')
-- dff.clumps[1].geometryList.geometries[1]:clearGeometry()

local col = COLIO()
col:generateFromGeometry("COLL",dff.clumps[1].geometryList.geometries[1],{
	textureA = 26,	--find material ID by texture name, and convert to col material
	[{255,255,255}] = 1,	--find material ID by color, and convert to col material
})

engineImportTXD(engineLoadTXD('data/plane.txd'), 5507)	
engineReplaceModel(engineLoadDFF(dff:save()), 5507)
engineReplaceCOL(engineLoadCOL(col:save()), 5507)
-- dff:save('empty.dff')
local ob = createObject(5507, -712.05090, 945.73853, 27.35322)
setElementPosition(localPlayer, -712.05090, 945.73853, 28.35322)