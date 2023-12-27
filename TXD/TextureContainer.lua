class "TextureContainerStruct" {
	extend = "Struct",
	count = false,
	deviceID = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = Struct.typeID
		self.count = 0
		self.deviceID = 0
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.count = readStream:read(uint16)
			self.deviceID = readStream:read(uint16)
		end,
		write = function(self,writeStream)
			self.size = self:getSize(true)
			writeStream:write(self.count,uint16)
			writeStream:write(self.deviceID,uint16)
		end,
		getSize = function(self)
			return 4
		end,
	}
}

class "TextureContainer" {
    typeID = 0x16,
	
    extend = "Section",
	struct = false,
	textures = false,
	extension = false,
	init = function(self,version)
		self.type = 0x16
		self.version = version
		self.struct = TextureContainerStruct():init(version)
		self.textures = {}
		self.extension = TextureNativeExtension():init(version)
		self.size = self:getSize(true)
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = TextureContainerStruct()
			self.struct:read(readStream)

			self.textures = {}
			for i=1, self.struct.count do
				local texture = TextureNative()
				texture:read(readStream)
				self.textures[i] = texture
			end

			self.extension = TextureNativeExtension()
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.size = self:getSize(true)
			self.struct:write(writeStream)

			for i=1,self.struct.count do
				self.textures[i]:write(writeStream)
			end

			self.extension:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()

			for i=1, self.struct.count do
				size = size + self.textures[i]:getSize()
			end

			size = size + self.extension:getSize()
			return size
		end,
	},
	
	removeByID = function(self,index)
		if self.textures[index] then
			table.remove(self.textures,index)
			self.struct.count = self.struct.count-1
			self.size = self:getSize()
			return true
		end
		return false
	end,

	removeByName = function(self,name)
		for i=1, self.struct.count do
			if self.textures[i].name == name then
				table.remove(self.textures,i)
				self.struct.count = self.struct.count-1
				self.size = self:getSize()
				return true
			end
		end
		return false
	end,
	
	addTexture = function(self,name)
		local textureNative = TextureNative():init(EnumRWVersion.GTASA)
		textureNative.struct.name = name
		
		table.insert(self.textures,textureNative)
		self.struct.count = self.struct.count+1
		self.size = self:getSize(true)
		
		return self.struct.count
	end,
}