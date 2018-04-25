function close(cdfId)
%cdflib.close Close CDF file
%   cdflib.close(cdfId) closes the specified CDF file identified by cdfId.  
%   You must close a CDF to guarantee that all modifications made since 
%   opening the CDF will actually be written out to file.
%
%   This function corresponds to the CDF library C API routine 
%   CDFcloseCDF.  
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.open, cdflib.create

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('close',cdfId);
