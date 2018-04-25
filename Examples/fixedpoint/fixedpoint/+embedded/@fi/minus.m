function c = minus(a,b)
%MINUS  Matrix difference between fi objects
%   C = MINUS(A,B) subtracts matrix B from matrix A.
%   A and B must have the same dimensions unless one is a scalar.
%   A scalar can be subtracted from another object of any size.
%   C = MINUS(A,B) is called for the syntax A - B when A or B is a fi 
%   object.
%   MINUS does not support fi objects of data type boolean.
%
%   See also EMBEDDED.FI/MTIMES, EMBEDDED.FI/PLUS, EMBEDDED.FI/TIMES,
%            EMBEDDED.FI/UMINUS

%   Copyright 1999-2014 The MathWorks, Inc.

    if isfi(a) && isboolean(a)
        a = logical(a);
    end
    if isfi(b) && isboolean(b)
        b = logical(b);
    end
    if islogical(a) && islogical(b)
        c = a - b;
    elseif isfi(a) && isfi(b)
        c = fiminus(a,b);
    elseif isa(a,'double')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a - double(b);
        else
            c = fiminus(a,b);
        end
    elseif isa(b,'double')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = double(a) - b;
        else
            c = fiminus(a,b);
        end
    elseif isa(a,'single')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a - single(b);
        else
            c = fiminus(a,b);
        end
    elseif isa(b,'single')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = single(a) - b;
        else
            c = fiminus(a,b);
        end
    else
        c = fiminus(a,b);
    end
    
end
