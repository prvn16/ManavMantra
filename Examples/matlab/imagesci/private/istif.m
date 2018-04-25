function tf = istif(filename)
%ISTIF Returns true for a TIF file.
%   TF = ISTIF(FILENAME)

%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
sig = fread(fid, 4, 'uint8');
fclose(fid);

%
% Is it a BigTiff?
if isequal(sig, [73; 73; 43; 0]) || isequal(sig, [77; 77; 0; 43])
	tf = true;
	return
end

%
% It's not BigTiff.  Check if it is classic Tiff.
tf = isequal(sig, [73; 73; 42; 0]) | isequal(sig, [77; 77; 0; 42]);
