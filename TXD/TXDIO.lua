class "TXDIO" {
	textureContainer = false,
	readStream = false,
	writeStream = false,
	load = function(self,pathOrRaw)
		if fileExists(pathOrRaw) then
			local f = fileOpen(pathOrRaw)
			if f then
				pathOrRaw = fileRead(f,fileGetSize(f))
				fileClose(f)
			end
		end
		self.readStream = ReadStream(pathOrRaw)
		self.textureContainer = TextureContainer()
		self.textureContainer:read(self.readStream)
	end,
	save = function(self,fileName)
		self.writeStream = WriteStream()
		self.textureContainer:write(self.writeStream)
		local str = self.writeStream:save()
		if fileName then
			if fileExists(fileName) then fileDelete(fileName) end
			local f = fileCreate(fileName)
			fileWrite(f,str)
			fileClose(f)
			return true
		end
		return str
	end,

	listTextures = function(self)
		local nameList = {}

		for _,texNative in ipairs(self.textureContainer.textures) do
			table.insert(nameList,texNative.struct.name)
		end

		return nameList
	end,

	-- getTextureNativeDataByIndex = function(self,index)
	-- 	local txdChildren = self.textureContainer.textures
	-- 	if txdChildren[index] then
	-- 		return txdChildren[index].struct
	-- 	end
	-- end,

	-- getTextureNativeDataByName = function(self,name)
	-- 	local txdChildren = self.textureContainer.textures
	-- 	local textureDataList = {}
	-- 	for _,texNative in ipairs(txdChildren) do
	-- 		if texNative.struct.name == name then
	-- 			table.insert(textureDataList,texNative.struct)
	-- 		end
	-- 	end
	-- 	return textureDataList
	-- end,

	getTextureNativeData = function(self, indexOrName)
		local txdChildren = self.textureContainer.textures
		if type(indexOrName) == 'number' then
			if txdChildren[indexOrName] then
				return txdChildren[indexOrName].struct
			end
		elseif type(indexOrName) == 'string' then
			local textureDataList = {}
			for _,texNative in ipairs(txdChildren) do
				if texNative.struct.name == indexOrName then
					table.insert(textureDataList,texNative.struct)
				end
			end
			return textureDataList
		end
	end,

	removeTextureData = function(self, indexOrName)
		if type(indexOrName) == 'number' then
			return self.textureContainer:removeByID(indexOrName)
		elseif type(indexOrName) == 'string' then
			return self.textureContainer:removeByName(indexOrName)
		end
	end,

	getTextureIndexByName = function(self,name)
		local txdChildren = self.textureContainer.textures
		for index,texNative in ipairs(txdChildren) do
			if texNative.struct.name == name then
				return index
			end
		end
		return false
	end,

	getTextureByIndex = function(self,textureID)
		local txdChildren = self.textureContainer.textures
		if not txdChildren[textureID] then return false end

		local texNative = txdChildren[textureID]
		if texNative.struct.textureFormat == EnumD3DFormat.DXT1 or texNative.struct.textureFormat == EnumD3DFormat.DXT3 or texNative.struct.textureFormat == EnumD3DFormat.DXT5 then --DXT
			local dds = DDSTexture()
			dds:convertFromTXD(texNative)
			local writeStream = WriteStream()
			dds:write(writeStream)
			return writeStream:save()
		else --Plain TODO
			-- local bmp = BMPTexture()
			-- bmp:convertFromTXD(texNative)
			-- local writeStream = WriteStream()
			-- bmp:write(writeStream)
			-- return writeStream:save()
		end
	end,
	
	getTexture = function(self,indexOrName)
		if type(indexOrName) == 'number' then
			return self:getTextureByIndex(indexOrName)
		elseif type(indexOrName) == 'string' then
			local index = self:getTextureIndexByName(indexOrName)
			if index then
				return self:getTextureByIndex(index)
			end
		end
		return false
	end,

	setTextureByIndex = function(self,textureID,texture)
		assert(type(texture) == 'userdata' and getElementType(texture) == 'texture','Invalid texture element')

		local txdChildren = self.textureContainer.textures
		if not txdChildren[textureID] then return false end

		local texNative = txdChildren[textureID]
		local dds = DDSTexture()
		local ddsData = getDdsWithMipmapsManually(texture)
		dds.ddsTextureData = ddsData
		dds:convertToTXD(texNative)
		return true
	end,

	setTexture = function(self,indexOrName,texture)
		if type(indexOrName) == 'number' then
			return self:setTextureByIndex(indexOrName,texture)
		elseif type(indexOrName) == 'string' then
			local index = self:getTextureIndexByName(indexOrName)
			if index then
				return self:setTextureByIndex(index,texture)
			end
		end
		return false
	end,

	getTexture = function(self,indexOrName)
		if type(indexOrName) == 'number' then
			return self:getTextureByIndex(indexOrName)
		elseif type(indexOrName) == 'string' then
			local index = self:getTextureIndexByName(indexOrName)
			if index then
				return self:getTextureByIndex(index)
			end
		end
		return false
	end,

	getTextureDimensionsByIndex = function(self,textureID)
		local txdChildren = self.textureContainer.textures
		if not txdChildren[textureID] then return false end
		local texNative = txdChildren[textureID]
		return texNative.struct.width,texNative.struct.height
	end,

	getTextureDimensions = function(self,indexOrName)
		if type(indexOrName) == 'number' then
			return self:getTextureDimensionsByIndex(indexOrName)
		elseif type(indexOrName) == 'string' then
			local index = self:getTextureIndexByName(indexOrName)
			if index then
				return self:getTextureDimensionsByIndex(index)
			end
		end
		return false
	end,

	addTexture = function(self,name,texture)
		local index = self.textureContainer:addTexture(name)
		self:setTextureByIndex(index,texture)

		return index
	end
}