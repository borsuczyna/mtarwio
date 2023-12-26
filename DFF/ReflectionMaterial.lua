class "ReflectionMaterial" {
    typeID = 0x0253F2FC,
	
    extend = "Section",
	envMapScaleX = false,
	envMapScaleY = false,
	envMapOffsetX = false,
	envMapOffsetY = false,
	reflectionIntensity = false,
	envTexturePtr = false,
	methodContinue = {
		read = function(self,readStream)
			self.envMapScaleX = readStream:read(float)
			self.envMapScaleY = readStream:read(float)
			self.envMapOffsetX = readStream:read(float)
			self.envMapOffsetY = readStream:read(float)
			self.reflectionIntensity = readStream:read(float)
			self.envTexturePtr = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.envMapScaleX,float)
			writeStream:write(self.envMapScaleY,float)
			writeStream:write(self.envMapOffsetX,float)
			writeStream:write(self.envMapOffsetY,float)
			writeStream:write(self.reflectionIntensity,float)
			writeStream:write(self.envTexturePtr,uint32)
		end,
		getSize = function(self)
			local size = 24
			self.size = size
			return size
		end,
	}
}