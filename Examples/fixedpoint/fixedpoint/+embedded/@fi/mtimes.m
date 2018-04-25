function c = mtimes(a,b)
%MTIMES Matrix product of fi objects
%   C = MTIMES(A,B) is the matrix product of A and B.
%   A and B must be such that the number of columns in A is equal to the
%   number of rows in B, unless one of them is a scalar.
%   A scalar can multiply anything.
%   C = MTIMES(A,B) is called for the syntax A * B when A or B is a fi 
%   object.
%   MTIMES does not support fi objects of data type boolean.
%
%   See also EMBEDDED.FI/PLUS, EMBEDDED.FI/MINUS, EMBEDDED.FI/TIMES,
%            EMBEDDED.FI/UMINUS

%   Copyright 1999-2014 The MathWorks, Inc.

    if isfi(a) && isboolean(a)
        a = logical(a);
    end
    if isfi(b) && isboolean(b)
        b = logical(b);
    end
    if islogical(a) && islogical(b)
        c = a * b;
    elseif isfi(a) && isfi(b)
        c = fimtimes(a,b);
    elseif isa(a,'double')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a * double(b);
        else
            c = fimtimes(a,b);
        end
    elseif isa(b,'double')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = double(a) * b;
        else
            c = fimtimes(a,b);
        end
    elseif isa(a,'single')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a * single(b);
        else
            c = fimtimes(a,b);
        end
    elseif isa(b,'single')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = single(a) * b;
        else
            c = fimtimes(a,b);
        end
    else
        c = fimtimes(a,b);
    end
    
end
