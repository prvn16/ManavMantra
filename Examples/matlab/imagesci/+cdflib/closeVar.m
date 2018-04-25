function closeVar(cdfId,varNum)
%cdflib.closeVar Close specified variable from multi-file format CDF
%   cdflib.closeVar(cdfId,varNum) closes the specified variable from a 
%   multi-file format CDF.  It is unnecessary to call this function 
%   on a single-file format CDF.
%
%   This function corresponds to the CDF library C API routine 
%   CDFclosezVar.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       cdflib.setFormat(cdfid,'MULTI_FILE');
%       timeVar = cdflib.createVar(cdfid,'Time','cdf_int1',1,[],true,[]);
%       spaceVar = cdflib.createVar(cdfid,'Space','cdf_int1',1,[],true,[]);
%       cdflib.closeVar(cdfid,timeVar);
%       cdflib.closeVar(cdfid,spaceVar);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.getVarnum, cdflib.setFormat, cdflib.getFormat.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('closeVar',cdfId,varNum);
