class "DFFIO" {
	uvAnimDict = false,
	clumps = false,
	readStream = false,
	writeStream = false,
	version = false,
	load = function(self,pathOrRaw)
		if fileExists(pathOrRaw) then
			local f = fileOpen(pathOrRaw)
			if f then
				pathOrRaw = fileRead(f,fileGetSize(f))
				fileClose(f)
			end
		end
		local readStream = ReadStream(pathOrRaw)
		self.clumps = {}
		while readStream.readingPos+12 < #pathOrRaw do
			local nextSection = Section()
			nextSection.parent = self
			nextSection:read(readStream)
			self.version = nextSection.version
			if nextSection.type == UVAnimDict.typeID then
				recastClass(nextSection,UVAnimDict)
				self.uvAnimDict = nextSection
				nextSection:read(readStream)
			elseif nextSection.type == Clump.typeID then
				recastClass(nextSection,Clump)
				self.clumps[#self.clumps+1] = nextSection
				nextSection:read(readStream)
			else
				break	--Read End
			end
		end
	end,
	createClump = function(self,version)
		local clump = Clump()
		clump.parent = self
		clump:init(version or EnumRWVersion.GTASA)
		self.clumps[#self.clumps+1] = clump
	end,
	save = function(self,fileName)
		self.writeStream = WriteStream()
		self.writeStream.parent = self
		for i=1,#self.clumps do
			self.clumps[i]:write(self.writeStream)
		end
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
	convert = function(self,target)
		if not type(target) == "string" then error("Bad argument @convert at argument 1, expected a string got "..type(target)) end
		if not EnumRWVersion[target:upper()] then error("Bad argument @convert at argument 1, invalid type "..target) end
		for i=1,#self.clumps do
			self.clumps[i]:convert(EnumRWVersion[target:upper()])
		end
		return true
	end,
	update = function(self)
		for i=1,#self.clumps do
			self.clumps[i]:getSize()
		end
	end,
}