function delete(cdfId)
%cdflib.delete Delete existing CDF file
%   cdflib.delete(cdfId) deletes an existing CDF file identified by cdfId.
%   If the CDF file is a multi-file format CDF, the variable files (having 
%   extensions of .z0, .z1, etc.) are also deleted.
%
%   This function corresponds to the CDF library C API routine 
%   CDFdeleteCDF.  
%
%   Example:
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfId = cdflib.open('myfile.cdf');
%       cdflib.delete(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.create, cdflib.setFormat

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('delete',cdfId);
