function padvalue = getVarPadValue(cdfId,varNum)
%cdflib.getVarPadValue Return pad value
%   padvalue = cdflib.getVarPadValue(cdfId,varNum) returns the pad value of
%   the variable identified by varNum in the CDF identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetzVarPadValue.  
%
%   Example:
%       cdfId = cdflib.open('example.cdf');
%       varNum = 0;
%       padValue = cdflib.getVarPadValue(cdfId,varNum);
%       cdflib.close(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.setVarPadValue.

%   Copyright 2009-2013 The MathWorks, Inc.

padvalue = cdflibmex('getVarPadValue',cdfId,varNum);
