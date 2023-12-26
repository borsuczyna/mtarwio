class "FrameListExtension" {
	extend = "Extension",
	frame = false,
	HAnimPLG = false,
	init = function(self,version)
		self.frame = Frame():init(version)
		self.frame.parent = self
		self.size = self:getSize(true)
		self.version = version
		self.type = FrameListExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			if self.size ~= 0 then
				local section = Section()
				section.parent = self
				section:read(readStream)
				if section.type == HAnimPLG.typeID then
					recastClass(section,HAnimPLG)
					self.HAnimPLG = section
					self.HAnimPLG:read(readStream)
					section = Section()
					section.parent = self
				end
				recastClass(section,Frame)
				self.frame = section
				self.frame:read(readStream)
			end
		end,
		write = function(self,writeStream)
			if self.HAnimPLG then
				self.HAnimPLG:write(writeStream)
			end
			if self.frame then
				self.frame:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = self.frame:getSize()
			if self.HAnimPLG then
				size = size+self.HAnimPLG:getSize()
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			if self.HAnimPLG then
				self.HAnimPLG:convert(targetVersion)
			end
			if self.frame then
				self.frame:convert(targetVersion)
			end
		end,
	},
}

class "FrameListStruct" {
	extend = "Struct",
	frameCount = false,
	frameInfo = false,
	init = function(self,version)
		self.frameCount = 0
		self.frameInfo = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = FrameListStruct.typeID
		return self
	end,
	createFrameInfo = function(self)
		self.frameInfo[#self.frameInfo+1] = {
			rotationMatrix = {	--By Default
				{1,0,0},
				{0,1,0},
				{0,0,1},
			},
			positionVector = {0,0,0},
			parentFrame = 0,	--Compatible to lua array
			matrixFlags = 0x00020003,
		}
		self.size = self:getSize(true)
		return #self.frameInfo
	end,
	setFrameInfoParentFrame = function(self,frameInfoID,parentFrameID)
		if not self.frameInfo[frameInfoID] then error("Bad argument @setFrameInfoParentFrame, frame info index out of range, total "..#self.frameInfo.." got "..frameInfoID) end
		self.frameInfo[frameInfoID].parentFrame = parentFrameID
		return self
	end,
	setFrameInfoPosition = function(self,frameInfoID,x,y,z)
		if not self.frameInfo[frameInfoID] then error("Bad argument @setFrameInfoPosition, frame info index out of range, total "..#self.frameInfo.." got "..frameInfoID) end
		self.frameInfo[frameInfoID].positionVector[1] = x
		self.frameInfo[frameInfoID].positionVector[2] = y
		self.frameInfo[frameInfoID].positionVector[3] = z
		return self
	end,
	getFrameInfoPosition = function(self,frameInfoID)
		if not self.frameInfo[frameInfoID] then error("Bad argument @getFrameInfoParentFrame, frame info index out of range, total "..#self.frameInfo.." got "..frameInfoID) end
		local posVector = self.frameInfo[frameInfoID]
		return posVector[1],posVector[2],posVector[3]
	end,
	setFrameInfoRotation = function(self,frameInfoID,rx,ry,rz)
		if not self.frameInfo[frameInfoID] then error("Bad argument @setFrameInfoRotation, frame info index out of range, total "..#self.frameInfo.." got "..frameInfoID) end
		self.frameInfo[frameInfoID].rotationMatrix = eulerToRotationMatrix(rx,ry,rz)
		return self
	end,
	getFrameInfoRotation = function(self,frameInfoID)
		if not self.frameInfo[frameInfoID] then error("Bad argument @getFrameInfoRotation, frame info index out of range, total "..#self.frameInfo.." got "..frameInfoID) end
        local rotMatrix = self.frameInfo[frameInfoID].rotationMatrix
		return rotationMatrixToEuler(rotMatrix)
	end,
	methodContinue = {
		read = function(self,readStream)
			self.frameCount = readStream:read(uint32)
			if not self.frameInfo then self.frameInfo = {} end
			for i=1,self.frameCount do
				self.frameInfo[i] = {
					rotationMatrix = {
						{readStream:read(float),readStream:read(float),readStream:read(float)},
						{readStream:read(float),readStream:read(float),readStream:read(float)},
						{readStream:read(float),readStream:read(float),readStream:read(float)},
					},
					positionVector = {
						readStream:read(float),readStream:read(float),readStream:read(float),
					},
					parentFrame = readStream:read(uint32)+1,	--Compatible to lua array
					matrixFlags = readStream:read(uint32),
				}
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.frameCount,uint32)
			for i=1,self.frameCount do
				local fInfo = self.frameInfo[i]
				for x=1,3 do for y=1,3 do
					writeStream:write(fInfo.rotationMatrix[x][y],float)
				end end
				writeStream:write(fInfo.positionVector[1],float)
				writeStream:write(fInfo.positionVector[2],float)
				writeStream:write(fInfo.positionVector[3],float)
				writeStream:write(fInfo.parentFrame-1,uint32)	--Compatible to lua array
				writeStream:write(fInfo.matrixFlags,uint32)
			end
		end,
		getSize = function(self)
			local size = 4+(9*4+3*4+4+4)*#self.frameInfo
			self.size = size
			return size
		end,
	}
}

class "FrameList" {
    typeID = 0x0E,
	
    extend = "Section",
	struct = false,
	frames = false,
	init = function(self,version)
		self.struct = FrameListStruct():init(version)
		self.struct.parent = self
		self.frames = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = FrameList.typeID
		return self
	end,
	createFrame = function(self,name)
		local FrameListExtension = FrameListExtension():init(self.version)
		FrameListExtension.parent = self
		FrameListExtension.frame:setName(name or "unnamed")
		FrameListExtension:update()
		self.struct:createFrameInfo()
		self.struct.frameCount = self.struct.frameCount+1
		self.frames[self.struct.frameCount] = FrameListExtension
		self.size = self:getSize(true)
		return FrameListExtension
	end,
	methodContinue = {
		read = function(self,readStream)
			--Read Struct
			self.struct = FrameListStruct()
			self.struct.parent = self
			self.struct:read(readStream)
			--Read Frames
			self.frames = {}
			for i=1,self.struct.frameCount do
				self.frames[i] = FrameListExtension()
				self.frames[i].parent = self
				self.frames[i]:read(readStream)
			end
		end,
		write = function(self,writeStream)
			self.struct.frameCount = #self.frames
			self.struct:write(writeStream)
			for i=1,#self.frames do
				self.frames[i]:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = self.struct:getSize()
			for i=1,#self.frames do
				size = size+self.frames[i]:getSize()
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			self.struct:convert(targetVersion)
			for i=1,#self.frames do
				self.frames[i]:convert(targetVersion)
			end
		end,
	}
}