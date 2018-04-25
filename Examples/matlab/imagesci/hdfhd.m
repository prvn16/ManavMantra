function varargout = hdfhd(varargin)
%HDFHD MATLAB gateway to the HDF HD interface.
%   HDFHD is a gateway to the HDF HD interface. 
%
%   The general syntax for HDFHD is
%   HDFHD(funcstr,param1,param2,...).  There is a one-to-one correspondence
%   between HD functions in the HDF library and valid values for funcstr.
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the operation 
%   failed.
%
%     tag_name = hdfhd('gettagsname',tag)
%       Get the name of the specified tag.
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDF, MATLAB.IO.HDF4.SD, HDFAN, HDFDF24, HDFDFR8, HDFH,
%            HDFHE, HDFHX, HDFML, HDFV, HDFVF, HDFVH, HDFVS

%   Copyright 1984-2013 The MathWorks, Inc.

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('HD',varargin{:});

