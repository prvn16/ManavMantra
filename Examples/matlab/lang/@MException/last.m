%LAST Return last uncaught exception.
%   ME = MException.last displays the contents of the MException object 
%   representing your most recent uncaught error. This is a static method
%   of the MException class.
%
%   MException.last('reset') sets the IDENTIFIER and MESSAGE properties
%   of the most recent exception to the empty string, the STACK property
%   to a 0-by-1 structure, and CAUSE property to an empty cell array.
%
%   Example:
%      ME = MException.last
%
%   See also MException.

%   Copyright 2007-2010 The MathWorks, Inc.
%   Built-in function.
