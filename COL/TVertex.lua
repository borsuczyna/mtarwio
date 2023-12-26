class "TVertex" {
	nil,
	nil,
	nil,
	read = function(self,readStream,version)
		version = version or "COLL"
		if version == "COLL" then
			self[1] = readStream:read(float)
			self[2] = readStream:read(float)
			self[3] = readStream:read(float)
		else
			self[1] = readStream:read(int16)
			self[2] = readStream:read(int16)
			self[3] = readStream:read(int16)
		end
	end,
	write = function(self,writeStream,version)
		version = version or "COLL"
		if version == "COLL" then
			writeStream:write(self[1],float)
			writeStream:write(self[2],float)
			writeStream:write(self[3],float)
		else
			writeStream:write(self[1],int16)
			writeStream:write(self[2],int16)
			writeStream:write(self[3],int16)
		end
	end,
}