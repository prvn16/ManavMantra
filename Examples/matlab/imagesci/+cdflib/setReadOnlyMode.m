function setReadOnlyMode(cdfId,mode)
%cdflib.setReadOnlyMode Set read-only mode of CDF
%   cdflib.setReadOnlyMode(cdfId,mode) sets the read-only mode of the
%   CDF identified by cdfId.   The mode may be either one of the strings
%   'READONLYon' or 'READONLYoff', or the numeric equivalent.  
%
%   This function should only be applied to CDFs that have been just 
%   opened, not those that have just been created.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetReadOnlyMode.  
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       cdflib.setReadOnlyMode(cdfid,'READONLYon');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getReadOnlyMode, cdflib.getConstantNames, 
%   cdflib.getConstantValue.

% Copyright 2009-2013 The MathWorks, Inc.

if ischar(mode)
	mode = cdflibmex('getConstantValue',mode);
end
cdflibmex('setReadOnlyMode',cdfId,mode);
