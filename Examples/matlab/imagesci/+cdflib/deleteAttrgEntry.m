function deleteAttrgEntry(cdfId,attrNum,entryNum)
%cdflib.deleteAttrgEntry Delete entry in global attribute
%   cdflib.deleteAttrgEntry(cdfId,attrNum,entryNum) deletes the specified 
%   entry in the global attribute identified by attrNum in the CDF 
%   specified by cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFdeleteAttrgEntry.  
%
%   Example:
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       attrNum = cdflib.getAttrNum(cdfid,'SampleAttribute');
%       entryVal = cdflib.getAttrgEntry(cdfid,attrNum,0);
%       cdflib.deleteAttrgEntry(cdfid,attrNum,0);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.deleteAttr, cdflib.deleteAttrEntry.


%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('deleteAttrgEntry',cdfId,attrNum,entryNum);


