function tf = isNumericOrLogical(A)
    tf = isnumeric(A) || (islogical(A) || isa(A, 'logical'));
end
