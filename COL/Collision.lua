class "Collision" {	--Only support COL1/2/3
	version = nil,	--FourCC ( COLL/COL2/COL3 )
	size = nil,
	modelName = nil,
	modelID = nil,
	bound = nil,
	vertexCount = nil,
	sphereCount = nil,
	boxCount = nil,
	faceGroupCount = nil,
	faceCount = nil,
	lineCount = nil,	--Unused
	trianglePlaneCount = nil,	--Unused
	flags = nil,
	offsetSphere = nil,
	offsetBox = nil,
	offsetLine = nil,	--Unused
	offsetFaceGroup = nil,
	offsetVertex = nil,
	offsetFace = nil,
	offsetTrianglePlane = nil,	--Unused
	--Casted From flags
	useConeInsteadOfLine = nil,
	notEmpty = nil,
	hasFaceGroup = nil,
	hasShadow = nil,
	--
	--Collision Version >= 3
	shadowFaceCount = nil,
	shadowVertexCount = nil,
	offsetShadowVertex = nil,
	offsetShadowFace = nil,
	--
	spheres = nil,
	boxes = nil,
	vertices = nil,
	faces = nil,
	faceGroups = nil,
	shadowFaces = nil,
	shadowVertices = nil,
	init = function(self,colVersion)
		self.version = colVersion or "COLL"
		self.size = 0	--Size will be specified when writing
		self.modelName = "default"
		self.modelID = 0
		self.bound = TBounds()
		self.bound:init(colVersion)
		if self.version == "COL2" or self.version == "COL3" then
			self.sphereCount = 0
			self.boxCount = 0
			self.faceCount = 0
			self.lineCount = 0	--Unused
			self.trianglePlaneCount = 0	--Unused
			self.flags = 0
			--Casted From flags
			self.useConeInsteadOfLine = bExtract(self.flags,0) == 1
			self.notEmpty = bExtract(self.flags,1) == 1
			self.hasFaceGroup = bExtract(self.flags,3) == 1
			self.hasShadow = bExtract(self.flags,4) == 1
			--
			self.offsetSphere = 0
			self.offsetBox = 0
			self.offsetLine = 0	--Unused
			self.offsetVertex = 0
			self.offsetFace = 0
			self.offsetTrianglePlane = 0	--Unused
			if self.version == "COL3" then
				self.shadowFaceCount = 0
				self.offsetShadowVertex = 0
				self.offsetShadowFace = 0
			end
			--Init Spheres
			self.spheres = {}
			--Init Boxes
			self.boxes = {}
			--Init Faces
			self.faces = {}
			if self.hasFaceGroup then
				--Init Face Groups
				self.faceGroupCount = 0
				self.faceGroups = {}
			end
			--Init Vertices
			self.vertexCount = 0
			self.vertices = {}
			
			if self.hasShadow then
				--Init Shadow Faces
				self.shadowFaces = {}
				--Init Shadow Vertices
				self.shadowVertexCount = 0
				self.shadowVertices = {}
			end
		elseif self.version == "COLL" then
			self.sphereCount = 0
			self.spheres = {}
			self.boxCount = 0
			self.boxes = {}
			self.vertexCount = 0
			self.vertices = {}
			self.faceCount = 0
			self.faces = {}
		end
		return self
	end,
	read = function(self,readStream)
		self.version = readStream:read(char,4)
		self.size = readStream:read(uint32)
		self.modelName = readStream:read(char,22)
		self.modelID = readStream:read(uint16)		--If not match, model name will be used
		self.bound = TBounds()
		self.bound:read(readStream,self.version)
		if self.version == "COL2" or self.version == "COL3" then
			self.sphereCount = readStream:read(uint16)
			self.boxCount = readStream:read(uint16)
			self.faceCount = readStream:read(uint16)
			self.lineCount = readStream:read(uint8)	--Unused
			self.trianglePlaneCount = readStream:read(uint8)	--Unused
			self.flags = readStream:read(uint32)
			--Casted From flags
			self.useConeInsteadOfLine = bExtract(self.flags,0) == 1
			self.notEmpty = bExtract(self.flags,1) == 1
			self.hasFaceGroup = bExtract(self.flags,3) == 1
			self.hasShadow = bExtract(self.flags,4) == 1
			--
			self.offsetSphere = readStream:read(uint32)
			self.offsetBox = readStream:read(uint32)
			self.offsetLine = readStream:read(uint32)	--Unused
			self.offsetVertex = readStream:read(uint32)
			self.offsetFace = readStream:read(uint32)
			self.offsetTrianglePlane = readStream:read(uint32)	--Unused
			if self.version == "COL3" then
				self.shadowFaceCount = readStream:read(uint32)
				self.offsetShadowVertex = readStream:read(uint32)
				self.offsetShadowFace = readStream:read(uint32)
			end
			
			--Read Spheres
			readStream.readingPos = self.offsetSphere+4+1
			self.spheres = {}
			for i=1,self.sphereCount do
				self.spheres[i] = TSphere()
				self.spheres[i]:read(readStream,self.version)
			end
			--Read Boxes
			readStream.readingPos = self.offsetBox+4+1
			self.boxes = {}
			for i=1,self.boxCount do
				self.boxes[i] = TBox()
				self.boxes[i]:read(readStream)
			end
			--Read Faces
			readStream.readingPos = self.offsetFace+4+1
			self.faces = {}
			for i=1,self.faceCount do
				self.faces[i] = TFace()
				self.faces[i]:read(readStream,self.version)
			end
			if self.hasFaceGroup then
				--Read Face Groups
				readStream.readingPos = self.offsetFace+1	--Face Group Count
				self.faceGroupCount = readStream:read(uint32)
				offsetFaceGroup = readStream.readingPos-4-self.faceGroupCount*28
				readStream.readingPos = offsetFaceGroup
				self.faceGroups = {}
				for i=1,self.faceGroupCount do
					self.faceGroups[i] = FaceGroup()
					self.faceGroups[i]:read(readStream,self.version)
				end
			end
			--Read Vertices
			self.vertexCount = ((self.hasFaceGroup and offsetFaceGroup or (self.offsetFace+4))-(self.offsetVertex+4))/6
			self.vertexCount = self.vertexCount-self.vertexCount%1
			self.vertices = {}
			readStream.readingPos = self.offsetVertex+4+1
			for i=1,self.vertexCount do
				self.vertices[i] = TVertex()
				self.vertices[i]:read(readStream,self.version)
			end
			
			if self.hasShadow then
				--Read Shadow Faces
				readStream.readingPos = self.offsetShadowFace+4+1
				self.shadowFaces = {}
				for i=1,self.shadowFaceCount do
					self.shadowFaces[i] = TFace()
					self.shadowFaces[i]:read(readStream,self.version)
				end
				--Read Shadow Vertices
				self.shadowVertexCount = ((self.offsetShadowFace+4)-(self.offsetShadowVertex+4))/6
				self.shadowVertexCount = self.shadowVertexCount-self.shadowVertexCount%1
				self.shadowVertices = {}
				readStream.readingPos = self.offsetShadowVertex+4+1
				for i=1,self.shadowVertexCount do
					self.shadowVertices[i] = TVertex()
					self.shadowVertices[i]:read(readStream,self.version)
				end
			end
		elseif self.version == "COLL" then
			self.sphereCount = readStream:read(uint32)
			self.spheres = {}
			for i=1,self.sphereCount do
				self.spheres[i] = TSphere()
				self.spheres[i]:read(readStream)
			end
			readStream:read(uint32)	--Unused 0
			self.boxCount = readStream:read(uint32)
			self.boxes = {}
			for i=1,self.boxCount do
				self.boxes[i] = TBox()
				self.boxes[i]:read(readStream)
			end
			self.vertexCount = readStream:read(uint32)
			self.vertices = {}
			for i=1,self.vertexCount do
				self.vertices[i] = TVertex()
				self.vertices[i]:read(readStream)
			end
			self.faceCount = readStream:read(uint32)
			self.faces = {}
			for i=1,self.faceCount do
				self.faces[i] = TFace()
				self.faces[i]:read(readStream)
			end
		end
	end,
	write = function(self,writeStream)
		writeStream:write(self.version,char,4)
		local pSize = writeStream:write(self.size,uint32)
		writeStream:write(self.modelName,char,22)
		writeStream:write(self.modelID,uint16)
		local maxX,maxY,maxZ,minX,minY,minZ = -256,-256,-256,256,256,256	--Calculate bounding box
		for i=1,#self.vertices do
			local vertex = self.vertices[i]
			if maxX < vertex[1] then maxX = vertex[1] end
			if maxY < vertex[2] then maxY = vertex[2] end
			if maxZ < vertex[3] then maxZ = vertex[3] end
			if minX > vertex[1] then minX = vertex[1] end
			if minY > vertex[2] then minY = vertex[2] end
			if minZ > vertex[3] then minZ = vertex[3] end
		end
		for i=1,#self.spheres do
			local sphere = self.spheres[i]
			local sphereMinX,sphereMinY,sphereMinZ = sphere.center[1]-sphere.radius,sphere.center[2]-sphere.radius,sphere.center[3]-sphere.radius
			local sphereMaxX,sphereMaxY,sphereMaxZ = sphere.center[1]+sphere.radius,sphere.center[2]+sphere.radius,sphere.center[3]+sphere.radius
			if maxX < sphereMaxX then maxX = sphereMaxX end
			if maxY < sphereMaxY then maxY = sphereMaxY end
			if maxZ < sphereMaxZ then maxZ = sphereMaxZ end
			if minX > sphereMinX then minX = sphereMinX end
			if minY > sphereMinY then minY = sphereMinY end
			if minZ > sphereMinZ then minZ = sphereMinZ end
		end
		for i=1,#self.boxes do
			local box = self.boxes[i]
			if maxX < box.max[1] then maxX = box.max[1] end
			if maxY < box.max[2] then maxY = box.max[2] end
			if maxZ < box.max[3] then maxZ = box.max[3] end
			if minX > box.min[1] then minX = box.min[1] end
			if minY > box.min[2] then minY = box.min[2] end
			if minZ > box.min[3] then minZ = box.min[3] end
		end
		self.bound.min[1] = minX
		self.bound.min[2] = minY
		self.bound.min[3] = minZ
		self.bound.max[1] = maxX
		self.bound.max[2] = maxY
		self.bound.max[3] = maxZ
		self.bound.center[1] = (minX+maxX)/2
		self.bound.center[2] = (minY+maxY)/2
		self.bound.center[3] = (minZ+maxZ)/2
		self.bound.radius = ((minX-self.bound.center[1])^2+(minY-self.bound.center[2])^2+(minZ-self.bound.center[3])^2)^0.5
		self.bound:write(writeStream,self.version)
		if self.version == "COL2" or self.version == "COL3" then
			self.sphereCount = #self.spheres
			writeStream:write(self.sphereCount,uint16)
			self.boxCount = #self.boxes
			writeStream:write(self.boxCount,uint16)
			self.faceCount = #self.faces
			writeStream:write(self.faceCount,uint16)
			self.lineCount = 0
			writeStream:write(self.lineCount,uint8)	--Unused
			self.trianglePlaneCount = 0
			writeStream:write(self.trianglePlaneCount,uint8)	--Unused
			writeStream:write(self.flags,uint32)
			--Maybe overwrite
			local pOffsetSphere,pOffsetBox,pOffsetLine,pOffsetVertex,pOffsetFace,pOffsetTrianglePlane
			pOffsetSphere = writeStream:write(0,uint32)
			pOffsetBox = writeStream:write(0,uint32)
			pOffsetLine = writeStream:write(0,uint32)	--Unused
			pOffsetVertex = writeStream:write(0,uint32)
			pOffsetFace = writeStream:write(0,uint32)
			pOffsetTrianglePlane = writeStream:write(0,uint32)	--Unused
			local pOffsetShadowFace,pOffsetShadowVertex
			if self.version == "COL3" then
				writeStream:write(self.shadowFaceCount,uint32)
				pOffsetShadowVertex = writeStream:write(0,uint32)
				pOffsetShadowFace = writeStream:write(0,uint32)
			end
			--Sphere Start
			--Write Spheres
			if self.sphereCount ~= 0 then
				self.offsetSphere = writeStream.writingPos-4-1
				writeStream:overwrite(pOffsetSphere,self.offsetSphere,uint32)
				for i=1,self.sphereCount do
					self.spheres[i]:write(writeStream,self.version)
				end
			end
			--Write Boxes
			if self.boxCount ~= 0 then
				self.offsetBox = writeStream.writingPos-4-1
				writeStream:overwrite(pOffsetBox,self.offsetBox,uint32)
				for i=1,self.boxCount do
					self.boxes[i]:write(writeStream)
				end
			end
			--Write Vertices
			if #self.vertices ~= 0 then
				self.offsetVertex = writeStream.writingPos-4-1
				writeStream:overwrite(pOffsetVertex,self.offsetVertex,uint32)
				for i=1,#self.vertices do
					self.vertices[i]:write(writeStream,self.version)
				end
				if (writeStream.writingPos-self.offsetVertex)%4 ~= 0 then	--For 4Byte Alignment
					writeStream:write(0,uint16)
				end
			end
			if self.hasFaceGroup then
				--Write Face Groups
				self.faceGroupCount = #self.faceGroups
				for i=1,self.faceGroupCount do
					self.faceGroups[i]:write(writeStream,self.version)
				end
				writeStream:write(self.faceGroupCount,uint32)
			end
			--Write Faces
			if self.faceCount ~= 0 then
				self.offsetFace = writeStream.writingPos-4-1
				writeStream:overwrite(pOffsetFace,self.offsetFace,uint32)
				for i=1,self.faceCount do
					self.faces[i]:write(writeStream,self.version)
				end
			end
			if self.version == "COL3" and self.hasShadow then
				--Write Shadow Vertices
				if self.shadowVertexCount ~= 0 then
					self.offsetShadowVertex = writeStream.writingPos-4-1
					writeStream:overwrite(pOffsetShadowVertex,self.offsetShadowVertex,uint32)
					for i=1,self.shadowVertexCount do
						self.shadowVertices[i]:write(writeStream,self.version)
					end
					if (writeStream.writingPos-self.offsetShadowVertex)%4 ~= 0 then	--For 4Byte Alignment
						writeStream:write(0,uint16)
					end
				end
				--Write Shadow Faces
				if self.shadowFaceCount ~= 0 then
					self.offsetShadowFace = writeStream.writingPos-4-1
					writeStream:overwrite(pOffsetShadowFace,self.offsetShadowFace,uint32)
					for i=1,self.shadowFaceCount do
						self.shadowFaces[i]:write(writeStream,self.version)
					end
				end
			end
		elseif self.version == "COLL" then
			self.sphereCount = #self.spheres
			writeStream:write(self.sphereCount,uint32)
			for i=1,self.sphereCount do
				self.spheres[i]:write(writeStream)
			end
			writeStream:write(0,uint32)	--Unused 0
			self.boxCount = #self.boxes
			writeStream:write(self.boxCount,uint32)
			for i=1,self.boxCount do
				self.boxes[i]:write(writeStream)
			end
			self.vertexCount = #self.vertices
			writeStream:write(self.vertexCount,uint32)
			for i=1,self.vertexCount do
				self.vertices[i]:write(writeStream)
			end
			self.faceCount = #self.faces
			writeStream:write(self.faceCount,uint32)
			for i=1,self.faceCount do
				self.faces[i]:write(writeStream)
			end
		end
		writeStream:overwrite(pSize,writeStream.writingPos-1,uint32)
	end,
	getSize = function(self)
		
	end,
}