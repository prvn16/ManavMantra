function setVarSparseRecords(cdfId,varNum,stype)
%cdflib.setVarSparseRecords Specify sparse records type
%   cdflib.setVarSparseRecords(cdfId,varNum,stype) specifies the sparse 
%   records type of the variable identified by varNum in the CDF 
%   identified by cdfId.
%
%   The value for stype can be either 'NO_SPARSERECORDS', 
%   'PAD_SPARSERECORDS', 'PREV_SPARSERECORDS', or the numeric equivalent.
%   as retrieved by cdflib.getConstantValue.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetzSparseRecords.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       varnum = cdflib.createVar(cdfid,'Time','cdf_int1',1,[],true,[]);
%       cdflib.setVarSparseRecords(cdfid,varnum,'PAD_SPARSERECORDS');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVarSparseRecords, cdflib.getConstantValue.

%   Copyright 2009-2013 The MathWorks, Inc.


if ischar(stype)
	stype = cdflibmex('getConstantValue',stype);
end
cdflibmex('setVarSparseRecords',cdfId,varNum,stype);
