function applylut(varargin)
%APPLYLUT Neighborhood operations using lookup tables.
%   APPLYLUT is not supported with gpuArray.  Use BWLOOKUP instead.
%
%   See also GPUARRAY/BWLOOKUP, GPUARRAY.

%   Copyright 2012-2013 The MathWorks, Inc.

error(message('images:applylut:noGPU'))
