class "HAnimPLG" {
    typeID = 0x11E,
	
    extend = "Section",
	animVersion = 0x100,	--By Default
	nodeID = false,
	nodeCount = false,
	flags = false,
	keyFrameSize = 36,		--By Default
	nodes = false,
	methodContinue = {
		read = function(self,readStream)
			self.animVersion = readStream:read(uint32)
			self.nodeID = readStream:read(uint32)
			self.nodeCount = readStream:read(uint32)
			if self.nodeCount ~= 0 then	--Root Bone
				self.flags = readStream:read(uint32)
				self.keyFrameSize = readStream:read(uint32)
				self.nodes = {}
				for i=1,self.nodeCount do
					self.nodes[i] = {
						nodeID = readStream:read(uint32),		--Identify
						nodeIndex = readStream:read(uint32),	--Index in array
						flags = readStream:read(uint32),
					}
				end
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.animVersion,uint32)
			writeStream:write(self.nodeID,uint32)
			writeStream:write(self.nodeCount,uint32)
			if self.nodeCount ~= 0 then	--Root Bone
				writeStream:write(self.flags,uint32)
				writeStream:write(self.keyFrameSize,uint32)
				for i=1,self.nodeCount do
					writeStream:write(self.nodes[i].nodeID,uint32)
					writeStream:write(self.nodes[i].nodeIndex,uint32)
					writeStream:write(self.nodes[i].flags,uint32)
				end
			end
		end,
		getSize = function(self)
			local size = 3*4
			if self.nodeCount ~= 0 then	--Root Bone
				size = size+8+self.nodeCount*4
			end
			self.size = size
			return size
		end,
	}
}