class "UVAnimDictStruct" {
	extend = "Struct",
	animationCount = false,
	animations = false,
	methodContinue = {
		read = function(self,readStream)
			self.animationCount = readStream:read(uint32)
			self.animations = {}
			for i=1,self.animationCount do
				self.animations[i] = UVAnim()
				self.animations[i].parent = self
				self.animations[i]:read(readStream)
			end
		end,
		write = function(self,writeStream)
			writeStream:write(#self.animations,uint32)
			for i=1,#self.animations do
				self.animations[i]:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = 4
			for i=1,#self.animations do
				size = size+self.animations[i]:getSize()
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			for i=1,#self.animations do
				self.animations[i]:convert(targetVersion)
			end
		end,
	}
}

class "UVAnimDict" {
    typeID = 0x2B,
    
	extend = "Section",
	struct = false,
	methodContinue = {
		read = function(self,readStream)
			self.struct = UVAnimDictStruct()
			self.struct.parent = self
			self.struct:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
		end,
	}
}