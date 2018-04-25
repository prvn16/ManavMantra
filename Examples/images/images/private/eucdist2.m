function varargout = eucdist2(varargin)
%EUCDIST2 Compute 2-D Euclidean distance transform.
%   D = EUCDIST2(BW) computes the Euclidean distance transform on the input 
%   binary image BW, which must be 2-D.  Specifically, it computes the
%   distance to the nearest nonzero-valued pixel.
%    
%   [D,L] = EUCDIST2(BW) returns a linear index array L representing a
%   nearest-neighbor map.  L(r,c) is the linear index of the nonzero-valued
%   element of BW closest to (r,c).
%
%   See also BWDIST.

%   Copyright 1993-2003 The MathWorks, Inc.

%#mex

error('images:eucdist2:missingMEXFile', 'Missing MEX-file: %s', mfilename);
