function varargout = hdfhx(varargin)
%HDFHX MATLAB gateway to HDF external data interface
%   HDFHX is a gateway to the HDF interface for manipulating linked and
%   external data elements. 
%
%   The general syntax for HDFHX is 
%   HDFHX(funcstr,param1,param2,...). There is a one-to-one correspondence
%   between HX functions in the HDF library and valid values for funcstr.
%   For example, 
%   HDFHX('setdir',pathname); corresponds to the C library call 
%   HXsetdir(pathname).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   In cases where the HDF C library accepts NULL for certain inputs, an
%   empty matrix ([] or '') can be used.
%
%  Syntaxes
%  --------
%  access_id = hdfhx('create', file_id, tag, ref, extern_name,
% 		   offset, length)
%    Create new external file special data element.
% 
%  status = hdfhx('setcreatedir',pathname);
%    Set directory location for writing external file.
%
%  status = hdfhx('setdir',pathname);
%    Set directory for locating external files.  PATHNAME may contain
%    multiple directories separated by vertical bars.
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDF, MATLAB.IO.HDF4.SD, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, 
%            HDFHE, HDFML, HDFV, HDFVF, HDFVH, HDFVS

%   Copyright 1984-2013 The MathWorks, Inc.

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('HX',varargin{:});

