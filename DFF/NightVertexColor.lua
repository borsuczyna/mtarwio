class "NightVertexColor" {
    typeID = 0x253F2F9,
	
    extend = "Section",
	hasColor = false,
	colors = false,
	methodContinue = {
		read = function(self,readStream)
			self.hasColor = readStream:read(uint32)
			self.colors = {}
			for i=1,(self.size-4)/4 do
				self.colors[i] = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.hasColor,uint32)
			for i=1,#self.colors do
				writeStream:write(self.colors[i][1],uint8)
				writeStream:write(self.colors[i][2],uint8)
				writeStream:write(self.colors[i][3],uint8)
				writeStream:write(self.colors[i][4],uint8)
			end
			
		end,
		getSize = function(self)
			local size = 4*#self.colors+4
			self.size = size
			return size
		end,
	}
}