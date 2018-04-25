function n = getVarNumRecsWritten(cdfId,varNum)
%cdflib.getVarNumRecsWritten Return number of records written
%   numrecs = CDF.getVarNumRecsWritten(cdfId,varNum) returns number of 
%   records written for the variable identified by varNum in the CDF 
%   identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarNumRecsWritten.  
%
%   Example:
%       cdfId = cdflib.open('example.cdf');
%       varNum = 0;
%       numrecs = cdflib.getVarNumRecsWritten(cdfId,varNum);
%       cdflib.close(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVarMaxWrittenRecNum.

% Copyright 2009-2013 The MathWorks, Inc.

n = cdflibmex('getVarNumRecsWritten',cdfId,varNum);
