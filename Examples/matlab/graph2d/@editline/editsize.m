function aObj = editsize(aObj, varargin)
%EDITLINE/EDITSIZE Edit editline linewidth
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2007 The MathWorks, Inc. 

try
   size = str2double(varargin{1});
   aObj = set(aObj,'LineWidth',size);
catch
    error(message('MATLAB:editsize:InvalidActionLineSize'));
end
