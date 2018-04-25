function out = openhtml(filename)
%OPENHTML Display HTML file in the Help Browser
%   Helper function for OPEN.
%
%   See OPEN.

%   Copyright 1984-2002 The MathWorks, Inc. 

if nargout, out = []; end
web(filename);
