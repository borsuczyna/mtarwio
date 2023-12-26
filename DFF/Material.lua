class "MaterialExtension" {
	extend = "Extension",
	materialEffect = false,
	reflectionMaterial = false,
	specularMaterial = false,
	uvAnimation = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = MaterialExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			--Custom Section: Reflection Material
			local readSize = 0
			while self.size > readSize do
				local section = Section()
				section.parent = self
				section:read(readStream)
				if section.type == ReflectionMaterial.typeID then
					recastClass(section,ReflectionMaterial)
					self.reflectionMaterial = section
					section:read(readStream)
				elseif section.type == SpecularMaterial.typeID then
					recastClass(section,SpecularMaterial)
					self.specularMaterial = section
					section:read(readStream)
				elseif section.type == MaterialEffectPLG.typeID then
					recastClass(section,MaterialEffectPLG)
					self.materialEffect = section
					section:read(readStream)
				elseif section.type == UVAnimPLG.typeID then
					recastClass(section,UVAnimPLG)
					self.uvAnimation = section
					section:read(readStream)
				end
				readSize = readSize+section.size+12
			end
		end,
		write = function(self,writeStream)
			if self.reflectionMaterial then
				self.reflectionMaterial:write(writeStream)
			end
			if self.specularMaterial then
				self.specularMaterial:write(writeStream)
			end
			if self.materialEffect then
				self.materialEffect:write(writeStream)
			end
			if self.uvAnimation then
				self.uvAnimation:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = 0
			if self.reflectionMaterial then
				size = size+self.reflectionMaterial:getSize()
			end
			if self.specularMaterial then
				size = size+self.specularMaterial:getSize()
			end
			if self.materialEffect then
				size = size+self.materialEffect:getSize()
			end
			if self.uvAnimation then
				size = size+self.uvAnimation:getSize()
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			if self.reflectionMaterial then
				self.reflectionMaterial:convert(targetVersion)
			end
			if self.specularMaterial then
				self.specularMaterial:convert(targetVersion)
			end
			if self.materialEffect then
				self.materialEffect:convert(targetVersion)
			end
			if self.uvAnimation then
				self.uvAnimation:convert(targetVersion)
			end
		end,
	}
}

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

class "MaterialStruct" {
	extend = "Struct",
	flags = false,
	color = false,
	unused = false,
	isTextured = false,
	ambient = false,
	specular = false,
	diffuse = false,
	init = function(self,version)
		self.flags = 0
		self.color = {255,255,255,255}
		self.unused = 0
		self.isTextured = false
		self.ambient = 1
		self.specular = 1
		self.diffuse = 1
		self.size = self:getSize(true)
		self.version = version
		self.type = MaterialStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.flags = readStream:read(uint32)
			self.color = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
			self.unused = readStream:read(uint32)
			self.isTextured = readStream:read(uint32) == 1
			self.ambient = readStream:read(float)
			self.specular = readStream:read(float)
			self.diffuse = readStream:read(float)
		end,
		write = function(self,writeStream)
			writeStream:write(self.flags,uint32)
			writeStream:write(self.color[1],uint8)
			writeStream:write(self.color[2],uint8)
			writeStream:write(self.color[3],uint8)
			writeStream:write(self.color[4],uint8)
			writeStream:write(self.unused,uint32)
			writeStream:write(self.isTextured and 1 or 0,uint32)
			writeStream:write(self.ambient,float)
			writeStream:write(self.specular,float)
			writeStream:write(self.diffuse,float)
		end,
		getSize = function(self)
			local size = 28 -- 4+1*4+4+4+4*3
			self.size = size
			return size
		end,
	}
}

class "Material" {
    typeID = 0x07,
	
    extend = "Section",
	struct = false,
	texture = false,
	extension = false,
	init = function(self,ver)
		self.struct = MaterialStruct():init(version)
		self.struct.parent = self
		self.extension = MaterialExtension():init(version)
		self.extension.parent = self
		self.size = self:getSize(true)
		self.version = version
		self.type = Material.typeID
	end,
	methodContinue = {
		read = function(self,readStream)
			--Read Material Struct
			self.struct = MaterialStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			if self.struct.isTextured then
				--Read Texture
				self.texture = Texture()
				self.texture.parent = self
				self.texture:read(readStream)
			end
			--Read Extension
			self.extension = MaterialExtension()
			self.extension.parent = self
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			if self.struct.isTextured then
				self.texture:write(writeStream)
			end
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()+(self.struct.isTextured and self.texture:getSize() or 0)+self.extension:getSize()
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			if self.struct.isTextured then
				self.texture:convert(targetVersion)
			end
			self.extension:convert(targetVersion)
		end,
	}
}