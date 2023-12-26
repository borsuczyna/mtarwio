class "COLIO" {	
	collision = nil,
	readStream = nil,
	writeStream = nil,
	load = function(self,pathOrRaw)
		if fileExists(pathOrRaw) then
			local f = fileOpen(pathOrRaw)
			if f then
				pathOrRaw = fileRead(f,fileGetSize(f))
				fileClose(f)
			end
		end
		self.readStream = ReadStream(pathOrRaw)
		self.collision = Collision()
		self.collision:read(self.readStream)
	end,
	generateFromGeometry = function(self,colVersion,geometry,matList,light)
		--Deal with materials
		local light = light or 0
		local matRef = {}
		if type(matList) == "table" then
			for k,v in pairs(matList) do
				local typeK = type(k)
				if typeK == "string" then	--Find Material By Texture Name
					local mID = geometry.materialList:findMaterialByTexName(k)
					if mID then matRef[mID] = v end
				elseif typeK == "number" then	--Use Material Index
					if geometry.materialList.materials[k] then
						matRef[k] = v
					end
				elseif typeK == "table" then	--Find Material By Texture Color
					local mID = geometry.materialList:findMaterialByColor(k[1],k[2],k[3],k[4])
					if mID then matRef[mID] = v end
				end
			end
		end
		--Deal with faces
		self.collision = Collision():init(colVersion)
		local collision = self.collision
		--Copy vertices from geometry
		collision.vertexCount = #geometry.struct.vertices
		local colVertices = collision.vertices
		local geoVertices = geometry.struct.vertices
		for i=1,collision.vertexCount do
			collision.vertices[i] = TVertex()
			collision.vertices[i][1] = geoVertices[i][1]
			collision.vertices[i][2] = geoVertices[i][2]
			collision.vertices[i][3] = geoVertices[i][3]
		end
		--Copy faces from geometry
		local faceHashTable = {}
		collision.faceCount = #geometry.struct.faces
		local colFaces = collision.faces
		local geoFaces = geometry.struct.faces
		for i=1,collision.faceCount do
			collision.faces[i] = TFace():init(colVersion)
			collision.faces[i].a = geoFaces[i][1]
			collision.faces[i].b = geoFaces[i][2]
			collision.faces[i].c = geoFaces[i][4]
			collision.faces[i].surface.light = light
			collision.faces[i].surface.material = 0
			local faceHash = geoFaces[i][2].."-"..geoFaces[i][1].."-"..geoFaces[i][4]
			faceHashTable[faceHash] = i
		end
		--Find materials
		local binMeshPLG = geometry.extension.binMeshPLG
		if binMeshPLG then
			for i=1,#binMeshPLG.materialSplits do
				local matSplit = binMeshPLG.materialSplits[i]
				local material = matRef[matSplit[2]+1] or 0	--Material ID of collision
				for index=1,matSplit[1],3 do
					local faceHash = matSplit[3][index].."-"..matSplit[3][index+1].."-"..matSplit[3][index+2]
					if faceHashTable[faceHash] then
						collision.faces[ faceHashTable[faceHash] ].surface.material = material
					end
				end
			end
		end
		if colVersion ~= "COLL" then
			collision.flags = bReplace(collision.flags,(collision.vertexCount ~= 0) and 1 or 0,1)
		end
	end,
	save = function(self,fileName)
		self.writeStream = WriteStream()
		self.writeStream.parent = self
		self.collision:write(self.writeStream)
		local str = self.writeStream:save()
		if fileName then
			if fileExists(fileName) then fileDelete(fileName) end
			local f = fileCreate(fileName)
			fileWrite(f,str)
			fileClose(f)
			return true
		end
		return str
	end,
	getSize = function(self)
		
	end,
}