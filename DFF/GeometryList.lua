class "GeometryListStruct" {
	extend = "Struct",
	init = function(self,version)
		self.geometryCount = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = GeometryListStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.geometryCount = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.geometryCount,uint32)
		end,
		getSize = function(self)
			local size = 4
			self.size = size
			return size
		end,
	}
}

class "GeometryList" {
    typeID = 0x1A,
	
    extend = "Section",
	struct = false,
	geometries = false,
	init = function(self,version)
		self.struct = GeometryListStruct():init(version)
		self.struct.parent = self
		self.geometries = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = GeometryList.typeID
		return self
	end,
	createGeometry = function(self)
		local geometry = Geometry():init(self.version)
		geometry.parent = self
		self.struct.geometryCount = self.struct.geometryCount+1
		self.geometries[self.struct.geometryCount] = geometry
		self.size = self:getSize(true)
		return geometry
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = GeometryListStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			self.geometries = {}
			--Read Geometries
			for i=1,self.struct.geometryCount do
				--print("Reading Geometry",i)
				self.geometries[i] = Geometry()
				self.geometries[i].parent = self
				self.geometries[i]:read(readStream)
			end
		end,
		write = function(self,writeStream)
			self.struct.geometryCount = #self.geometries
			self.struct:write(writeStream)
			for i=1,#self.geometries do
				self.geometries[i]:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = self.struct:getSize()
			for i=1,#self.geometries do
				size = size+self.geometries[i]:getSize()
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			for i=1,#self.geometries do
				self.geometries[i]:convert(targetVersion)
			end
		end,
	}
}