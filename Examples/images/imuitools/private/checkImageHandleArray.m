function checkImageHandleArray(hImage, ~)
%checkImageHandleArray checks an array of image handles.
%   checkImageHandleArray(hImage,mfilename) validates that HIMAGE contains a
%   valid array of image handles. If HIMAGE is not a valid array,
%   then checkImageHandles issues an error for MFILENAME.

%   Copyright 1993-2011 The MathWorks, Inc.

if ~all(ishghandle(hImage,'image'))
    error(message('images:checkImageHandleArray:invalidImageHandle'))
end
