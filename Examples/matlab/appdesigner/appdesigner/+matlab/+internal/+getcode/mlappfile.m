function code = mlappfile(inputfile)
%matlab.internal.getcode.mlappfile Helper function to read code
%   This function reads the MATLAB code from MATLAB App (.mlapp) files.

% Copyright 2014 The MathWorks, Inc

code = matlab.internal.getcode.mlxfile(inputfile);

end