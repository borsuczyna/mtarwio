class "String" {
    typeID = 0x02,
	
    extend = "Section",
	string = false,
	init = function(self,ver)
		self.string = ""
		self.size = self:getSize(true)
		self.version = version
		self.type = String.typeID
	end,
	methodContinue = {
		read = function(self,readStream)
			self.string = readStream:read(char,self.size)
		end,
		write = function(self,writeStream)
			local diff = self.size-#self.string --Diff
			writeStream:write(self.string,bytes,#self.string)
			writeStream:write(string.rep("\0",diff),bytes,diff)
		end,
		getSize = function(self)
			return self.size
		end,
	}
}