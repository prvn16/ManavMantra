function info = inquireAttr(cdfId,attrNum)
%cdflib.inquireAttr Return information about attribute
%   info = cdflib.inquireAttr(cdfId,attrNum) returns information about the 
%   attribute specifid by attrNum in the CDF specified by cdfId.  info is a 
%   structure with the following fields:
%
%     name      - the attribute's name that corresponds to attrNum
%     scope     - either 'global' or 'variable'
%     maxgEntry - For global attributes, this is the maximum entry number used.  
%     maxEntry  - For variable attributes, this is the maximum variable entry 
%                 number used.  
%
%   This function corresponds to the CDF library C API routine 
%   CDFinquireAttr.
%
%   Example:
%       cdfid = cdflib.open('example.cdf');
%       attrnum = cdflib.getAttrNum(cdfid,'Description');
%       info = cdflib.inquireAttr(cdfid,attrnum);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.inquireAttrgEntry, cdflib.inquireAttrEntry.

% Copyright 2009-2013 The MathWorks, Inc.

[name,scope,g,z] = cdflibmex('inquireAttr',cdfId,attrNum);
info.name = name;
info.scope = scope;
info.maxgEntry = g;
info.maxEntry = z;

