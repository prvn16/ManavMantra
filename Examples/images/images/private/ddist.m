function varargout = ddist(varargin)
%DDIST Compute discrete distance transform.
%   D = DDIST(BW,N) computes the discrete distance transform on the
%   input binary image BW.  Specifically, it computes the distance
%   to the nearest zero-valued pixel.  This is the opposite of the
%   distance transform spec for the IPT function BWDIST, so that
%   function complements its input before passing it in here.
%   If N is 4 a city-block distance is computed; if N is 8 a chessboard
%   distance is computed.
%
%   [D,L] = DDIST(BW,N) returns a linear index array L representing
%   a nearest-neighbor map.  L(r,c) is the linear index of the zero-valued
%   element of BW closest to (r,c).
%
%   See also BWDIST.

%   Copyright 1993-2010 The MathWorks, Inc.

%#mex

error('images:ddist:missingMexFile', 'Missing MEX-file: %s', mfilename)
