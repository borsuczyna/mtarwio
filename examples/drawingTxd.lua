local sx, sy = guiGetScreenSize()
local txd = TXDIO()
txd:load('data/billbox.txd')

local textures = {
    names = {},
    textures = {},
    dimensions = {}
}

textures.names = txd:listTextures()
for i = 1, #textures.names do
    textures.textures[i] = dxCreateTexture(txd:getTexture(i))
    textures.dimensions[i] = {txd:getTextureDimensions(i)}
end

addEventHandler('onClientRender', root, function()
    local x, y = 0, 0
    for i = 1, #textures.textures do
        local w, h = textures.dimensions[i][1], textures.dimensions[i][2]
        dxDrawImage(x, y, w, h, textures.textures[i])
        dxDrawText(textures.names[i], x, y, x + w, y + h, tocolor(255, 255, 255), 1, 'default-bold', 'center', 'center')
        x = x + w
        if x >= sx then
            x = 0
            y = y + h
        end
    end
end)