class "TextureStruct" {
	extend = "Struct",
	flags = false,
	--Casted From Flags (Read Only)
	filter = false,
	UAddressing = false,
	VAddressing = false,
	hasMipmaps = false,
	--
	init = function(self,version)
		self.flags = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = TextureStruct.typeID
		self.UAddressing = 0
		self.VAddressing = 0
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.flags = readStream:read(uint32)
			--Casted From Flags (Read Only)
			self.filter = bExtract(self.flags,24,8)
			self.UAddressing = bExtract(self.flags,24,4)
			self.VAddressing = bExtract(self.flags,20,4)
			self.hasMipmaps = bExtract(self.flags,19) == 1
			--
		end,
		write = function(self,writeStream)
			writeStream:write(self.flags,uint32)
		end,
		getSize = function(self)
			local size = 4
			self.size = size
			return size
		end,
	}
}

class "Texture" {
    typeID = 0x06,
	
    extend = "Section",
	struct = false,
	textureName = false,
	maskName = false,
	extension = false,
	init = function(self,version)
		self.struct = TextureStruct():init(version)
		self.struct.parent = self
		self.textureName = String():init(version)
		self.textureName.parent = self
		self.maskName = String():init(version)
		self.maskName.parent = self
		self.extension = Extension():init(version)
		self.extension.parent = self
		self.size = self:getSize(true)
		self.version = version
		self.type = Texture.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			--Read Texture Struct
			self.struct = TextureStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			--Read Texture Name
			self.textureName = String()
			self.textureName.parent = self
			self.textureName:read(readStream)
			--Read Mask Name
			self.maskName = String()
			self.maskName.parent = self
			self.maskName:read(readStream)
			--Read Extension
			self.extension = Extension()
			self.extension.parent = self
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			self.textureName:write(writeStream)
			self.maskName:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()+self.textureName:getSize()+self.maskName:getSize()+self.extension:getSize()
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			self.textureName:convert(targetVersion)
			self.maskName:convert(targetVersion)
			self.extension:convert(targetVersion)
		end,
	}
}