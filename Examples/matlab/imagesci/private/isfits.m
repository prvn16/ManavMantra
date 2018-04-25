function tf = isfits(filename)
%ISFITS Returns true for a FITS file.
%   TF = ISFITS(FILENAME)

%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
sig = fread(fid, 6, 'char=>char')';
fclose(fid);
tf = isequal(sig, 'SIMPLE');
