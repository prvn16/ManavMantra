function aObj = editsize(aObj, varargin)
%AXISTEXT/EDITSIZE Edit font size for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2007 The MathWorks, Inc. 

try
   size = str2double(varargin{1});
   aObj = set(aObj,'FontSize',size);
catch
   error(message('MATLAB:editsize:InvalidAction'));
end

