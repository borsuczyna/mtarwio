class "MorphPLG" {
    typeID = 0x105,
	
    extend = "Section",
	unused = false,
	init = function(self,version)
		self.unused = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = MorphPLG.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.unused = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.unused,uint32)
		end,
		getSize = function(self)
			local size = 4
			self.size = size
			return size
		end,
	}
}