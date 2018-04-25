function out = openm(filename)
%OPENM   Open program file in MATLAB Editor.  Helper function
%   for OPEN.
%
%   See OPEN.

%   Chris Portal 1-23-98
%   Copyright 1984-2010 The MathWorks, Inc. 

if nargout, out = []; end
edit(filename)

