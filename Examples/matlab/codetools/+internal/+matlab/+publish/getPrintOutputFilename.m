function imgFilename = getPrintOutputFilename(imgNoExt,imageFormat)
% Determine the image extension from the imageFormat, e.g. "jpeg" = "jpg".

% Copyright 1984-2009 The MathWorks, Inc.

[~,printTable(:,1),printTable(:,2)] = printtables;
lookup = strmatch(imageFormat,printTable(:,1),'exact');
if isempty(lookup)
    imageExtension = imageFormat;
else
    imageExtension = printTable{lookup,2};
end
imgFilename = [imgNoExt '.' imageExtension];
end
