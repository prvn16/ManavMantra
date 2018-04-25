%copyElement Copy scalar MATLAB object. 
%   b = copyElement(h) makes a copy of the scalar handle h and returns 
%   a scalar handle b of the same class as h.
%
%   The sealed matlab.mixin.Copyable COPY method calls the protected 
%   copyElement method to copy each object in the array.  You can 
%   override copyElement in your subclass to control the copy behavior.
%
%   See also matlab.mixin.Copyable, COPY, HANDLE
 
%   Copyright 2010-2013 The MathWorks, Inc.
%   Built-in function.
