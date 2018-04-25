function validateInputForUnaryComparisonFunction(A)
    if ~isNumericOrLogical(A)
        throw(createValidatorException('MATLAB:validators:mustBeNumericOrLogical'));
    end

    if ~isreal(A)
        throw(createValidatorException('MATLAB:validators:mustBeReal'));
    end
end
