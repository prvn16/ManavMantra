function out = openmat(filename)
%OPENMAT   Load data from file and show preview.
%   Helper function for OPEN.
%
%   See OPEN.

%   Copyright 1984-2007 The MathWorks, Inc.

try
   out = load(filename);
catch exception;
   throw(exception);
end
