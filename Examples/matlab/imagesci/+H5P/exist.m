function value = exist(prop_id, name)
%H5P.exist  Determine if specified property exists in property list.
%   value = H5P.exist(prop_id, name) returns a positive value if the 
%   property specified by the text string name exists within the property 
%   list or class specified by prop_id.  
%
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       if H5P.exist(fapl,'sieve_buf_size')
%           fprintf('sieve buffer size property exists\n');
%       else
%           fprintf('sieve buffer size property does not exist\n');
%       end
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

value = H5ML.hdf5lib2('H5Pexist', prop_id, name);            
