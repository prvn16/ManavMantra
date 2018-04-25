function varargout = hdfvh(varargin)
%HDFVH MATLAB gateway to VH functions in the HDF Vdata interface.
%   HDFVH is a gateway to the VH functions in the HDF Vdata interface.  
%
%   The general syntax for HDFVH is
%   HDFVH(funcstr,param1,param2,...).  There is a one-to-one correspondence
%   between VH functions in the HDF library and valid values for funcstr.
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the operation
%   failed.
%
%   High-level Vdata functions
%   --------------------------
%   High-level Vdata functions write data to single-field vdatas.
%
%     vgroup_ref = hdfvh('makegroup',file_id,tags,refs,...
%                       vgroup_name,vgroup_class)
%       Groups a collection of data objects within a vgroup.
%
%     count = hdfvh('storedata',file_id,fieldname,data,...
%                       vdata_name,vdata_class)
%       Creates vdatas containing records limited to one field with one
%       component per field.  
%
%
%     count = hdfvh('storedatam',file_id,fieldname,data,...
%                     vdata_name,vdata_class)
%       Creates vdatas containing records with one field containing one or
%       more components. 
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDF, MATLAB.IO.HDF4.SD, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, 
%            HDFHE, HDFHX, HDFML, HDFV, HDFVF, HDFVS

%   Copyright 1984-2013 The MathWorks, Inc.

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('VH',varargin{:});

