function varargout = hdfml(varargin)
%HDFML MATLAB-HDF gateway utilities.
%   HDFML provides several utilities functions for working with the
%   MATLAB-HDF gateway functions.
%
%   The general syntax for HDFML is
%   HDFML(funcstr,param1,param2,...).
%
%   The MATLAB-HDF gateway functions maintain lists of certain HDF file and
%   data object identifiers so that, for example, HDF objects and files can
%   be properly closed when a user issues the command:
%
%     clear mex
%
%   These lists are updated whenever these identifiers are created or
%   closed.  Two of the functions provided by HDFML are for manipulating
%   these identifier lists.
%
%     hdfml('closeall')
%       Closes all open registered HDF file and data object identifiers.
%
%     hdfml('listinfo')
%       Prints information about all open registered HDF file and data
%       object identifiers.
%
%     tag = hdfml('tagnum',tagname)
%       Returns tag number corresponding given tag name.
%
%     nbytes = hdfml('sizeof',data_type)
%       Returns size in bytes of specified data type.
%
%     hdfml('defaultchartype',char_type)
%       Defines the HDF data type for MATLAB strings.  Valid values for 
%       char_type are 'char8' or 'uchar8'.  The change persists until the 
%       MATLAB-HDF gateway function is cleared from memory.  MATLAB strings 
%       are mapped to char8 by default.
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDF, MATLAB.IO.HDF4.SD, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, 
%            HDFHE, HDFHX, HDFV, HDFVF, HDFVH, HDFVS

%   Copyright 1984-2013 The MathWorks, Inc.

% Call HDF.MEX to do the actual work.

[varargout{1:nargout}] = hdf('ML',varargin{:});





