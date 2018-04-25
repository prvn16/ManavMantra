function info = inquireVar(cdfId,varNum)
%cdflib.inquireVar Return information about variable
%   info = cdflib.inquireVar(cdfId,varNum) returns information about the
%   variable specified by varNum in the CDF identified by cdfId.  The info
%   struct contains the following fields:
%
%     name        - the name of the variable
%     datatype    - the datatype
%     numElements - number of elements of the datatype
%     dims        - dimension sizes
%     recVariance - record variance
%     dimVariance - dimension variances
%
%   This function corresponds to the CDF library C API routine 
%   CDFinquirezVar.  
%
%   Example:  Retrieve information about the first variable in a file.
%       cdfId = cdflib.open('example.cdf');
%       info = cdflib.inquireVar(cdfId,0)
%       cdflib.close(cdfId);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.inquire.

% Copyright 2009-2013 The MathWorks, Inc.

[name,dtype,nelts,dims,recVary,dimVary] = cdflibmex('inquireVar',cdfId,varNum);
info.name = name;
info.datatype = dtype;
info.numElements = nelts;
info.dims = dims;
info.recVariance = recVary;
info.dimVariance = dimVary;
