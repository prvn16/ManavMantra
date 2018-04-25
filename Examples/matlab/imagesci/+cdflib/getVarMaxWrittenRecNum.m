function maxrec = getVarMaxWrittenRecNum(cdfId,varNum)
%cdflib.getVarMaxWrittenRecNum Return maximum written record number
%   maxrec = cdflib.getVarMaxWrittenRecNum(cdfId,varNum) returns the maximum
%   record number written for the variable specified by varNum in the CDF
%   specified by cdfId.  Record numbers are zero-based.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarMaxWrittenRecNum.  
%
%   Example:  Retrieve the maximum written record number for the first
%   variable.
%       cdfId = cdflib.open('example.cdf');
%       varNum = 0;
%       maxRecNum = cdflib.getVarMaxWrittenRecNum(cdfId,varNum);
%       cdflib.close(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVarMaxAllocRecNum.

%   Copyright 2009-2013 The MathWorks, Inc.

maxrec = cdflibmex('getVarMaxWrittenRecNum',cdfId,varNum);
