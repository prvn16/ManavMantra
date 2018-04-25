function val = isa(hndl,type)
%SCRIBEHANDLE/ISA Test isa for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

if strcmpi(class(hndl), type)
   val = 1;
else
   val = builtin('isa',hndl,type);
end
