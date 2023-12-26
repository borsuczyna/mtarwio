class "FaceGroup" {
	min = nil,
	max = nil,
	startFace = nil,
	endFace = nil,
	read = function(self,readStream,version)
		version = version or "COLL"
		if version ~= "COLL" then
			self.min = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.max = {readStream:read(float),readStream:read(float),readStream:read(float)}
			self.startFace = readStream:read(uint16)
			self.endFace = readStream:read(uint16)
		end
	end,
	write = function(self,writeStream,version)
		version = version or "COLL"
		if version ~= "COLL" then
			writeStream:write(self.min[1],float)
			writeStream:write(self.min[2],float)
			writeStream:write(self.min[3],float)
			writeStream:write(self.max[1],float)
			writeStream:write(self.max[2],float)
			writeStream:write(self.max[3],float)
			writeStream:write(self.startFace,uint16)
			writeStream:write(self.endFace,uint16)
		end
	end,
	getSize = function(self,version)
		version = version or "COLL"
		if version ~= "COLL" then
			return 4*6+2*2
		end
		return 0
	end,
}