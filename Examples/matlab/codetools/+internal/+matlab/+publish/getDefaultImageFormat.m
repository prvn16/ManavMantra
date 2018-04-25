function imageFormat = getDefaultImageFormat(format,method)

% Copyright 1984-2009 The MathWorks, Inc.

if strcmp(format,'latex') && strcmp(method,'print')
    imageFormat = 'epsc2';
elseif strcmp(format,'pdf')
    imageFormat = 'bmp';
else
    imageFormat = 'png';
end
end
