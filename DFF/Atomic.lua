class "AtomicExtension" {
	extend = "Extension",
	pipline = false,
	materialEffect = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = AtomicExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			local nextSection
			local readSize = 0
			if self.size ~= 0 then
				repeat
					nextSection = Section()
					nextSection.parent = self
					nextSection:read(readStream)
					if nextSection.type == Pipline.typeID then
						recastClass(nextSection,Pipline)
						self.pipline = nextSection
					elseif nextSection.type == MaterialEffectPLG.typeID then
						recastClass(nextSection,MaterialEffectPLG)
						self.materialEffect = nextSection
					else
						error("Unsupported Atomic Plugin "..nextSection.type)
					end
					nextSection.parent = self
					nextSection:read(readStream)
					readSize = readSize+nextSection.size+12
				until readSize >= self.size
			end
		end,
		write = function(self,writeStream)
			if self.pipline then
				self.pipline:write(writeStream)
			end
			if self.materialEffect then
				self.materialEffect:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = 0
			if self.pipline then
				size = size+self.pipline:getSize()
			end
			if self.materialEffect then
				size = size+self.materialEffect:getSize()
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			if self.pipline then
				self.pipline:convert(targetVersion)
			end
			if self.materialEffect then
				self.materialEffect:convert(targetVersion)
			end
		end,
	}
}

class "AtomicStruct" {
	extend = "Struct",
	frameIndex = false,			-- Index of the frame within the clump's frame list.
	geometryIndex = false,		-- Index of the geometry within the clump's frame list.
	flags = false,				-- Flags
	unused = false,				-- Unused
	--Casted From flags
	atomicCollisionTest = false,	--Unused
	atomicRender = false,			--The atomic is rendered if it is in the view frustum. It's set to TRUE for all models by default.
	--
	init = function(self,version)
		self.frameIndex = 0
		self.geometryIndex = 0
		self.flags = 5
		self.unused = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = AtomicStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.frameIndex = readStream:read(uint32)
			self.geometryIndex = readStream:read(uint32)
			self.flags = readStream:read(uint32)
			self.unused = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.frameIndex,uint32)
			writeStream:write(self.geometryIndex,uint32)
			writeStream:write(self.flags,uint32)
			writeStream:write(self.unused,uint32)
		end,
		getSize = function(self)
			local size = 16
			self.size = size
			return size
		end,
	}
}

class "Atomic" {
    typeID = 0x14,
	
    extend = "Section",
	struct = false,
	extension = false,
	init = function(self,version)
		self.struct = AtomicStruct():init(version)
		self.struct.parent = self
		self.extension = AtomicExtension():init(version)
		self.extension.parent = self
		self.size = self:getSize(true)
		self.version = version
		self.type = Atomic.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = AtomicStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			self.extension = AtomicExtension()
			self.extension.parent = self
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()+self.extension:getSize()
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			self.extension:convert(targetVersion)
		end,
	}
}