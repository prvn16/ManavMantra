function c = times(a,b)
%TIMES  Element-by-element multiplication of fi objects
%   C = TIMES(A,B) is the element-by-element product of A and B.
%   A and B must have the same dimensions unless one of them is a scalar.
%   A scalar can be multiplied into anything.
%   C = TIMES(A,B) is called for the syntax A .* B when A or B is a fi 
%   object.
%   TIMES does not support fi objects of data type boolean.
%
%   See also EMBEDDED.FI/PLUS, EMBEDDED.FI/MINUS, EMBEDDED.FI/MTIMES,
%            EMBEDDED.FI/UMINUS

%   Copyright 1999-2014 The MathWorks, Inc.

    if isfi(a) && isboolean(a)
        a = logical(a);
    end
    if isfi(b) && isboolean(b)
        b = logical(b);
    end
    if islogical(a) && islogical(b)
        c = a .* b;
    elseif isfi(a) && isfi(b)
        c = fitimes(a,b);
    elseif isa(a,'double')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a .* double(b);
        else
            c = fitimes(a,b);
        end
    elseif isa(b,'double')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = double(a) .* b;
        else
            c = fitimes(a,b);
        end
    elseif isa(a,'single')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a .* single(b);
        else
            c = fitimes(a,b);
        end
    elseif isa(b,'single')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = single(a) .* b;
        else
            c = fitimes(a,b);
        end
    else
        c = fitimes(a,b);
    end
    
end
