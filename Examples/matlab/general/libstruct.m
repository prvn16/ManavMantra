function ptr=libstruct(structtype,initialvalue)
%LIBSTRUCT Creates a structure pointer for use with shared libraries.
%
%   S = LIBSTRUCT('STRUCTTYPE') returns an empty libstruct of the given type
%   type can be any structure defined in a loaded library.
%
%   S = LIBSTRUCT('STRUCTTYPE',INITIALVALUE) returns a libstruct object
%   initialized to the INITIALVALUE supplied.
%
%   See also LOADLIBRARY, LIBPOINTER.
   
%   Copyright 2002-2008 The MathWorks, Inc. 
if nargin==1
    ptr=feval(['lib.' structtype]);
else
    ptr=feval(['lib.' structtype],initialvalue);
end
