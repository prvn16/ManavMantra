function set_gc_references(fapl_id, gc_ref)
%H5P.set_gc_references  Set garbage collection references flag.
%   H5P.set_gc_references(fapl_id, gc_ref) sets the flag for garbage
%   collecting references for the file specified by the file access
%   property list identifier, fapl_id. gc_ref is a flag setting reference
%   garbage collection to on (1) or off (0).
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_gc_references(fapl,1);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_gc_references.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_gc_references', fapl_id, gc_ref);            
