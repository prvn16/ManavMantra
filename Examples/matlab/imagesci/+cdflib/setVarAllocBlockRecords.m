function setVarAllocBlockRecords(cdfId,varNum,firstrec,lastrec)
%cdflib.setVarAllocBlockRecords Specify range of records to be allocated
%   cdflib.setVarAllocBlockRecords(cdfId,varNum,firstrec,lastrec) specifies a 
%   range of records between firstrec and lastrec to be allocated (not 
%   written) for the variable specified by varNum in the CDF specified by 
%   cdfId.
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetzVarAllocBlockRecords.  
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib.getVarAllocRecords.

%   Copyright 2009-2013 The MathWorks, Inc.

cdflibmex('setVarAllocBlockRecords',cdfId,varNum,firstrec,lastrec);
