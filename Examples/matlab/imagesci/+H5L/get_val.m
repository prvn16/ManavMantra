function linkval = get_val(link_loc_id,link_name,lapl_id, varargin)
%H5L.get_val  Return value of symbolic link.
%   linkval = H5L.get_val(link_loc_id,link_name,lapl_id) returns
%   the value of a symbolic link.
%
%   link_loc_id is a file or group identifier.  link_name identifies a
%   symbolic link and is defined relative to link_loc_id. Symbolic links
%   include soft and external links and some user-defined links.
%
%   In the case of soft links, linkval is a cell array containing the path 
%   to which the link points. 
%
%   In the case of external links, linkval is a cell array consisting of
%   the name of the target file and the object name.
%
%   linkval = H5L.get_val(__, Name1, Value1) returns the value of a
%   symbolic link. The name-value pair specifies the text encoding to be
%   used to interpret the link value. 
%
%   Name-Value Pairs
%   ----------------
%   'TextEncoding'  - Defines the character encoding to be used for
%                     interpreting the link value. It takes values
%                     'system' or 'UTF-8'. Default value is 'system'. 
%
%   This function corresponds to the H5L.get_val and H5Lunpack_elink_val
%   functions in the HDF5 1.8 C API.
%
%   Example:
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/g1/g1.2/g1.2.1');
%       linkval = H5L.get_val(gid,'slink','H5P_DEFAULT');
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5L.

%   Copyright 2009-2017 The MathWorks, Inc.

useUtf8 = matlab.io.internal.imagesci.h5ParseEncoding(varargin);
linkval = H5ML.hdf5lib2('H5Lget_val',link_loc_id,link_name,lapl_id, useUtf8);            

