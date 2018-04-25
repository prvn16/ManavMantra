function [T, errid, errargs] = eml_fi_computeDivideType(Ta, Tb)
    %eml_fi_computeDivideType MATLAB helper function to compute the
    %quotient numerictype for A/B and A./B
    %
    %    [T, errid, errargs] = eml_fi_computeDivideType(Ta, Tb) computes
    %    the quotient numerictype T for A/B and A./B where Ta is
    %    numerictype(A) if A is a fi object or class(A) if A is not a fi
    %    object, and Tb is numerictype(B) if B is a fi object or class(B)
    %    if B is not a fi object.
    %
    %    If an error occurs, then the error id and error message arguments
    %    are returned as errid and errargs, respectively.
    %
    %    This helper function is a MATLAB code generation front-end for
    %    embedded.fi/computeDivideType.
    %
    %    See also embedded.fi/computeDivideType.
    
    %   Thomas A. Bryan and Becky Bryan, 30 December 2008
	
    %   Copyright 2008-2016 The MathWorks, Inc.
    
    T = [];
    errargs = {};
    [a, errid] = parse_inputs(Ta);
    if isempty(errid)
        [b, errid] = parse_inputs(Tb);
        if isempty(errid)
            [T, errid, errargs] = computeDivideType(a,b);
        end
    end
    
    function [x, errid] = parse_inputs(Tx)
        x = [];
        errid = '';
        
        % Parse the input types
        if isnumerictype(Tx)
            % numerictype object
            x = fi([],Tx);
        elseif ischar(Tx)
            % String that defines the class
            x = feval(Tx,0);
        else
            % Invalid input to this function
            errid = 'fi:computeDivideType:InvalidInput';
        end
    end
end

% LocalWords:  errid
% LocalWords:  errargs
