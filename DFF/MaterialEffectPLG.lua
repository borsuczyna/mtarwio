class "MaterialEffectPLG" {
    typeID = 0x120,
	
    extend = "Section",
	effectType = false,
	
	--0x02
	texture = false,
	unused = false,
	reflectionCoefficient = false,
	useFrameBufferAlphaChannel = false,
	useEnvMap = false,
	endPadding = false,
	--0x05
	unused = false,
	endPadding = false,
	
	methodContinue = {
		read = function(self,readStream)
			self.effectType = readStream:read(uint32)
			if self.effectType == 0x00 or self.effectType == 0x01 then
				--Nothing
			elseif self.effectType == 0x02 then
				self.unused = readStream:read(uint32)
				self.reflectionCoefficient = readStream:read(float)
				self.useFrameBufferAlphaChannel = readStream:read(uint32) == 1
				self.useEnvMap = readStream:read(uint32) == 1
				if self.useEnvMap then
					self.texture = Texture()
					self.texture.parent = self
					self.texture:read(readStream)
				end
				self.endPadding = readStream:read(uint32)
			elseif self.effectType == 0x05 then
				self.unused = readStream:read(uint32)
				self.endPadding = readStream:read(uint32)
			else
				print("Bad effectType @MaterialEffectPLG, effect ID "..self.effectType.." is not implemented")
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.effectType,uint32)
			if self.effectType == 0x00 or self.effectType == 0x01 then
				--Nothing
			elseif self.effectType == 0x02 then
				writeStream:write(self.unused,uint32)
				writeStream:write(self.reflectionCoefficient,float)
				writeStream:write(self.useFrameBufferAlphaChannel and 1 or 0,uint32)
				writeStream:write(self.useEnvMap and 1 or 0,uint32)
				if self.useEnvMap then
					self.texture:write(writeStream)
				end
				writeStream:write(self.endPadding,uint32)
			elseif self.effectType == 0x05 then
				writeStream:write(self.unused,uint32)
				writeStream:write(self.endPadding,uint32)
			else
				print("Bad effectType @MaterialEffectPLG, effect ID "..self.effectType.." is not implemented")
			end
		end,
		getSize = function(self)
			local size = 4
			if self.effectType == 0x00 or self.effectType == 0x01 then
				--Nothing
			elseif self.effectType == 0x02 then
				size = size+4*5+(self.useEnvMap and self.texture:getSize() or 0)+4
			elseif self.effectType == 0x05 then
				size = size+8+4
			end
			self.size = size
			return size
		end,
		convert = function(self,targetVersion)
			if self.useEnvMap then
				self.texture:convert(targetVersion)
			end
		end,
	}
}