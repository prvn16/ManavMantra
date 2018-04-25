function E = createValidatorExceptionWithValue(V, ID1, ID2)
    if isempty(V)
        E = createValidatorException(ID1);
    else
        E = createValidatorException(ID2, V);
    end
end
