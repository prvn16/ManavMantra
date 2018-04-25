function maxrec = getVarMaxAllocRecNum(cdfId,varNum)
%cdflib.getVarMaxAllocRecNum Return number of records allocated for variable
%   maxrec = cdflib.getVarMaxAllocRecNum(cdfId,varNum) returns the number 
%   of records allocated for the variable identified by varNum in the file
%   specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarMaxAllocRecNum.  
%
%   Example:  Retrieve the maximum allocated record number allocated for
%   the first variable.
%       cdfId = cdflib.open('example.cdf');
%       varNum = 0;
%       maxRecNum = cdflib.getVarMaxAllocRecNum(cdfId,varNum);
%       cdflib.close(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVarMaxWrittenRecNum.

%   Copyright 2009-2013 The MathWorks, Inc.

maxrec = cdflibmex('getVarMaxAllocRecNum',cdfId,varNum);
