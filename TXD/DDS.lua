class "DDSPixelFormat" {
	blockSize = 0x00000020, --4Bytes  (32)
	flags = EnumDDPF.D3DFORMAT, --4Bytes (DDPF)
	d3dformat = EnumD3DFormat.DXT1, --4Bytes
	RGBBitCount = 0, --4Bytes
	RBitMask = 0, --4Bytes
	GBitMask = 0, --4Bytes
	BBitMask = 0, --4Bytes
	RGBAlphaBitMask = 0, --4Bytes
	read = function(self,readStream)
		self.blockSize = readStream:read(uint32)
		self.flags = readStream:read(uint32)
		self.d3dformat = readStream:read(uint32)
		self.RGBBitCount = readStream:read(uint32)
		self.RBitMask = readStream:read(uint32)
		self.GBitMask = readStream:read(uint32)
		self.BBitMask = readStream:read(uint32)
		self.RGBAlphaBitMask = readStream:read(uint32)
	end,
	write = function(self,writeStream)
		writeStream:write(self.blockSize,uint32)
		writeStream:write(self.flags,uint32)
		writeStream:write(self.d3dformat,uint32)
		writeStream:write(self.RGBBitCount,uint32)
		writeStream:write(self.RBitMask,uint32)
		writeStream:write(self.GBitMask,uint32)
		writeStream:write(self.BBitMask,uint32)
		writeStream:write(self.RGBAlphaBitMask,uint32)
	end,
}

class "DDSCaps" {
	caps1 = EnumDDSCaps1.TEXTURE, --4Bytes (DDSCaps1)
	caps2 = EnumDDSCaps2.NONE, --4Bytes (DDSCaps2)
	reserved = string.rep("\0",4*2), --4*2Bytes
	read = function(self,readStream)
		self.caps1 = readStream:read(uint32)
		self.caps2 = readStream:read(uint32)
		self.reserved = readStream:read(bytes,8)
	end,
	write = function(self,writeStream)
		writeStream:write(self.caps1,uint32)
		writeStream:write(self.caps2,uint32)
		writeStream:write(self.reserved,bytes,8)
	end,
}

class "DDSHeader" {
	magic = 0x20534444, --4Bytes (DDS )
	blockSize = 0x0000007C,  --4Bytes (124)
	flags = 0x00001007, --4Bytes
	height = false,  --4Bytes
	width = false,  --4Bytes
	pitchOrLinearSize = 0x00002000,  --4Bytes
	depth = 0x00000000,  --4Bytes (Volume Texture)
	mipmapLevels = false,  --4Bytes
	reserved1 = string.rep("\0",4*11),  --4*11Bytes
	--Pixel Format
	pixelFormat = DDSPixelFormat(), --pixelFormat
	caps = DDSCaps(), --caps
	reserved2 = 0,  --4Bytes
	read = function(self,readStream)
		self.magic = readStream:read(uint32)
		self.blockSize = readStream:read(uint32)
		self.flags = readStream:read(uint32)
		self.height = readStream:read(uint32)
		self.width = readStream:read(uint32)
		self.pitchOrLinearSize = readStream:read(uint32)
		self.depth = readStream:read(uint32)
		self.mipmapLevels = readStream:read(uint32)
		self.reserved1 = readStream:read(bytes,4*11)
		self.pixelFormat:read(readStream)
		self.caps:read(readStream)
		self.reserved2 = readStream:read(uint32)
	end,
	write = function(self,writeStream)
		writeStream:write(self.magic,uint32)
		writeStream:write(self.blockSize,uint32)
		writeStream:write(self.flags,uint32)
		writeStream:write(self.height,uint32)
		writeStream:write(self.width,uint32)
		writeStream:write(self.pitchOrLinearSize,uint32)
		writeStream:write(self.depth,uint32)
		writeStream:write(self.mipmapLevels,uint32)
		writeStream:write(self.reserved1,bytes,4*11)
		self.pixelFormat:write(writeStream)
		self.caps:write(writeStream)
		writeStream:write(self.reserved2,uint32)
	end,
}

