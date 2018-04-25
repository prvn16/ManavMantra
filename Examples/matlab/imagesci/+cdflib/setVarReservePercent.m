function setVarReservePercent(cdfId,varNum,percent)
%cdflib.setVarReservePercent Specify the compression reserve percentage
%   cdflib.setVarReservePercent(cdfId,varNum,percent) specifies the 
%   compression reserve percentage for the variable specified by varNum
%   in the CDF identified by cdfId.
%
%   Fractional reserve percentages will be rounded down.
%   
%   This function corresponds to the CDF library C API routine 
%   CDFsetzVarReservePercent.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       varNum = cdflib.createVar(cdfid,'Time','cdf_int1',1,[],true,[]);
%       cdflib.setVarCompression(cdfid,varNum,'GZIP_COMPRESSION',8);
%       cdflib.setVarReservePercent(cdfid,varNum, 80);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setVarCompression, cdflib.getVarCompression.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('setVarReservePercent',cdfId,varNum,percent);
