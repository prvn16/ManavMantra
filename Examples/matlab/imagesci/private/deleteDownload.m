function deleteDownload(filename)
%DELETEDOWNLOAD Deletes the temporary file downloaded from the URL

%   Copyright 2007-2013 The MathWorks, Inc.

try
    delete(filename);
catch me %#ok<NASGU>
    warning(message('MATLAB:imagesci:deleteDownload:removeTempFile', filename))
end