class "DDSMipmap" {
	size = false,
	data = false,
	read = function(self,readStream)
		self.data = readStream:read(bytes,self.size)
	end,
	write = function(self,writeStream)
		writeStream:write(self.data,bytes,self.size)
	end,
}

class "DDSTexture" {
	ddsHeader = false,
	mipmaps = false,
	read = function(self,readStream)
		self.ddsHeader = DDSHeader()
		self.ddsHeader:read(readStream)
		local size = readStream.length - readStream.readingPos
		self.mipmaps = {}
		for i=1,self.ddsHeader.mipmapLevels do
			local mipmap = DDSMipmap()
			local width = math.max(1, math.floor(self.ddsHeader.width / (2^(i-1))))
			local height = math.max(1, math.floor(self.ddsHeader.height / (2^(i-1))))
			local size = getMipMapSize(width,height,self.ddsHeader.pixelFormat.d3dformat)
			mipmap.size = size
			mipmap:read(readStream)
			self.mipmaps[i] = mipmap
		end
	end,
	write = function(self,writeStream)
		writeStream = writeStream or WriteStream()
		self.ddsHeader:write(writeStream)
		for i=1,#self.mipmaps do
			local width = math.max(1, math.floor(self.ddsHeader.width / (2^(i-1))))
			local height = math.max(1, math.floor(self.ddsHeader.height / (2^(i-1))))
			local size = getMipMapSize(width,height,self.ddsHeader.pixelFormat.d3dformat)
			self.mipmaps[i]:write(writeStream)
		end
		return writeStream
	end,
	convertFromTXD = function(self,textureNative)
		self.ddsHeader = DDSHeader()
		self.ddsHeader.height = textureNative.struct.height
		self.ddsHeader.width = textureNative.struct.width
		self.ddsHeader.mipmapLevels = textureNative.struct.mipMapCount
		self.ddsHeader.pixelFormat.d3dformat = textureNative.struct.textureFormat
		local d3dFmt = self.ddsHeader.pixelFormat.d3dformat
		if not (d3dFmt == EnumD3DFormat.DXT1 or d3dFmt == EnumD3DFormat.DXT3 or d3dFmt == EnumD3DFormat.DXT5) then return false end
		local writeStream = WriteStream()
		if textureNative.struct.mipMapCount ~= 1 then
			self.ddsHeader.caps.caps1 = bitOr(self.ddsHeader.caps.caps1,EnumDDSCaps1.MIPMAP,EnumDDSCaps1.COMPLEX)
		end
		for i=1,textureNative.struct.mipMapCount do
			--writeStream:write(#textureNative.struct.textures[i],uint32)
			writeStream:write(textureNative.struct.mipmaps[i],bytes)
		end
			-- self.ddsTextureData = writeStream:save()
		self.mipmaps = {}
		for i=1,textureNative.struct.mipMapCount do
			self.mipmaps[i] = DDSMipmap()
			self.mipmaps[i].size = #textureNative.struct.mipmaps[i]
			self.mipmaps[i].data = textureNative.struct.mipmaps[i]
		end
		return true
	end,
	convertToTXD = function(self,texNative)
		local readStream = ReadStream(self.ddsTextureData)
		local ddsTexture = DDSTexture()
		ddsTexture:read(readStream)
		local ddsHeader = ddsTexture.ddsHeader
		local d3dFmt = ddsHeader.pixelFormat.d3dformat
		if not (d3dFmt == EnumD3DFormat.DXT1 or d3dFmt == EnumD3DFormat.DXT3 or d3dFmt == EnumD3DFormat.DXT5) then return false end
		texNative.struct.width = ddsHeader.width
		texNative.struct.height = ddsHeader.height
		texNative.struct.textureFormat = ddsHeader.pixelFormat.d3dformat
		texNative.struct.mipMapCount = ddsHeader.mipmapLevels
		texNative.struct.mipmaps = {}
		for i=1,ddsHeader.mipmapLevels do
			texNative.struct.mipmaps[i] = ddsTexture.mipmaps[i].data
		end
		return true
	end,
	saveFile = function(self,fileName)
		local ddsData = self:write()
		local file = fileCreate(fileName)
		fileWrite(file,ddsData:save())
		fileClose(file)
	end,
}