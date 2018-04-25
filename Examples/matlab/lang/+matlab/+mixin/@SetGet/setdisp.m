%SETDISP    Specialized MATLAB object property display.
%   SETDISP is called by SET when SET is called with no output argument 
%   and a single input parameter H an array of handles to MATLAB objects.  
%   This method is designed to be overridden in situations where a
%   special display format is desired to display the results returned by
%   SET(H).  If not overridden, the default display format for the class
%   is used.
%
%   See also setdisp, matlab.mixin.SetGet, matlab.mixin.SetGet/set, handle
 
%   Copyright 2007-2014 The MathWorks, Inc.
%   Built-in function.
