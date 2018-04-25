function ptr=libpointer(varargin)
%LIBPOINTER Creates a pointer object for use with shared libraries.
%
%   P = LIBPOINTER returns an empty (void) pointer
%
%   P = LIBPOINTER('TYPE') returns an empty pointer to the given TYPE.
%   TYPE can be any MATLAB numeric type, or a structure or enum defined in
%   a loaded library.
%
%   P = LIBPOINTER('TYPE',INITIALVALUE) returns a pointer object
%   initialized to the INITIALVALUE supplied.
%
%   See also LOADLIBRARY, LIBSTRUCT.
   
%   Copyright 2002-2008 The MathWorks, Inc. 

 ptr=lib.pointer(varargin{:});
 
