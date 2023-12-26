class "UVAnimPLGStruct" {
	extend = "Struct",
	unused = false,
	name = false,
	methodContinue = {
		read = function(self,readStream)
			self.unused = readStream:read(uint32)
			self.name = readStream:read(char,32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.unused,uint32)
			writeStream:write(self.name,char,32)
		end,
		getSize = function(self)
			local size = 36
			self.size = size
			return size
		end,
	}
}

class "UVAnimPLG" {
    typeID = 0x135,
	
    extend = "Section",
	struct = false,
	methodContinue = {
		read = function(self,readStream)
			self.struct = UVAnimPLGStruct()
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