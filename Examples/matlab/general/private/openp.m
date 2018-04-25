function out = openp(filename)
%OPENP   Open the matching .m file of a .p file if one
%   exists.  Helper function for OPEN.
%
%   See OPEN.

%   Chris Portal 1-23-98
%   Copyright 1984-2010 The MathWorks, Inc. 

if nargout, out = []; end
edit(filename)
