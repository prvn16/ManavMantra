function mode = getFileBackward()
%cdflib.getFileBackward Return backward mode
%   mode = cdflib.getFileBackward() returns the backward mode.  mode will be
%   one of the following strings:
%
%     'BACKWARDFILEon'
%     'BACKWARDFILEoff'
%
%   This function corresponds to the CDF library C API routine 
%   CDFgetFileBackward.  
%
%   Example:  
%       mode = cdflib.getFileBackward;
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib.setFileBackward, cdflib.getConstantValue.

%   Copyright 2010-2013 The MathWorks, Inc.

mode = cdflibmex('getFileBackward');
