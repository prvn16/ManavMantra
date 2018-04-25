function deleteAttrEntry(cdfId,attrNum,entryNum)
%cdflib.deleteAttrEntry Delete attribute entry
%   cdflib.deleteAttrEntry(cdfId,attrNum,entryNum) deletes the specified 
%   entry in the attribute identified by attrNum in the CDF specified by
%   cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFdeleteAttrzEntry.
%
%   Example:
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       attrNum = cdflib.getAttrNum(cdfid,'Description');
%       entryVal = cdflib.getAttrEntry(cdfid,attrNum,0);
%       cdflib.deleteAttrEntry(cdfid,attrNum,0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.deleteAttr

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('deleteAttrEntry',cdfId,attrNum,entryNum);
