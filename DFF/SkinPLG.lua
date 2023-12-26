class "SkinPLG" {
    typeID = 0x116,
	
    extend = "Section",
	boneCount = false,
	usedBoneCount = false,
	maxVertexWeights = false,
	usedBoneIndices = false,
	boneVertices = false,
	boneVertexWeights = false,
	bones = false,
	methodContinue = {
		read = function(self,readStream)
			self.boneCount = readStream:read(uint8)
			self.usedBoneCount = readStream:read(uint8)
			self.maxVertexWeights = readStream:read(uint8)
			readStream:read(uint8)	--Padding
			self.usedBoneIndices = {}
			for i=1,self.usedBoneCount do
				self.usedBoneIndices[i] = readStream:read(uint8)
			end
			self.boneVertices = {}
			for i=1,self.parent.parent.struct.vertexCount do
				self.boneVertices[i] = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
				
			end
			self.boneVertexWeights = {}
			for i=1,self.parent.parent.struct.vertexCount do
				self.boneVertexWeights[i] = {readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)}
			
			end
			self.bones = {}
			for i=1,self.boneCount do
				if self.version ~= EnumRWVersion.GTASA then
					readStream:read(uint32)
				end
				self.bones[i] = {
					{readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)},
					{readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)},
					{readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)},
					{readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)},
				}
			end
			if self.version == EnumRWVersion.GTASA then
				readStream:read(uint32)	--unused
				readStream:read(uint32)	--unused
				readStream:read(uint32)	--unused
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.boneCount,uint8)
			writeStream:write(self.usedBoneCount,uint8)
			writeStream:write(self.maxVertexWeights,uint8)
			writeStream:write(0,uint8)	--Padding
			for i=1,self.usedBoneCount do
				writeStream:write(self.usedBoneIndices[i],uint8)
			end
			for i=1,self.parent.parent.struct.vertexCount do
				writeStream:write(self.boneVertices[i][1],uint8)
				writeStream:write(self.boneVertices[i][2],uint8)
				writeStream:write(self.boneVertices[i][3],uint8)
				writeStream:write(self.boneVertices[i][4],uint8)
				
			end
			for i=1,self.parent.parent.struct.vertexCount do
				writeStream:write(self.boneVertexWeights[i][1],float)
				writeStream:write(self.boneVertexWeights[i][2],float)
				writeStream:write(self.boneVertexWeights[i][3],float)
				writeStream:write(self.boneVertexWeights[i][4],float)
			end
			for i=1,self.boneCount do
				if self.version ~= EnumRWVersion.GTASA then
					writeStream:write(0xDEADDEAD,uint32)
				end
				local boneTransform = self.bones[i]
				writeStream:write(boneTransform[1][1],float)
				writeStream:write(boneTransform[1][2],float)
				writeStream:write(boneTransform[1][3],float)
				writeStream:write(boneTransform[1][4],float)
				writeStream:write(boneTransform[2][1],float)
				writeStream:write(boneTransform[2][2],float)
				writeStream:write(boneTransform[2][3],float)
				writeStream:write(boneTransform[2][4],float)
				writeStream:write(boneTransform[3][1],float)
				writeStream:write(boneTransform[3][2],float)
				writeStream:write(boneTransform[3][3],float)
				writeStream:write(boneTransform[3][4],float)
				writeStream:write(boneTransform[4][1],float)
				writeStream:write(boneTransform[4][2],float)
				writeStream:write(boneTransform[4][3],float)
				writeStream:write(boneTransform[4][4],float)
			end
			if self.version == EnumRWVersion.GTASA then
				writeStream:write(0,uint32)	--unused
				writeStream:write(0,uint32)	--unused
				writeStream:write(0,uint32)	--unused
			end
		end,
		getSize = function(self)
			local size = 4+self.usedBoneCount+self.parent.parent.struct.vertexCount*5
			if self.version == EnumRWVersion.GTASA then
				size = size+self.boneCount*16*4+3*4
			else
				size = size+self.boneCount*17*4
			end
			self.size = size
			return size
		end,
	}
}