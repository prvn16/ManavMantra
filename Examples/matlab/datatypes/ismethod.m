function f = ismethod(obj,name)
%ISMETHOD  True if method of object.
%   ISMETHOD(OBJ,NAME) returns 1 if the character vector NAME is a method
%   of object OBJ, and 0 otherwise.
%
%   Example:
%     Hd = dfilt.df2;
%     f = ismethod(Hd, 'order')
%
%   See also METHODS.  
  
%   Author: Thomas A. Bryan
%   Copyright 1999-2016 The MathWorks, Inc.

narginchk(2,2)

f = any(strcmp(name,methods(obj))); 