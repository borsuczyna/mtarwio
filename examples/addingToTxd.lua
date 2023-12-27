local txd = TXDIO():new()

local addMe = dxCreateTexture('data/addme.png', 'dxt1', true)
local newId = txd:addTexture('new', addMe)
txd:save('new-txd.txd')