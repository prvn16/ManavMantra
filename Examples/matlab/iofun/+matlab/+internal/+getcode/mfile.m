function out = mfile( filename )
%matlab.internal.getcode.mfile Helper function to read code
%   This function reads the MATLAB code from plain text MATLAB code (.m) files

% Copyright 2013 The MathWorks, Inc.
try
    out = fileread(filename);
catch me
    error(message('MATLAB:internal:getCode:errorReadingCodeFile',filename,me.message));
end

end


