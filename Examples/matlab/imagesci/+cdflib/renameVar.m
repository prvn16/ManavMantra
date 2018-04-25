function renameVar(cdfId,varNum,newName)
%cdflib.renameVar Rename existing Variable
%   cdflib.renameVar(cdfId,varNum,newName) renames the variable identified
%   by varNum in the CDF identified by cdfId.  
%   
%   This function corresponds to the CDF library C API routine 
%   CDFrenamezVar.    
%
%   Example:  Rename the 'Temperature' variable to 'Pressure'.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       cdflib.renameVar(cdfid,varnum,'Pressure');
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createVar.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('renameVar',cdfId,varNum,newName);
