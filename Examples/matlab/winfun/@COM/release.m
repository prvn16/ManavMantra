function release(obj)
%RELEASE Release a COM interface.
%  RELEASE(OBJ) releases the interface and all resources used by the
%  interface. Once an interface has been released, it is no longer valid. 
%  Subsequent operations on the MATLAB object that represents that 
%  interface will result in errors. Releasing the interface does not delete
%  the COM object itself (see delete), since other interfaces on that object
%  may still be active
%
%  See also  COM/DELETE.

% Copyright 1984-2003 The MathWorks, Inc. 
