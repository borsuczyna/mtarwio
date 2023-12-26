class "TSphere" {
	radius = nil,
	center = nil,
	surface = nil,
	read = function(self,readStream,version)
		version = version or "COLL"
		if version == "COLL" then
			self.radius = readStream:read(float)
			self.center = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.surface = TSurface()
			self.surface:read(readStream)	--Standard TSurface
		else
			self.center = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.radius = readStream:read(float)
			self.surface = TSurface()
			self.surface:read(readStream)	--Standard TSurface
		end
	end,
	write = function(self,writeStream,version)
		version = version or "COLL"
		if version == "COLL" then
			writeStream:write(self.radius,float)
			writeStream:write(self.center[1],float)
			writeStream:write(self.center[2],float)
			writeStream:write(self.center[3],float)
			self.surface:write(writeStream)	--Standard TSurface
		else
			writeStream:write(self.center[1],float)
			writeStream:write(self.center[2],float)
			writeStream:write(self.center[3],float)
			writeStream:write(self.radius,float)
			self.surface:write(writeStream)	--Standard TSurface
		end
	end,
}