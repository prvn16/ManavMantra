function [version,release,increment] = getVersion(cdfId)
%cdflib.getVersion Return release information for CDF 
%   [version,release,increment] = cdflib.getVersion(cdfId) returns the library 
%   version number, release number, and incremental number of the CDF 
%   library used to create the file identified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetVersion.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       [v,r,i] = cdflib.getVersion(cdfid);
%       cdflib.close(cdfid);
%       fprintf('Created with version %d.%d.%d.\n', v,r,i);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getLibraryVersion

% Copyright 2009-2013 The MathWorks, Inc.

[version,release,increment] = cdflibmex('getVersion',cdfId);
