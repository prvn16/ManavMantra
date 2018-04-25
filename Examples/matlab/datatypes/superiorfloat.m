function  classname = superiorfloat(varargin)  %#ok<STOUT>
%SUPERIORFLOAT return 'double' or 'single' based on the superior input.
%
%   SUPERIORFLOAT(...) returns 'double' if superior input has class double,
%   char, or logical.
%
%   SUPERIORFLOAT(...) returns 'single' if superior input has class single.
%
%   SUPERIORFLOAT errors, otherwise.
  
%   Copyright 1984-2012 The MathWorks, Inc.

throwAsCaller( ...
    CatalogException(message('MATLAB:datatypes:superiorfloat')));

% ------------------------------------------------
function me = CatalogException(message)
% Helper function for MException

me = MException(message.Identifier, '%s', message.getString);
