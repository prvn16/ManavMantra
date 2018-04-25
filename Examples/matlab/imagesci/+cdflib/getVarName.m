function name = getVarName(cdfId,varNum)
%cdflib.getVarName Return name attached to variable
%   name = cdflib.getVarName(cdfId,varNum) returns the name of the variable
%   identified by varNum in the CDF identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarName.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       info = cdflib.inquire(cdfid);
%       for j = 0:(info.numVars-1)
%           name = cdflib.getVarName(cdfid,j);
%           fprintf('Varnum %d:  "%s"\n', j, name );
%       end
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.inquireVar.

%   Copyright 2009-2013 The MathWorks, Inc.

name = cdflibmex('getVarName',cdfId,varNum);
