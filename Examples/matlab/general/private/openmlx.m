function out = openmlx(filename)
%OPENMLX   Open matlab code in MATLAB Editor.  Helper function
%   for OPEN.
%
%   See OPEN.

%   Copyright 2013-2015 The MathWorks, Inc.

if nargout, out = []; end
edit(filename)

end