class "TextureNativeStruct" {
	extend = "Struct",

	platform = false,
    filterFlags = false,
    name = false,
    mask = false,
	maskFlags = false,
	textureFormat = false,
	width = false,
	height = false,
	depth = false,
	mipMapCount = false,
	texCodeType = false,
	flags = false,
	palette = false,
	mipmaps = false,

	init = function(self,version)
		self.platform = 9 -- 9 = PC
		self.filterFlags = 0x1106
		self.name = ""
		self.mask = ""
		self.maskFlags = 0x8200
		self.textureFormat = 0
		self.width = 0
		self.height = 0
		self.depth = 16
		self.mipMapCount = 9
		self.texCodeType = 4
		self.flags = 0x8
		self.palette = ""
		self.mipmaps = {}
		self.version = version
		self.size = self:getSize(true)
		self.sizeVersion = 0
		self.type = 1
		return self
	end,

	methodContinue = {
		read = function(self,readStream)
			self.platform = readStream:read(uint32)
            self.filterFlags = readStream:read(uint32);
            self.name = readStream:read(char,32);
            self.mask = readStream:read(char,32);
			self.maskFlags = readStream:read(uint32);

			self.textureFormat = readStream:read(uint32);
			self.width = readStream:read(uint16);
			self.height = readStream:read(uint16);
			self.depth = readStream:read(uint8);
			self.mipMapCount = readStream:read(uint8);
			self.texCodeType = readStream:read(uint8);
			self.flags = readStream:read(uint8);

			self.palette = readStream:read(char, self.depth == 7 and 256 * 4 or 0);
			
			self.mipmaps = {}

			for i = 1, self.mipMapCount do
				local size = readStream:read(uint32)
				local data = readStream:read(bytes,size)
				self.mipmaps[i] = data
			end
        end,
		write = function(self,writeStream)
			self.size = self:getSize(true)

			writeStream:write(self.platform, uint32)
			writeStream:write(self.filterFlags, uint32)
			writeStream:write(self.name, char, 32)
			writeStream:write(self.mask, char, 32)
			writeStream:write(self.maskFlags, uint32)
			
			writeStream:write(self.textureFormat, uint32)
			writeStream:write(self.width, uint16)
			writeStream:write(self.height, uint16)
			writeStream:write(self.depth, uint8)
			writeStream:write(self.mipMapCount, uint8)
			writeStream:write(self.texCodeType, uint8)
			writeStream:write(self.flags, uint8)

			writeStream:write(self.palette, char, self.depth == 7 and 256 * 4 or 0)

			for i = 1, self.mipMapCount do
				local data = self.mipmaps[i]
				local size = #data
				writeStream:write(size, uint32)
				writeStream:write(data, bytes, size)
			end
		end,
		getSize = function(self)
			local size = 0
			size = size + 4 + 4 + 32 + 32 + 4
			size = size + 4 + 2 + 2 + 1 + 1 + 1 + 1
			size = size + (self.depth == 7 and 256 * 4 or 0)
			for i = 1, self.mipMapCount do
				local data = self.mipmaps[i] or {}
				size = size + 4 + #data
			end
			return size
		end,
    }
}

class "TextureNativeExtension" {
	extend = "Extension",
	data = false,
	methodContinue = {
		read = function(self,readStream)
			self.data = {}
			if self.size > 0 then
				self.data = readStream:read(char, self.size)
			end
		end,
		write = function(self,writeStream)
			self.size = self:getSize(true)
			if self.size > 0 then
				writeStream:write(self.data, bytes, self.size)
			end
		end,
		getSize = function(self)
			if not self.data then self.data = {} end
			return #self.data
		end,
	}
}

class "TextureNative" {
    typeID = 0x15,
	
    extend = "Section",
	struct = false,
	extension = false,
	init = function(self,version)
		self.struct = TextureNativeStruct():init(version)
		self.extension = TextureNativeExtension():init(version)
		self.type = TextureNative.typeID

		self.size = self:getSize(true)
		self.sizeVersion = 0
		self.type = TextureNative.typeID
		self.version = version
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = TextureNativeStruct()
			self.struct:read(readStream)
			
			if readStream.readingPos == readStream.length then
				print("Encountered stream end instead of texture extra info")
				return
			end

			self.extension = TextureNativeExtension()
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.size = self:getSize(true)
			self.struct:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			return self.struct:getSize() + self.extension:getSize()
		end,
	}
}