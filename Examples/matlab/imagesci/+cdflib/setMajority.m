function setMajority(cdfId,majority)
%cdflib.setMajority Specify variable majority of CDF
%   cdflib.setMajority(cdfId,majority) specifies the variable majority of 
%   the CDF identified by cdfId.  The majority can be one of the strings
%   'ROW_MAJOR' or 'COLUMN_MAJOR', or the numeric equivalent. 
%
%   Note:  The majority setting is an external mechanism.  The cdflib I/O
%   routines always import data into MATLAB with the fastest-varying
%   dimension first.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetMajority.  
%
%   Example:  
%       cdfid = cdflib.create('myfile.cdf');
%       cdflib.setMajority(cdfid,'COLUMN_MAJOR');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getMajority, cdflib.getConstantValue.

% Copyright 2009-2013 The MathWorks, Inc.

if ischar(majority)
	majority = cdflibmex('getConstantValue',majority);
end
cdflibmex('setMajority',cdfId,majority);
