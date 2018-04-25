%getFooter Build and return display footer text
%   S = getFooter(A) builds and returns the text used as the footer when
%   displaying the object array A.  This method is called once each time A
%   is displayed.
%
%   Override this method as a protected method when a custom footer is needed.  
%   The overriding implementation must support all of the possible states an 
%   object array might be in, including scalar, non-scalar, empty, and deleted 
%   (if A is an instance of a handle class). 
%  
%   The default implementation returns an empty string.
%
%   See also matlab.mixin.CustomDisplay, getHeader, getPropertyGroups

%   Copyright 2012-2015 The MathWorks, Inc.
%   Built-in method.   

