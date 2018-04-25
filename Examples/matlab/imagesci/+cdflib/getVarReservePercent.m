function percent = getVarReservePercent(cdfId,varNum)
%cdflib.getVarReservePercent Return the compression reserve percentage
%   percent = cdflib.getVarReservePercent(cdfId,varNum) returns the 
%   compression reserve percentage for the variable specified by varNum
%   in the CDF identified by cdfId.
%   
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarReservePercent.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       percent = cdflib.getVarReservePercent(cdfid,varnum);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setVarReservePercent

%   Copyright 2009-2013 The MathWorks, Inc.

percent = cdflibmex('getVarReservePercent',cdfId,varNum);
