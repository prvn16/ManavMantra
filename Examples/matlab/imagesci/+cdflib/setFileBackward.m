function setFileBackward(mode)
%cdflib.setFileBackward Set the backward mode
%   cdflib.setFileBackward(mode) sets the backward mode.  mode can be
%   one of the following strings or the numeric equivalent:
%
%     'BACKWARDFILEon'
%     'BACKWARDFILEoff'
%
%   By default, the backward mode is off.  If this routine is used with 
%   'BACKWARDFILEon', any new CDF files are created such that clients 
%   using version 2.7 of the CDF library will be able to read the file.
%   This condition will last for the duration of the MATLAB session or
%   until cdflib.setFileBackward is called again.
%
%   Example:  turn on backwards mode.
%       cdflib.setFileBackward('BACKWARDFILEon');
%
%   This function corresponds to the CDF library C API routine 
%   CDFsetFileBackward.  
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.getFileBackward, cdflib.getConstantValue.

%   Copyright 2010-2013 The MathWorks, Inc.

if ischar(mode)
	mode = cdflib.getConstantValue(mode);
end
cdflibmex('setFileBackward',mode);
