function datum = getVarData(varargin)
%cdflib.getVarData Return single value from specified index
%   datum = cdflib.getVarData(cdfId,varNum,recNum,indices) returns a single
%   value from the variable identified by varNum in the CDF identified by
%   cdfId.  The location of the datum is specified by recNum, the record 
%   number, and by the dimension indices within the record.
%   
%   datum = cdflib.getVarData(cdfId,varNum,recNum) returns a single
%   value if the variable has no dimensions.  
%
%   Variable numbers, record numbers and dimension indices are zero-based 
%   numbers.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarData.  
%
%   Example:  Retrieve the first datum in the second record for the third
%   variable.
%       cdfId = cdflib.open('example.cdf');
%       varNum = 2;
%       recNum = 1;
%       indices = [0 0];
%       datum = cdflib.getVarData(cdfId,varNum,recNum,indices);
%       cdflib.close(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.putVarData, cdflib.getVarRecordData, 
%   cdflib.hypergetVarData.

%   Copyright 2009-2013 The MathWorks, Inc.

datum = cdflibmex('getVarData',varargin{:});
