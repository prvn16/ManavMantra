function tf = ishdf(filename)
%ISHDF Returns true for an HDF file.
%   TF = ISHDF(FILENAME)

%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
sig = fread(fid, 4, 'uint8');
fclose(fid);
tf = isequal(sig, [14; 3; 19; 1]);
