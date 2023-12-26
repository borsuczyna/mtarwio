class "UVAnim" {
	typeID = 0x1B,
	
	extend = "Section",
	header = false,
	animType = false,
	frameCount = false,
	flags = false,
	duration = false,
	unused = false,
	name = false,
	nodeToUVChannel = false,
	data = false,
	methodContinue = {
		read = function(self,readStream)
			self.header = readStream:read(uint32)	--0x0100
			self.animType = readStream:read(uint32)
			self.frameCount = readStream:read(uint32)
			self.flags = readStream:read(uint32)
			self.duration = readStream:read(float)
			self.unused = readStream:read(uint32)
			self.name = readStream:read(char,32)
			self.nodeToUVChannel = {}
			for i=1,8 do
				self.nodeToUVChannel[i] = readStream:read(float)
			end
			self.data = {}
			for i=1,self.frameCount do
				self.data[i] = {}
				self.data[i].time = readStream:read(float)
				self.data[i].scale = {readStream:read(float),readStream:read(float),readStream:read(float)}
				self.data[i].position = {readStream:read(float),readStream:read(float),readStream:read(float)}
				self.data[i].previousFrame = readStream:read(int32)
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.header,uint32)
			writeStream:write(self.animType,uint32)
			writeStream:write(self.frameCount,uint32)
			writeStream:write(self.flags,uint32)
			writeStream:write(self.duration,float)
			writeStream:write(self.unused,uint32)
			writeStream:write(self.name,char,32)
			for i=1,8 do
				writeStream:write(self.nodeToUVChannel[i],float)
			end
			for i=1,self.frameCount do
				writeStream:write(self.data[i].time,float)
				writeStream:write(self.data[i].scale[1],float)
				writeStream:write(self.data[i].scale[2],float)
				writeStream:write(self.data[i].scale[3],float)
				writeStream:write(self.data[i].position[1],float)
				writeStream:write(self.data[i].position[2],float)
				writeStream:write(self.data[i].position[3],float)
				writeStream:write(self.data[i].previousFrame,int32)
			end
		end,
		getSize = function(self)
			local size = 4*6+32+4*8+4*8*self.frameCount
			self.size = size
			return size
		end,
	}
}