class "TBox" {
	min = nil,
	max = nil,
	surface = nil,
	read = function(self,readStream)
		self.min = {readStream:read(float),readStream:read(float),readStream:read(float)}
		self.max = {readStream:read(float),readStream:read(float),readStream:read(float)}
		self.surface = TSurface()
		self.surface:read(readStream)
	end,
	write = function(self,writeStream)
		writeStream:write(self.min[1],float)
		writeStream:write(self.min[2],float)
		writeStream:write(self.min[3],float)
		writeStream:write(self.max[1],float)
		writeStream:write(self.max[2],float)
		writeStream:write(self.max[3],float)
		self.surface:write(writeStream)
	end,
	getSize = function()
		return self.surface:getSize()+24
	end,
}