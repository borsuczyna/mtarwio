class "MaterialListStruct" {
	extend = "Struct",
	materialCount = false,
	materialIndices = false,
	init = function(self,version)
		self.materialCount = 0
		self.materialIndices = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = MaterialListStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.materialCount = readStream:read(uint32)
			self.materialIndices = {}
			for i=1,self.materialCount do
				--For material, -1; For a pointer of existing material, other index value.
				self.materialIndices[i] = readStream:read(int32)
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.materialCount,uint32)
			for i=1,self.materialCount do
				writeStream:write(self.materialIndices[i],int32)
			end
		end,
		getSize = function(self)
			local size = 4+4*self.materialCount
			self.size = size
			return size
		end,
	}
}

class "MaterialList" {
    typeID = 0x08,
	
    extend = "Section",
	struct = false,
	materials = false,
	init = function(self,version)
		self.struct = MaterialListStruct():init(version)
		self.struct.parent = self
		self.materials = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = MaterialList.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			--Read Material List Struct
			self.struct = MaterialListStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			--Read Materials
			self.materials = {}
			for matIndex=1,self.struct.materialCount do
				--print("Reading Material",matIndex,readStream.readingPos)
				self.materials[matIndex] = Material()
				self.materials[matIndex].parent = self
				self.materials[matIndex]:read(readStream)
			end
		end,
		write = function(self,writeStream)
			self.struct.materialCount = #self.materials
			self.struct:write(writeStream)
			for matIndex=1,#self.materials do
				self.materials[matIndex]:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = self.struct:getSize()
			for matIndex=1,#self.materials do
				size = size+self.materials[matIndex]:getSize()
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			for matIndex=1,#self.materials do
				self.materials[matIndex]:convert(targetVersion)
			end
		end,
	},
	findMaterialByTexName = function(self,texName)
		for i=1,#self.materials do
			if self.materials[i].texture then
				if self.materials[i].texture.textureName.string == texName then
					return i
				end
			end
		end
		return false
	end,
	findMaterialByMaskName = function(self,maskName)
		for i=1,#self.materials do
			if self.materials[i].texture then
				if self.materials[i].texture.maskName.string == maskName then
					return i
				end
			end
		end
		return false
	end,
	findMaterialByColor = function(self,r,g,b,a)
		for i=1,#self.materials do
			local color = self.materials[i].struct.color
			if color[1] == r and color[2] == g and color[3] == b and color[4] == a then
				return i
			end
		end
		return false
	end,
}