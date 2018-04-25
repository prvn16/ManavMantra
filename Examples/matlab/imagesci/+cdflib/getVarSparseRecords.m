function stype = getVarSparseRecords(cdfId,varNum)
%cdflib.getVarSparseRecords Return sparse records type
%   stype = cdflib.getVarSparseRecords(cdfId,varNum) returns the sparse 
%   records type of the variable identified by varNum in the CDF 
%   identified by cdfId.
%
%   The value for stype can be either 'NO_SPARSERECORDS', 
%   'PAD_SPARSERECORDS', 'PREV_SPARSERECORDS', or the numeric equivalent.
%   as retrieved by cdflib.getConstantValue.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzSparseRecords.  
%
%   Example:  Determine the record type for each variable in a file.
%       cdfId = cdflib.open('example.cdf');
%       info = cdflib.inquire(cdfId);
%       for j = 0:(info.numVars-1)
%           name = cdflib.getVarName(cdfId,j);
%           type = cdflib.getVarSparseRecords(cdfId,j);
%           fprintf('Variable "%s":  %s\n', name, type );
%       end
%       cdflib.close(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setVarSparseRecords.

%   Copyright 2009-2013 The MathWorks, Inc.

stype = cdflibmex('getVarSparseRecords',cdfId,varNum);
