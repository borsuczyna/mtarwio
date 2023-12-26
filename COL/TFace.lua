class "TFace" {
	a = nil,
	b = nil,
	c = nil,
	surface = nil,
	init = function(self,version)
		self.a = 0
		self.b = 0
		self.c = 0
		self.surface = TSurface():init(version)	--Non-Standard TSurface
		return self
	end,
	read = function(self,readStream,version)
		version = version or "COLL"
		if version == "COLL" then
			self.a = readStream:read(uint32)
			self.b = readStream:read(uint32)
			self.c = readStream:read(uint32)
		else
			self.a = readStream:read(uint16)
			self.b = readStream:read(uint16)
			self.c = readStream:read(uint16)
			self.material = readStream:read(uint8)
			self.light = readStream:read(uint8)
		end
		self.surface = TSurface()
		self.surface:read(readStream,version)	--Non-Standard TSurface
	end,
	write = function(self,writeStream,version)
		version = version or "COLL"
		if version == "COLL" then
			writeStream:write(self.a,uint32)
			writeStream:write(self.b,uint32)
			writeStream:write(self.c,uint32)
		else
			writeStream:write(self.a,uint16)
			writeStream:write(self.b,uint16)
			writeStream:write(self.c,uint16)
			writeStream:write(self.material,uint8)
			writeStream:write(self.light,uint8)
		end
		self.surface:write(writeStream,version)	--Non-Standard TSurface
	end,
	getSize = function(self,version)
		version = version or "COLL"
		if version == "COLL" then
			return 4*3+self.surface:getSize()
		else
			return 4*3+2
		end
	end
}