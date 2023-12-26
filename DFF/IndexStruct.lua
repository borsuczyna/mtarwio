class "IndexStruct" {
	extend = "Struct",
	index = false,
	methodContinue = {
		read = function(self,readStream)
			self.index = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.index,uint32)
		end,
		getSize = function(self)
			local size = 4
			self.size = size
			return size
		end
	}
}