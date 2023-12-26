class "ClumpStruct" {
	extend = "Struct",
    
	atomicCount = false,
	lightCount = false,
	cameraCount = false,
	init = function(self,version)
		self.atomicCount = 0
		self.lightCount = 0
		self.cameraCount = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = ClumpStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.atomicCount = readStream:read(int32)
			self.lightCount = readStream:read(int32)
			self.cameraCount = readStream:read(int32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.atomicCount,int32)
			writeStream:write(self.lightCount,int32)
			writeStream:write(self.cameraCount,int32)
		end,
		getSize = function(self)
			local size = 12
			self.size = size
			return size
		end,
	}
}

class "ClumpExtension" {
	extend = "Extension",
	collisionSection = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = ClumpExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			if self.size > 0 then
				self.collisionSection = COLSection()
				self.collisionSection.parent = self
				self.collisionSection:read(readStream)
			end
		end,
		write = function(self,writeStream)
			if self.collisionSection then
				self.collisionSection:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = 0
			if self.collisionSection then
				size = size+self.collisionSection:getSize()
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			if self.collisionSection then
				self.collisionSection:convert(targetVersion)
			end
		end,
	}
}

class "Clump" {
    typeID = 0x10,

	extend = "Section",
	struct = false,
	frameList = false,
	geometryList = false,
	atomics = false,
	indexStructs = false,
	lights = false,
	extension = false,
	init = function(self,version)
		self.struct = ClumpStruct():init(version)
		self.struct.parent = self
		self.frameList = FrameList():init(version)
		self.frameList.parent = self
		self.geometryList = GeometryList():init(version)
		self.geometryList.parent = self
		self.extension = ClumpExtension():init(version)
		self.extension.parent = self
		self.atomics = {}
		self.indexStructs = {}
		self.lights = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = Clump.typeID
		return self
	end,
	createAtomic = function(self)
		local atomic = Atomic():init(self.version)
		atomic.parent = self
		self.struct.atomicCount = self.struct.atomicCount+1
		self.atomics[self.struct.atomicCount] = atomic
		self.size = self:getSize(true)
		return atomic
	end,
	addComponent = function(self)
		self:createAtomic()
		self.frameList:createFrame()
		self.geometryList:createGeometry()
		self.size = self:getSize(true)
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = ClumpStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			--Read Frame List
			self.frameList = FrameList()
			self.frameList.parent = self
			self.frameList:read(readStream)
			--Read Geometry List
			self.geometryList = GeometryList()
			self.geometryList.parent = self
			self.geometryList:read(readStream)
			--Read Atomics
			self.atomics = {}
			for i=1,self.struct.atomicCount do
				--print("Reading Atomic",i,readStream.readingPos)
				self.atomics[i] = Atomic()
				self.atomics[i].parent = self
				self.atomics[i]:read(readStream)
			end
			local nextSection
			repeat
				nextSection = Section()
				nextSection.parent = self
				nextSection:read(readStream)
				if nextSection.type == Struct.typeID then
					recastClass(nextSection,IndexStruct)
					nextSection:read(readStream)
					if not self.indexStructs then self.indexStructs = {} end
					self.indexStructs[#self.indexStructs+1] = nextSection
				elseif nextSection.type == Light.typeID then
					recastClass(nextSection,Light)
					nextSection:read(readStream)
					if not self.lights then self.lights = {} end
					self.lights[#self.lights+1] = nextSection
				end
			until nextSection.type == ClumpExtension.typeID
			--Read Extension
			recastClass(nextSection,ClumpExtension)
			self.extension = nextSection
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct.atomicCount = #self.atomics
			self.struct:write(writeStream)
			--Write Frame List
			self.frameList:write(writeStream)
			--Write Geometry List
			self.geometryList:write(writeStream)
			--Write Atomics
			for i=1,#self.atomics do
				--print("Write Atomic",i)
				self.atomics[i]:write(writeStream)
			end
			--Write Lights
			if self.indexStructs then
				for i=1,#self.indexStructs do
					if self.lights[i] then
						self.indexStructs[i]:write(writeStream)
						self.lights[i]:write(writeStream)
					end
				end
			end
			--Write Extension
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()+self.frameList:getSize()+self.geometryList:getSize()
			for i=1,#self.atomics do
				size = size+self.atomics[i]:getSize()
			end
			size = size+self.extension:getSize()
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			self.frameList:convert(targetVersion)
			self.geometryList:convert(targetVersion)
			for i=1,#self.atomics do
				self.atomics[i]:convert(targetVersion)
			end
			if self.indexStructs then
				for i=1,#self.indexStructs do
					if self.lights[i] then
						self.indexStructs[i]:convert(targetVersion)
						self.lights[i]:convert(targetVersion)
					end
				end
			end
			self.extension:convert(targetVersion)
			self:getSize()
		end,
	}
}