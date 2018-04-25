function F = eml_fimath_constructor_helper(emlInputFimath,varargin)
% EML_FIMATH_CONSTRUCTOR_HELPER Helper function for MATLAB to construct a
% fimath object for the purposes of code generation.
%
% This function does the following:
%   1) Saves the original default fimath
%   2) Temporarily sets the global fimath (changes the default)
%   3) Constructs a new FIMATH for the return
%   4) Resets the default fimath to its original value
%
% If an error occurs, the error message ID string is returned in ERR.

%   Copyright 2003-2013 The MathWorks, Inc.

if ~isempty(coder.target)
    eml_prefer_const(emlInputFimath);
    eml_prefer_const(varargin);
end

F = [];
try
    % Get the default fimath
        emlDefaultFimath = emlInputFimath;
    
    % 1) Save the original default fimath
    origDefaultFimath = fimath;
    
    % 2) Temporarily set the global fimath (change the default)
    %globalfimath(emlDefaultFimath);
    embedded.fimath.SetGlobalFimath(emlDefaultFimath);
    
    % 3) Construct a valid FIMATH for return
    F = fimath(varargin{:});
    
    % 4) Reset the default fimath to its original value
    %globalfimath(origDefaultFimath);
    embedded.fimath.SetGlobalFimath(origDefaultFimath);
catch ME
    % Reset the global fimath to its original value
    embedded.fimath.SetGlobalFimath(origDefaultFimath);
    ME.rethrow;
end
