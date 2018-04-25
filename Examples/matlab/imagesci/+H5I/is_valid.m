function tf = is_valid(obj_id)
%H5I.is_valid  Determine if specified identifier is valid. 
%   tf = H5I.is_valid(obj_id) determines whether the identifier obj_id is
%   valid. 
%
%   Example:
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.close(fapl);
%       if H5I.is_valid(fapl);
%           fprintf('File access property list is valid.\n');
%       else
%           fprintf('File access property list is not valid.\n');
%       end
%
%   See also H5I.

%   Copyright 2009-2013 The MathWorks, Inc.

tf = H5ML.hdf5lib2('H5Iis_valid', obj_id);            
