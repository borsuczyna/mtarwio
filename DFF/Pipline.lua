class "Pipline" {
    typeID = 0x1F,	--Right To Render
	
    extend = "Section",
	pluginIdentifier = false,
	extraData = false,
	methodContinue = {
		read = function(self,readStream)
			self.pluginIdentifier = readStream:read(uint32)
			self.extraData = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.pluginIdentifier,uint32)
			writeStream:write(self.extraData,uint32)
		end,
		getSize = function(self)
			local size = 8
			self.size = size
			return size
		end,
	}
}