class "GeometryExtension" {
	extend = "Extension",
	binMeshPLG = false,
	breakable = false,
	nightVertexColor = false,
	effect2D = false,
	skinPLG = false,
	morphPLG = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = GeometryExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			local nextSection
			local readSize = 0
			repeat
				nextSection = Section()
				nextSection.parent = self
				nextSection:read(readStream)
				if nextSection.type == BinMeshPLG.typeID then
					recastClass(nextSection,BinMeshPLG)
					self.binMeshPLG = nextSection
				elseif nextSection.type == Breakable.typeID then
					recastClass(nextSection,Breakable)
					self.breakable = nextSection
				elseif nextSection.type == NightVertexColor.typeID then
					recastClass(nextSection,NightVertexColor)
					self.nightVertexColor = nextSection
				elseif nextSection.type == Effect2D.typeID then
					recastClass(nextSection,Effect2D)
					self.effect2D = nextSection
				elseif nextSection.type == SkinPLG.typeID then
					recastClass(nextSection,SkinPLG)
					self.skinPLG = nextSection
				elseif nextSection.type == MorphPLG.typeID then
					recastClass(nextSection,MorphPLG)
					self.morphPLG = nextSection
				else
					error("Unsupported Geometry Plugin "..nextSection.type)
				end
				nextSection.parent = self
				nextSection:read(readStream)
				readSize = readSize+nextSection.size+12
			until readSize >= self.size
		end,
		write = function(self,writeStream)
			if self.binMeshPLG then self.binMeshPLG:write(writeStream) end
			if self.skinPLG then self.skinPLG:write(writeStream) end
			if self.morphPLG then self.morphPLG:write(writeStream) end
			if self.breakable then self.breakable:write(writeStream) end
			if self.nightVertexColor then self.nightVertexColor:write(writeStream) end
			if self.effect2D then self.effect2D:write(writeStream) end
		end,
		getSize = function(self)
			local size = 0
			if self.binMeshPLG then size = size+self.binMeshPLG:getSize() end
			if self.morphPLG then size = size+self.morphPLG:getSize() end
			if self.breakable then size = size+self.breakable:getSize() end
			if self.nightVertexColor then size = size+self.nightVertexColor:getSize() end
			if self.effect2D then size = size+self.effect2D:getSize() end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			if self.binMeshPLG then self.binMeshPLG:convert(targetVersion) end
			if self.morphPLG then self.morphPLG:convert(targetVersion) end
			if self.skinPLG then self.skinPLG:convert(targetVersion) end
			if self.breakable then self.breakable:convert(targetVersion) end
			if self.nightVertexColor then self.nightVertexColor:convert(targetVersion) end
			if self.effect2D then self.effect2D:convert(targetVersion) end
		end,
	}
}

class "GeometryStruct" {
	extend = "Struct",
	vertexCount = false,
	morphTargetCount = false,
	--version < EnumRWVersion.GTASA
	ambient = false,
	specular = false,
	diffuse = false,
	--Data
	vertexColors = false,
	texCoords = false,
	faces = false,
	vertices = false,
	normals = false,
	boundingSphere = false,
	hasVertices = false,
	hasNormals = false,
	--Casted From flags
	bTristrip = false,
	bPosition = false,
	bTextured = false,
	bVertexColor = false,
	bNormal = false,
	bLight = false,
	bModulateMaterialColor = false,
	bTextured2 = false,
	bNative = false,
	TextureCount = false,
	--
	init = function(self,version)
		self.faceCount = 0
		self.vertexCount = 0
		self.morphTargetCount = 1
		self.boundingSphere = {0,0,0,0}
		self.hasVertices = false
		self.hasNormals = false
		self.size = self:getSize(true)
		self.version = version
		self.type = GeometryStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			local flags = readStream:read(uint16)
			--Extract Flags
			self.bTristrip = bExtract(flags,0) == 1
			self.bPosition = bExtract(flags,1) == 1
			self.bTextured = bExtract(flags,2) == 1
			self.bVertexColor = bExtract(flags,3) == 1
			self.bNormal = bExtract(flags,4) == 1
			self.bLight = bExtract(flags,5) == 1
			self.bModulateMaterialColor = bExtract(flags,6) == 1
			self.bTextured2 = bExtract(flags,7) == 1
			self.TextureCount = readStream:read(uint8)
			self.bNative = (readStream:read(uint8)%2) == 1
			--Read face count
			self.faceCount = readStream:read(uint32)
			self.vertexCount = readStream:read(uint32)
			self.morphTargetCount = readStream:read(uint32)
			--
			if self.version < EnumRWVersion.GTASA then
				self.ambient = readStream:read(float)
				self.specular = readStream:read(float)
				self.diffuse = readStream:read(float)
			end
			
