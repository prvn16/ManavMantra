function [isUrl, filenameOut] = getFileFromURL(uri)
%GETFILEFROMURL Detects whether the input filename is a URL and downloads
%file from the URL

%   Copyright 2007-2017 The MathWorks, Inc.

% Download remote file.
if contains(uri, '://')
  
    isUrl = true;

    if (~usejava('jvm'))
        error(message('MATLAB:imagesci:getFileFromURL:noJVM'))
    end
    
    try
        filenameOut = websave(tempname, uri);
    catch me
        error(message('MATLAB:imagesci:getFileFromURL:urlRead', uri));
    end
    
else
  
    isUrl = false;
    filenameOut = uri;
    
end
