function info = inquire(cdfId)
%cdflib.inquire Return basic characteristics of CDF
%   info = cdflib.inquire(cdfId) returns basic characteristics of the CDF 
%   identified by cdfId.  info is a structure with the following fields:
%
%     encoding   - the encoding of the variable data and attribute entry
%                  data
%     majority   - the majority of the variable data
%     maxRec     - the maximum record written to a CDF variable 
%     numVars    - the number of CDF variables 
%     numvAttrs  - the number of variable attributes 
%     numgAttrs  - the number of global attributes 
%  
%   This function corresponds to the CDF library C API routine 
%   CDFinquireCDF and CDFgetNumgAttributes.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       info = cdflib.inquire(cdfid);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.inquireVar.

% Copyright 2009-2013 The MathWorks, Inc.


[encoding,majority,maxRec,numVars] = cdflibmex('inquire',cdfId);
info.encoding = encoding;
info.majority = majority;
info.maxRec = maxRec;
info.numVars = numVars;

info.numvAttrs = cdflibmex('getNumvAttributes',cdfId);
info.numgAttrs = cdflibmex('getNumgAttributes',cdfId);