			if not self.bNative then
				if self.bVertexColor then
					--R,G,B,A
					self.vertexColors = {}
					for vertices=1, self.vertexCount do
						self.vertexColors[vertices] = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
					end
				end
				self.texCoords = {}
				for i=1,(self.TextureCount ~= 0 and self.TextureCount or ((self.bTextured and 1 or 0)+(self.bTextured2 and 1 or 0)) ) do
					--U,V
					self.texCoords[i] = {}
					for vertices=1, self.vertexCount do
						self.texCoords[i][vertices] = {readStream:read(float),readStream:read(float)}
					end
				end
				self.faces = {}
				for i=1,self.faceCount do
					--Vertex2, Vertex1, MaterialID, Vertex3
					self.faces[i] = {readStream:read(uint16),readStream:read(uint16),readStream:read(uint16),readStream:read(uint16)}
				end
			end
			--for i=1,self.morphTargetCount do	--morphTargetCount must be 1
			--X,Y,Z,Radius
			self.boundingSphere = {readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)}
			self.hasVertices = readStream:read(uint32) ~= 0
			self.hasNormals = readStream:read(uint32) ~= 0
			if self.hasVertices then
				self.vertices = {}
				for vertex=1,self.vertexCount do
					self.vertices[vertex] = {readStream:read(float),readStream:read(float),readStream:read(float)}
				end
			end
			if self.hasNormals then
				self.normals = {}
				for vertex=1,self.vertexCount do
					self.normals[vertex] = {readStream:read(float),readStream:read(float),readStream:read(float)}
				end
			end
			--end
		end,
		write = function(self,writeStream)
			local flags = bAssemble(
				self.bTristrip,
				self.bPosition,
				self.bTextured,
				self.bVertexColor,
				self.bNormal,
				self.bLight,
				self.bModulateMaterialColor,
				self.bTextured2
			)+(self.bNative and 1 or 0)*2^24+self.TextureCount*2^16
			writeStream:write(flags,uint32)
			writeStream:write(self.faceCount,uint32)
			writeStream:write(self.vertexCount,uint32)
			writeStream:write(self.morphTargetCount,uint32)
			if self.version < EnumRWVersion.GTASA then
				writeStream:write(self.ambient,float)
				writeStream:write(self.specular,float)
				writeStream:write(self.diffuse,float)
			end
			if not self.bNative then
				if self.bVertexColor then
					--R,G,B,A
					for vertices=1, self.vertexCount do
						writeStream:write(self.vertexColors[vertices][1],uint8)
						writeStream:write(self.vertexColors[vertices][2],uint8)
						writeStream:write(self.vertexColors[vertices][3],uint8)
						writeStream:write(self.vertexColors[vertices][4],uint8)
					end
				end
				for i=1,(self.TextureCount ~= 0 and self.TextureCount or ((self.bTextured and 1 or 0)+(self.bTextured2 and 1 or 0)) ) do
					--U,V
					for vertices=1, self.vertexCount do
						writeStream:write(self.texCoords[i][vertices][1],float)
						writeStream:write(self.texCoords[i][vertices][2],float)
					end
				end
				for i=1,self.faceCount do
					--Vertex2, Vertex1, MaterialID, Vertex3
					writeStream:write(self.faces[i][1],uint16)
					writeStream:write(self.faces[i][2],uint16)
					writeStream:write(self.faces[i][3],uint16)
					writeStream:write(self.faces[i][4],uint16)
				end
			end
			for i=1,self.morphTargetCount do	--morphTargetCount should be 1
				--X,Y,Z,Radius
				writeStream:write(self.boundingSphere[1],float)
				writeStream:write(self.boundingSphere[2],float)
				writeStream:write(self.boundingSphere[3],float)
				writeStream:write(self.boundingSphere[4],float)
				writeStream:write(self.hasVertices and 1 or 0,uint32)
				writeStream:write(self.hasNormals and 1 or 0,uint32)
				if self.hasVertices then
					for vertex=1,self.vertexCount do
						writeStream:write(self.vertices[vertex][1],float)
						writeStream:write(self.vertices[vertex][2],float)
						writeStream:write(self.vertices[vertex][3],float)
					end
				end
				if self.hasNormals then
					for vertex=1,self.vertexCount do
						writeStream:write(self.normals[vertex][1],float)
						writeStream:write(self.normals[vertex][2],float)
						writeStream:write(self.normals[vertex][3],float)
					end
				end
			end
		end,
		getSize = function(self)
			local size = 4*4
			if self.version < EnumRWVersion.GTASA then
				size = size+4*3
			end
			if not self.bNative then
				if self.bVertexColor then
					size = size+self.vertexCount*4
				end
				size = size+self.vertexCount*4*2*(self.TextureCount ~= 0 and self.TextureCount or ((self.bTextured and 1 or 0)+(self.bTextured2 and 1 or 0)))+self.faceCount*2*4
			end
			for i=1,self.morphTargetCount do
				size = size+4*6
				if self.hasVertices then
					size = size+self.vertexCount*4*3
				end
				if self.hasNormals then
					size = size+self.vertexCount*4*3
				end
			end
			self.size = size
			return size
		end,
	},
}

