EnumFilterMode = {
	NEAREST = 1,
	LINEAR = 2,
	MIPNEAREST = 3,	--one mipmap
	MIPLINEAR = 4,
	LINEARMIPNEAREST = 5,	--mipmap interpolated
	LINEARMIPLINEAR = 6,
}
EnumAddressing = {
	WRAP = 1,
	MIRROR = 2,
	CLAMP = 3,
	BORDER = 4,
}
EnumDeviceID = {
	UNKNOWN = 0,
	D3D8 = 1,
	D3D9 = 2,
	GCN = 3,
	NULL = 4,
	OPENGL = 5,
	PS2 = 6,
	SOFTRAS = 7,
	XBOX = 8,
	PSP = 9,
}
EnumFormat = {
	DEFAULT = 0,
	C1555 = 0x0100,
	C565 = 0x0200,
	C4444 = 0x0300,
	LUM8 = 0x0400,
	C8888 = 0x0500,
	C888 = 0x0600,
	D16 = 0x0700,
	D24 = 0x0800,
	D32 = 0x0900,
	C555 = 0x0A00,
	AUTOMIPMAP = 0x1000,
	PAL8 = 0x2000,
	PAL4 = 0x4000,
	MIPMAP = 0x8000,
}
EnumD3DFormat = {
	L8 = 50,
	A8L8 = 51,
	A1R5G5B5 = 25,
	A8B8G8R8 = 32,
	R5G6B5 = 23,
	A4R4G4B4 = 26,
	X8R8G8B8 = 22,
	X1R5G5B5 = 24,
    A8R8G8B8 = 21,
	DXT1 = 0x31545844,
	--DXT2 = 0x32545844,
	DXT3 = 0x33545844,
	--DXT4 = 0x34545844,
	DXT5 = 0x35545844,
}
--RW Version
EnumRWTXDVersion = {
	GTASA = {
		Platform = {
			PC = EnumDeviceID.D3D9,
			XBOX = EnumDeviceID.XBOX,
			PS2 = EnumDeviceID.PS2,
		}
	},
	GTAVC = {
		Platform = {
			PC = EnumDeviceID.D3D8,
			XBOX = EnumDeviceID.XBOX,
			PS2 = EnumDeviceID.PS2,
		}
	},
	GTA3 = {
		Platform = {
			PC = EnumDeviceID.D3D8,
			XBOX = EnumDeviceID.XBOX,
		}
	}
}
EnumDDPF = {
	ALPHAPIXELS = 0x00000001, -- surface has alpha channel
	ALPHA = 0x00000002, -- alpha only
	D3DFORMAT = 0x00000004, -- D3DFormat available
	RGB = 0x00000040, -- RGB(A) bitmap
}
--DIRECTDRAWSURFACE CAPABILITY FLAGS
EnumDDSCaps1 = {
	ALPHA	= 0x00000002, -- alpha only surface
	COMPLEX	= 0x00000008, -- complex surface structure
	TEXTURE	= 0x00001000, -- used as texture (should always be set)
	MIPMAP	= 0x00400000, -- Mipmap present
}

EnumDDSCaps2 = {
	NONE = 0x00000000,
	CUBEMAP = 0x00000200,
	CUBEMAP_POSITIVEX = 0x00000400,
	CUBEMAP_NEGATIVEX = 0x00000800,
	CUBEMAP_POSITIVEY = 0x00001000,
	CUBEMAP_NEGATIVEY = 0x00002000,
	CUBEMAP_POSITIVEZ = 0x00004000,
	CUBEMAP_NEGATIVEZ = 0x00008000,
	VOLUME = 0x00200000,
}

function rwioGetTXDVersion(gtaVer,platform)
	return EnumRWTXDVersion[gtaVer][platform]
end