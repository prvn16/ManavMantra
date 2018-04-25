function [T,ERRID,ERR_EXTRA_ARG] = eml_numerictype_constructor_helper(maxWL,varargin)
    % EML_NUMERICTYPE_CONSTRUCTOR_HELPER Helper function for MATLAB to construct a
    % numerictype object.
    
    %   Copyright 2003-2017 The MathWorks, Inc.
    
    % T, ERRID and ERR_EXTRA_ARG defined before the try, catch so if caught
    % the values can still be returned. Supressing the warning for T = []
    % being unused because the definition is needed if the try is
    % unsuccessful.
    T = []; %#ok<NASGU>
    ERRID = '';
    ERR_EXTRA_ARG = [];
    
    try
        T = numerictype(varargin{:});
        % Check the Numerictype's WordLength and error if > 32 bits
        if strcmpi(T.DataType,'Fixed') && (T.WordLength > double(maxWL))
            ERRID = 'fixed:numerictype:invalidMaxWordLengthCodegen';
            ERR_EXTRA_ARG = double(maxWL)+1;
            return;
        end
        % G706888: 1-bit signed is not supported.
        if strcmpi(T.DataType,'Fixed') && ~isequal(T.Signedness, 'Unsigned') && (T.WordLength == 1)
            ERRID = 'fixed:numerictype:invalidMinWordLengthCodegen';
            return;
        end
    catch ME
      rethrow(ME);        


    end
