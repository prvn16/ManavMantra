function deleteVarRecords(cdfId,varNum,startRec,endRec)
%cdflib.deleteVarRecords Delete range of records
%   cdflib.deleteVarRecords(cdfId,varNum,startRec,endRec) deletes the range 
%   of records from startRec through endRec for the variable identified 
%   by varNum in the CDF file identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFdeletezVarRecords.  
%
%   Example:  Delete the second and third elements in the 'Temperature' 
%   variable.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       cdflib.deleteVarRecords(cdfid,varnum,1,2);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib.getVarNumRecsWritten, cdflib.putVarRecordData.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('deleteVarRecords',cdfId,varNum,startRec,endRec);
