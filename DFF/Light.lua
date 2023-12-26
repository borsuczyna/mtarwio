class "LightStruct" {
	extend = "Struct",
	frameIndex = false,
	radius = false,
	red = false,
	green = false,
	blue = false,
	direction = false,
	flags = false,
	lightType = false,
	methodContinue = {
		read = function(self,readStream)
			self.radius = readStream:read(float)
			self.red = readStream:read(float)
			self.green = readStream:read(float)
			self.blue = readStream:read(float)
			self.direction = readStream:read(float)
			self.flags = readStream:read(uint16)
			self.lightType = readStream:read(uint16)
		end,
		write = function(self,writeStream)
			writeStream:write(self.radius,float)
			writeStream:write(self.red,float)
			writeStream:write(self.green,float)
			writeStream:write(self.blue,float)
			writeStream:write(self.direction,float)
			writeStream:write(self.flags,uint16)
			writeStream:write(self.lightType,uint16)
		end,
		getSize = function(self)
			local size = 24
			self.size = size
			return size
		end,
	}
}

class "Light" {
    typeID = 0x12,
	
    extend = "Section",
	struct = false,
	extension = false,
	methodContinue = {
		read = function(self,readStream)
			self.struct = LightStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			self.extension = Extension()
			self.extension.parent = self
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()+self.extension:getSize()
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			self.extension:convert(targetVersion)
		end,
	}
}