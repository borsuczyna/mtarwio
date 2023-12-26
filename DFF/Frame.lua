class "Frame" {
    typeID = 0x253F2FE,
	
    extend = "Section",
	name = false,
	init = function(self,version)
		self.name = ""
		self.size = self:getSize(true)
		self.version = version
		self.type = Frame.typeID
		return self
	end,
	setName = function(self,name)
		self.name = name
		self.size = self:getSize(true)
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.name = readStream:read(char,self.size)
		end,
		write = function(self,writeStream)
			writeStream:write(self.name,char,self.size)
		end,
		getSize = function(self)
			local size = #self.name
			self.size = size
			return size
		end,
	},
}