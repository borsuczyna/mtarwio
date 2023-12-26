class "TSurface" {
	material = nil,
	flags = nil,
	brightness = nil,
	light = nil,
	init = function(self,version)
		self.material = 0
		self.flags = 0
		self.brightness = 0
		self.light = 0
		return self
	end,
	read = function(self,readStream,colVersion)
		self.material = readStream:read(uint8)
		self.flags = readStream:read(uint8)
		self.brightness = readStream:read(uint8)
		self.light = readStream:read(uint8)
	end,
	write = function(self,writeStream,colVersion)
		writeStream:write(self.material,uint8)
		writeStream:write(self.flags or 0,uint8)
		writeStream:write(self.brightness or 255,uint8)
		writeStream:write(self.light,uint8)
	end,
	getSize = function()
		return 4
	end,
}