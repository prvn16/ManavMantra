%GETDISP    Specialized MATLAB object property display.
%   GETDISP is called by GET when GET is called with no output argument 
%   and a single input parameter H an array of handles to MATLAB objects.  
%   This method is designed to be overridden in situations where a
%   special display format is desired to display the results returned by
%   GET(H).  If not overridden, the default display format for the class
%   is used.
%
%   See also matlab.mixin.SetGet, matlab.mixin.SetGet/GET, handle
 
%   Copyright 2007-2014 The MathWorks, Inc.
%   Built-in function.