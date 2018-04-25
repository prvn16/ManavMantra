function putVarData(cdfId,varNum,recNum,indices,datum)
%cdflib.putVarData Write single value to CDF variable
%   cdflib.putVarData(cdfId,varNum,recNum,indices,datum) writes a single 
%   datum to the variable identified by varNum in the CDF identified by
%   cdfId.  The location of the datum is specified by the record number 
%   recNum and by the dimension indices within the record.
%
%   Record numbers and dimension indices are zero-based numbers.  
%   
%   This function corresponds to the CDF library C API routine 
%   CDFputzVarData.  
%
%   Example:  Rewrite the first datum in the fourth record for the
%   'Temperature' variable.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       cdflib.putVarData(cdfid,varnum,3,[0 0],int16(999));
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.getVarData, cdflib.getVarRecordData, 
%   cdflib.hypergetVarData.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('putVarData',cdfId,varNum,recNum,indices,datum);
