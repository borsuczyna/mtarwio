class "COLSection" {
    typeID = 0x253F2FA,
	
    extend = "Section",
	collisionRaw = false,
	methodContinue = {
		read = function(self,readStream)
			self.collisionRaw = readStream:read(bytes,self.size)
		end,
		write = function(self,writeStream)
			writeStream:write(self.collisionRaw,bytes,#self.collisionRaw)
		end,
		getSize = function(self)
			local size = #self.collisionRaw
			self.size = size
			return size
		end,
	}
}