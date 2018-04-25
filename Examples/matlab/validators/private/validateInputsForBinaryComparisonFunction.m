function validateInputsForBinaryComparisonFunction(A, B, V)
    if ~isscalar(B)
        throw(createValidatorException('MATLAB:validators:mustBeScalar', V));
    end
    
    if ~isNumericOrLogical(A) || ~isNumericOrLogical(B)
        throw(createValidatorException('MATLAB:validators:mustBeNumericOrLogical'));
    end
    
    if ~isreal(A) || ~isreal(B)
        throw(createValidatorException('MATLAB:validators:mustBeReal'));
    end
end
