function set_fclose_degree(fapl_id, degree)
%H5P.set_fclose_degree  Set file access for file close degree.
%   H5P.set_fclose_degree(fapl_id, degree) sets the file close degree
%   property in the file access property list fapl_id to the value
%   specified by degree. degree can have any of the following values:
%   
%       'H5F_CLOSE_WEAK' 
%       'H5F_CLOSE_SEMI'
%       'H5F_CLOSE_STRONG' 
%       'H5F_CLOSE_DEFAULT'
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_fclose_degree(fapl,'H5F_CLOSE_STRONG');
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_fclose_degree.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_fclose_degree', fapl_id, degree);            
