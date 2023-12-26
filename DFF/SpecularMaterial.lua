class "SpecularMaterial" {
    typeID = 0x0253F2F6,
	
    extend = "Section",
	specularLevel = false,
	textureName = false,
	methodContinue = {
		read = function(self,readStream)
			self.specularLevel = readStream:read(float)
			self.textureName = readStream:read(char,24)
		end,
		write = function(self,writeStream)
			writeStream:write(self.specularLevel,float)
			writeStream:write(self.textureName,char,24)
		end,
		getSize = function(self)
			local size = 28
			self.size = size
			return size
		end,
	}
}