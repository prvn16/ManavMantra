function [status,description] = mlappfinfo(filename)
%MLAPPFINFO Text description of MLAPP-file contents.
%
%   See also FINFO.

% Copyright 2014 The MathWorks, Inc.
description = matlab.internal.getCode(filename);
status = 'MLAPP-file';
