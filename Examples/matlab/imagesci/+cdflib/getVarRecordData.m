function recordData = getVarRecordData(cdfId,varNum,recNum)
%cdflib.getVarRecordData Return entire record for variable
%   data = cdflib.getVarRecordData(cdfId,varNum,recNum) returns the record 
%   corresponding to recNum for the variable identified by varNum in the
%   CDF identified by cdfId.
%
%   Record numbers are zero-based.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarRecordData.  
%
%   Example:  Retrieve the first record from the variable 'Data'.
%       cdfId = cdflib.open('example.cdf');
%       varNum = cdflib.getVarNum(cdfId,'Data');
%       recData = cdflib.getVarRecordData(cdfId,varNum,0);
%       cdflib.close(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.putVarRecordData, cdflib.getVarData, 
%   cdflib.hypergetVarData.

% Copyright 2009-2013 The MathWorks, Inc.

recordData = cdflibmex('getVarRecordData',cdfId,varNum,recNum);
