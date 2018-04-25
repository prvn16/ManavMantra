function putVarRecordData(cdfId,varNum,recNum,data)
%cdflib.putVarRecordData Write entire variable record
%   cdflib.putVarRecordData(cdfId,varNum,recNum,recordData) writes an
%   entire record of data to the record identified by recNum for the CDF
%   variable identified by varNum in the file identified by cdfId.
%
%   Record numbers are zero-based.
%
%   This function corresponds to the CDF library C API routine 
%   CDFputzVarRecordData.  
%
%   Example:  Reverse the first two records of the 'Temperature' variable.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       rec0 = cdflib.getVarRecordData(cdfid,varnum,0);
%       rec1 = cdflib.getVarRecordData(cdfid,varnum,1);
%       cdflib.putVarRecordData(cdfid,varnum,0,rec1);
%       cdflib.putVarRecordData(cdfid,varnum,1,rec0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVarRecordData, cdflib.putVarData, 
%   cdflib.hyperPutVarData.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('putVarRecordData',cdfId,varNum,recNum,data);
