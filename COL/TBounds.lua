class "TBounds" {
	radius = nil,
	center = nil,
	min = nil,
	max = nil,
	init = function(self,version)
		version = version or "COLL"
		if version == "COLL" then
			self.radius = 0
			self.center = {0,0,0}
			self.min = {0,0,0}
			self.max = {0,0,0}
		else
			self.min = {0,0,0}
			self.max = {0,0,0}
			self.center = {0,0,0}
			self.radius = 0
		end
	end,
	read = function(self,readStream,version)
		version = version or "COLL"
		if version == "COLL" then
			self.radius = readStream:read(float)
			self.center = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.min = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.max = {readStream:read(float),readStream:read(float),readStream:read(float)}
		else
			self.min = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.max = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.center = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.radius = readStream:read(float)
		end
	end,
	write = function(self,writeStream,version)
		version = version or "COLL"
		if version == "COLL" then
			writeStream:write(self.radius,float)
			writeStream:write(self.center[1],float)
			writeStream:write(self.center[2],float)
			writeStream:write(self.center[3],float)
			writeStream:write(self.min[1],float)
			writeStream:write(self.min[2],float)
			writeStream:write(self.min[3],float)
			writeStream:write(self.max[1],float)
			writeStream:write(self.max[2],float)
			writeStream:write(self.max[3],float)
		else
			writeStream:write(self.min[1],float)
			writeStream:write(self.min[2],float)
			writeStream:write(self.min[3],float)
			writeStream:write(self.max[1],float)
			writeStream:write(self.max[2],float)
			writeStream:write(self.max[3],float)
			writeStream:write(self.center[1],float)
			writeStream:write(self.center[2],float)
			writeStream:write(self.center[3],float)
			writeStream:write(self.radius,float)
		end
	end,
	getSize = function(self)
		return 4*10
	end,
}