function TF = isImageIPPFilterType(imType)
%ISIMAGEIPPFILTERTYPE queries if image type is supported by IPPFILTER.
%	TF = isImageIPPFilterType(imType) returns true if class of image
%	specified in imType is supported by IPP's filtering routines.
%
%	Note that this function is intended for use by internal clients only.

%   Copyright 2014 The MathWorks, Inc.

%We are disabling the use of IPP for double precision inputs on win32.
if strcmp(computer('arch'),'win32')
    supportedTypes = {'uint8','uint16','int16','single'};
else
    supportedTypes = {'uint8','uint16','int16','single','double'};
end

if ~any(strcmp(imType, supportedTypes))
	TF = false;
else
	TF = true;
end


end