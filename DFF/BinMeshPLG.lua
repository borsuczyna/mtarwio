class "BinMeshPLG" {
    typeID = 0x50E,
	
    extend = "Section",
	faceType = false,
	materialSplitCount = false,
	vertexCount = false,
	materialSplits = false,
	methodContinue = {
		read = function(self,readStream)
			self.faceType = readStream:read(uint32)
			self.materialSplitCount = readStream:read(uint32)
			self.vertexCount = readStream:read(uint32)
			self.materialSplits = {}
			for i=1,self.materialSplitCount do
				--Faces, MaterialIndex, FaceList
				self.materialSplits[i] = {readStream:read(uint32),readStream:read(uint32),{}}
				for faceIndex=1, self.materialSplits[i][1] do
					self.materialSplits[i][3][faceIndex] = readStream:read(uint32)	--Face Index
				end
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.faceType,uint32)
			self.materialSplitCount = #self.materialSplits
			writeStream:write(self.materialSplitCount,uint32)
			local vertexCount = 0
			for i=1,self.materialSplitCount do
				vertexCount = vertexCount+#self.materialSplits[i][3]
			end
			self.vertexCount = vertexCount
			writeStream:write(self.vertexCount,uint32)
			for i=1,self.materialSplitCount do
				--Faces, MaterialIndex
				self.materialSplits[i][1] = #self.materialSplits[i][3]
				writeStream:write(self.materialSplits[i][1],uint32)
				writeStream:write(self.materialSplits[i][2],uint32)
				for faceIndex=1,self.materialSplits[i][1] do
					writeStream:write(self.materialSplits[i][3][faceIndex],uint32)	--Face Index
				end
			end
		end,
		getSize = function(self)
			local size = 4*3
			for i=1,self.materialSplitCount do
				size = size+8+self.materialSplits[i][1]*4
			end
			self.size = size
			return size
		end,
	}
}