class "Geometry" {
    typeID = 0x0F,
	
    extend = "Section",
	struct = false,
	materialList = false,
	extension = false,
	init = function(self,version)
		self.struct = GeometryStruct():init(version)
		self.struct.parent = self
		self.materialList = MaterialList():init(version)
		self.materialList.parent = self
		self.extension = GeometryExtension():init(version)
		self.extension.parent = self
		self.size = self:getSize(true)
		self.version = version
		self.type = Geometry.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = GeometryStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			--Read Material List
			self.materialList = MaterialList()
			self.materialList.parent = self
			self.materialList:read(readStream)
			--Read Extension
			self.extension = GeometryExtension()
			self.extension.parent = self
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			self.materialList:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()+self.materialList:getSize()+self.extension:getSize()
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			self.materialList:convert(targetVersion)
			self.extension:convert(targetVersion)
		end,
	},
	mergeGeometry = function(self,target,clone)
		--Compare flag (maybe will be implemented soon)
		if not self.struct.bTristrip == target.struct.bTristrip then return false end
		if not self.struct.bPosition == target.struct.bPosition then return false end
		if not self.struct.bTextured == target.struct.bTextured then return false end
		if not self.struct.bVertexColor == target.struct.bVertexColor then return false end
		if not self.struct.bNormal == target.struct.bNormal then return false end
		if not self.struct.bLight == target.struct.bLight then return false end
		if not self.struct.bModulateMaterialColor == target.struct.bModulateMaterialColor then return false end
		if not self.struct.bTextured2 == target.struct.bTextured2 then return false end
		if not self.struct.bNative == target.struct.bNative then return false end
		if not self.struct.hasNormals == target.struct.hasNormals then return false end
		local oldSelf
		if clone then	--Clone a new geometry table?
			oldSelf = self
			self = oopUtil.deepCopy(self,self.parent)
		end
		
		--Merge Struct
		--Add face/vertex count
		local targetVertices = target.struct.vertices or {}
		local selfVertices = self.struct.vertices or {}
		local targetVertexCount = #targetVertices
		local selfVertexCount = #selfVertices
		local targetFaceIndex,selfFaceIndex
		
		if not self.struct.bNative then
			if self.struct.bVertexColor then
				local targetVertexColors = target.struct.vertexColors
				local selfVertexColors = self.struct.vertexColors
				local selfVertexColorIndex = #selfVertexColors
				for i=1,#targetVertices do	--Copy vertex colors
					selfVertexColors[selfVertexColorIndex+i] = {targetVertexColors[i][1],targetVertexColors[i][2],targetVertexColors[i][3],targetVertexColors[i][4]}
				end
			end
			for i=1,(self.struct.TextureCount ~= 0 and self.struct.TextureCount or ((self.struct.bTextured and 1 or 0)+(self.struct.bTextured2 and 1 or 0)) ) do
				--U,V
				local selfTexCoords = self.struct.texCoords[i]
				local targetTexCoords = target.struct.texCoords[i]
				local selfTexCoordIndex = #selfTexCoords
				for vertices = 1,#targetVertices do	--Copy texture coordinates
					selfTexCoords[selfTexCoordIndex+vertices] = {targetTexCoords[vertices][1],targetTexCoords[vertices][2]}
				end
			end
			
			local targetFaces = target.struct.faces
			local selfFaces = self.struct.faces
			selfFaceIndex = #self.struct.faces
			for i=1,#targetFaces do	--Copy faces
				selfFaces[i+selfFaceIndex] = {targetFaces[i][1]+selfVertexCount,targetFaces[i][2]+selfVertexCount,targetFaces[i][3],targetFaces[i][4]+selfVertexCount}
			end
		end
		--for i=1,self.morphTargetCount do	--morphTargetCount must be 1
		--X,Y,Z,Radius
		--self.boundingSphere
		self.struct.hasVertices = self.struct.hasVertices or target.struct.hasVertices
		--self.struct.hasNormals = self.struct.hasNormals or target.struct.hasNormals
		if self.struct.hasVertices then
			self.struct.vertices = self.struct.vertices or {}
			local selfVertices = self.struct.vertices
			for vertex=1,targetVertexCount do
				selfVertices[vertex+selfVertexCount] = {targetVertices[vertex][1],targetVertices[vertex][2],targetVertices[vertex][3]}
			end
		end
		if self.struct.hasNormals then
			self.struct.normals = self.struct.normals or {}
			local selfNormals,targetNormals = self.struct.normals,target.struct.normals
			for vertex=1,targetVertexCount do
				selfNormals[vertex+selfVertexCount] = {targetNormals[vertex][1],targetNormals[vertex][2],targetNormals[vertex][3]}
			end
		end
		self.struct.faceCount = #self.struct.faces
		self.struct.vertexCount = #self.struct.vertices
		--end
		
		--Merge Material
		local matListToMerge = target.materialList
		local selfMatListIndex = matListToMerge.struct.materialCount
		for i=1,matListToMerge.struct.materialCount do
			self.materialList.struct.materialIndices[i+self.materialList.struct.materialCount] = matListToMerge.struct.materialIndices[i]
			self.materialList.materials[i+self.materialList.struct.materialCount] = matListToMerge.materials[i]
		end
		self.materialList.struct.materialCount = #self.materialList.struct.materialIndices
		--Merge Extension
		local selfExtension = self.extension
		local targetExtension = target.extension
		if selfExtension.binMeshPLG and targetExtension.binMeshPLG then
			if selfExtension.binMeshPLG.faceType == targetExtension.binMeshPLG.faceType then --FaceType should be the same
				local selfBinMesh = selfExtension.binMeshPLG
				local targetBinMesh = targetExtension.binMeshPLG
				
				for i=1,targetBinMesh.materialSplitCount do
					--Faces, MaterialIndex, FaceList
					local matIndex = selfBinMesh.materialSplitCount+i
					selfBinMesh.materialSplits[matIndex] = {targetBinMesh.materialSplits[i][1],selfMatListIndex+targetBinMesh.materialSplits[i][2],{}}
					for faceIndex=1,targetBinMesh.materialSplits[i][1] do
						selfBinMesh.materialSplits[matIndex][3][faceIndex] = targetBinMesh.materialSplits[i][3][faceIndex]+selfFaceIndex	--Face Index
					end
				end
				selfBinMesh.materialSplitCount = selfBinMesh.materialSplitCount+targetBinMesh.materialSplitCount
				selfBinMesh.vertexCount = selfBinMesh.vertexCount+targetBinMesh.vertexCount
			end
		end
		
		if selfExtension.nightVertexColor and targetExtension.nightVertexColor then
			if selfExtension.nightVertexColor.hasColor == targetExtension.nightVertexColor.hasColor then	--Currently, Only merge when both have night vertex color
				local targetNVC = targetExtension.nightVertexColor.colors
				local selfNVC = selfExtension.nightVertexColor.colors
				local selfNVCCount = #selfNVC
				for i=1,#targetNVC do
					selfNVC[i+selfNVCCount] = {targetNVC[i][1],targetNVC[i][2],targetNVC[i][3],targetNVC[i][4]}
				end
			end
		end

		return oldSelf
	end,

	addVertex = function(self, position, color, nightColor, texCoord, materialId)
		if not materialId then materialId = 1 end
		assert(self.struct.texCoords[materialId] ~= nil, "Material " .. materialId .. " does not exist")

		-- add vertex
		table.insert(self.struct.vertices, position)
		self.struct.vertexCount = #self.struct.vertices

		-- add color
		if self.struct.bVertexColor then
			table.insert(self.struct.vertexColors, color)
		end

		-- add night color
		if self.extension.nightVertexColor then
			table.insert(self.extension.nightVertexColor.colors, nightColor)
		end

		-- add tex coord
		if self.struct.bTextured then
			table.insert(self.struct.texCoords[materialId], texCoord)
		end

		-- return added vertex index
		return self.struct.vertexCount - 1
	end,

	findVertexAtPosition = function(self, position, epsilon)
		epsilon = epsilon or 0.0001
		for i, vertex in ipairs(self.struct.vertices) do
			if math.abs(vertex[1] - position[1]) < epsilon and math.abs(vertex[2] - position[2]) < epsilon and math.abs(vertex[3] - position[3]) < epsilon then
				return i - 1
			end
		end
		return nil
	end,

	setVertexPosition = function(self, vertexId, position)
		self.struct.vertices[vertexId + 1] = position
	end,

	setVertexColor = function(self, vertexId, color)
		self.struct.vertexColors[vertexId + 1] = color
	end,

	setVertexNightColor = function(self, vertexId, color)
		self.extension.nightVertexColor.colors[vertexId + 1] = color
	end,

	setVertexTexCoord = function(self, vertexId, materialId, texCoord)
		self.struct.texCoords[materialId][vertexId + 1] = texCoord
	end,

	getVertexPosition = function(self, vertexId)
		return self.struct.vertices[vertexId + 1]
	end,

	getVertexColor = function(self, vertexId)
		return self.struct.vertexColors[vertexId + 1]
	end,

	getVertexNightColor = function(self, vertexId)
		return self.extension.nightVertexColor.colors[vertexId + 1]
	end,

	getVertexTexCoord = function(self, vertexId, materialId)
		return self.struct.texCoords[materialId][vertexId + 1]
	end,

	addTriangle = function(self, a, b, c, materialId)
		if not materialId then materialId = 1 end

		-- add face
		table.insert(self.struct.faces, {a, b, materialId, c})
		self.struct.faceCount = #self.struct.faces

		-- add materialSplits
		if self.extension.binMeshPLG then
			local materialSplit = self.extension.binMeshPLG.materialSplits[materialId]
			if not materialSplit then
				materialSplit = {0, materialId - 1, {}}
				table.insert(self.extension.binMeshPLG.materialSplits, materialSplit)
				self.extension.binMeshPLG.materialSplitCount = self.extension.binMeshPLG.materialSplitCount + 1
			end

			table.insert(materialSplit[3], a)
			table.insert(materialSplit[3], b)
			table.insert(materialSplit[3], c)
		end
	end,

	clearGeometry = function(self)
		-- add empty vertex
		self.struct.vertices = { { 0, 0, 0 } }
		self.struct.vertexCount = 1
		self.struct.vertexColors = { { 255, 255, 255, 255 } }
		self.struct.texCoords = { { { 0, 0 } } }

		-- remove faces
		self.struct.faces = {  }
		self.struct.faceCount = 0

		-- remove materialSplits
		if self.extension.binMeshPLG then
			self.extension.binMeshPLG.materialSplits = { }
			self.extension.binMeshPLG.materialSplitCount = 0
		end

		-- add empty night vertex color
		if self.extension.nightVertexColor then
			self.extension.nightVertexColor.colors = { { 0, 0, 0, 0 } }
		end
		
	end
}