function tOut = eml_get_out_numerictype_for_round(tIn, num_bit_grow)
%EML_GET_OUT_NUMERICTYPE_FOR_ROUND Internal use only function

%   TOUT = EML_GET_OUT_NUMERICTYPE(TIN, NUM_BIT_GROW) generates the appropriate
%   numerictype for the output of MATLAB style rounding on a fi object 
%   with numerictype TIN. TIN is expected to have DataType 'Fixed' or 
%   'ScaledDouble'. 
%   This function is used by Embedded Matlab.

% Copyright 2007-2011 The MathWorks, Inc.

if ~isscaledtype(tIn)
    error(message('fixed:numerictype:inputNTNotFixedOrSD'));
end

tOut = tIn;

if tIn.FractionLength > 0

    tOut.WordLength = max((tIn.WordLength - tIn.FractionLength + num_bit_grow), ...
                        (1 + double(tIn.Signed)));

    tOut.FractionLength = 0;

end
