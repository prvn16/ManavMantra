function setVarInitialRecs(cdfId,varNum,numrecs)
%cdflib.setVarInitialRecs Specify initial number of records
%   cdflib.setVarInitialRecs(cdfId,varNum,numrecs) specifies the initial 
%   number of records to write to the variable specified by varNum in the
%   CDF specified by cdfId.  
%   
%   This function corresponds to the CDF library C API routine 
%   CDFsetzVarInitialRecs.  
%
%   Example:
%       cdfid = cdflib.create('myfile.cdf');
%       varnum = cdflib.createVar(cdfid,'Time','cdf_int1',1,[],true,[]);
%       cdflib.setVarInitialRecs(cdfid,varnum,100);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.createVar.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('setVarInitialRecs',cdfId,varNum,numrecs);
