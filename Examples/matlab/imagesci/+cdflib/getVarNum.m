function varNum = getVarNum(cdfId,varname)
%cdflib.getVarNum Return variable number for given variable name
%   varNum = cdflib.getVarNum(cdfId,varname) returns the variable number 
%   for the variable identified by varname in the file identified by 
%   cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarNum.  
%
%   Example:  Retrieve the variable number for the 'Latitude' variable.
%       cdfid = cdflib.open('example.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Latitude');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getVarName.

% Copyright 2009-2013 The MathWorks, Inc.


varNum = cdflibmex('getVarNum',cdfId,varname);
