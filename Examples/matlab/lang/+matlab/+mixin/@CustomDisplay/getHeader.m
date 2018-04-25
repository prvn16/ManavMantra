%getHeader Build and return display header text
%   S = getHeader(A) builds and returns the text used as the header when 
%   displaying the object A.  This method is called once each time A is
%   displayed.
%
%   Override this method as a protected method when a custom header is needed.  
%   The overriding implementation must support all of the possible states an 
%   object might be in, including scalar, non-scalar, empty, and deleted (if A
%   is an instance of a handle class).
%
%   The default implementation creates a header as follows:
%   If A is scalar, the class name is returned;
%   If A is non-scalar, the dimensions and class name are returned;
%   If A is a deleted handle, "handle to deleted 'classname'" is returned
%
%   In all cases, the class name is the simple name of the class (i.e.,
%   the non-package-qualified name), and is hyperlinked to MATLAB
%   documentation for the class, to be displayed in the helpPopup
%   window.
%
%   See also matlab.mixin.CustomDisplay, getFooter, getPropertyGroups

%   Copyright 2013-2015 The MathWorks, Inc.
%   Built-in method.   
