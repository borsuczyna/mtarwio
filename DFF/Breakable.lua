class "Breakable" {
    typeID = 0x0253F2FD,
	
    extend = "Section",
	flags = false,
	positionRule = false,
	vertexCount = false,
	offsetVertices = false,		--Unused
	offsetCoords = false,			--Unused
	offsetVertexLight = false,		--Unused
	faceCount = false,
	offsetVertexIndices = false,	--Unused
	offsetMaterialIndices = false,	--Unused
	materialCount = false,
	offsetTextures = false,			--Unused
	offsetTextureNames = false,		--Unused
	offsetTextureMasks = false,		--Unused
	offsetAmbientColors = false,	--Unused
	
	vertices = false,
	faces = false,
	texCoords = false,
	vertexColors = false,
	materialTextureNames = false,
	materialTextureMasks = false,

	methodContinue = {
		read = function(self,readStream)
			self.flags = readStream:read(uint32)
			if self.flags ~= 0 then
				self.positionRule = readStream:read(uint32)
				self.vertexCount = readStream:read(uint32)
				self.offsetVertices = readStream:read(uint32)			--Unused
				self.offsetCoords = readStream:read(uint32)				--Unused
				self.offsetVertexLight = readStream:read(uint32)		--Unused
				self.faceCount = readStream:read(uint32)
				self.offsetVertexIndices = readStream:read(uint32)		--Unused
				self.offsetMaterialIndices = readStream:read(uint32)	--Unused
				self.materialCount = readStream:read(uint32)
				self.offsetTextures = readStream:read(uint32)			--Unused
				self.offsetTextureNames = readStream:read(uint32)		--Unused
				self.offsetTextureMasks = readStream:read(uint32)		--Unused
				self.offsetAmbientColors = readStream:read(uint32)		--Unused
				
				self.vertices = {}
				for i=1,self.vertexCount do
					--x,y,z
					self.vertices[i] = {readStream:read(float),readStream:read(float),readStream:read(float)}
				end
				self.texCoords = {}
				for i=1,self.vertexCount do
					--u,v
					self.texCoords[i] = {readStream:read(float),readStream:read(float)}
				end
				self.vertexColors = {}
				for i=1,self.vertexCount do
					--r,g,b,a
					self.vertexColors[i] = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
				end
				self.faces = {}
				for i=1,self.faceCount do
					self.faces[i] = {readStream:read(uint16),readStream:read(uint16),readStream:read(uint16)}
				end
				self.triangleMaterials = {}
				for i=1,self.faceCount do
					self.triangleMaterials[i] = readStream:read(uint16)
				end
				self.materialTextureNames = {}
				for i=1,self.materialCount do
					self.materialTextureNames[i] = readStream:read(char,32)
				end
				self.materialTextureMasks = {}
				for i=1,self.materialCount do
					self.materialTextureMasks[i] = readStream:read(char,32)
				end
				self.ambientColor = {}
				for i=1,self.materialCount do
					self.ambientColor[i] = {readStream:read(float),readStream:read(float),readStream:read(float)}
				end
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.flags,uint32)
			if self.flags ~= 0 then
				writeStream:write(self.positionRule,uint32)
				writeStream:write(self.vertexCount,uint32)
				writeStream:write(self.offsetVertices,uint32)
				writeStream:write(self.offsetCoords,uint32)
				writeStream:write(self.offsetVertexLight,uint32)
				writeStream:write(self.faceCount,uint32)
				writeStream:write(self.offsetVertexIndices,uint32)
				writeStream:write(self.offsetMaterialIndices,uint32)
				writeStream:write(self.materialCount,uint32)
				writeStream:write(self.offsetTextures,uint32)
				writeStream:write(self.offsetTextureNames,uint32)
				writeStream:write(self.offsetTextureMasks,uint32)
				writeStream:write(self.offsetAmbientColors,uint32)
				
				for i=1,self.vertexCount do
					--x,y,z
					writeStream:write(self.vertices[i][1],float)
					writeStream:write(self.vertices[i][2],float)
					writeStream:write(self.vertices[i][3],float)
				end
				for i=1,self.vertexCount do
					--u,v
					writeStream:write(self.texCoords[i][1],float)
					writeStream:write(self.texCoords[i][2],float)
				end
				for i=1,self.vertexCount do
					--r,g,b,a
					writeStream:write(self.vertexColors[i][1],uint8)
					writeStream:write(self.vertexColors[i][2],uint8)
					writeStream:write(self.vertexColors[i][3],uint8)
					writeStream:write(self.vertexColors[i][4],uint8)
				end
				for i=1,self.faceCount do
					writeStream:write(self.faces[i][1],uint16)
					writeStream:write(self.faces[i][2],uint16)
					writeStream:write(self.faces[i][3],uint16)
				end
				for i=1,self.faceCount do
					writeStream:write(self.triangleMaterials[i],uint16)
				end
				for i=1,self.materialCount do
					writeStream:write(self.materialTextureNames[i],char,32)
				end
				for i=1,self.materialCount do
					writeStream:write(self.materialTextureMasks[i],char,32)
				end
				for i=1,self.materialCount do	--Normalized to [0,1]
					writeStream:write(self.ambientColor[i][1],float)
					writeStream:write(self.ambientColor[i][2],float)
					writeStream:write(self.ambientColor[i][3],float)
				end
			end
		end,
		getSize = function(self)
			local size = 0
			if self.flags == 0 then
				size = 4
			else
				size = 14*4+self.vertexCount*8*4+self.materialCount*32*2+self.materialCount*3*4
			end
			self.size = size
			return size
		end,
	}
}