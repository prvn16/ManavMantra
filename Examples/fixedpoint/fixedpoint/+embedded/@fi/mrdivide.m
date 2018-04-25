function c = mrdivide(a,b)
%/   Slash or right matrix divide.
%    MRDIVIDE(A,B) is called for A/B.
%
%    If either A or B is a fi object, then B must be a scalar in the
%    expression A/B, and the output is the same as A./B.
%
%    The data-type rules are found in the help for EMBEDDED.FI/RDIVIDE.
%
%    See also EMBEDDED.FI/RDIVIDE, MRDIVIDE.

%   Thomas A. Bryan and Becky Bryan, 30 December 2008
%   Copyright 2008-2012 The MathWorks, Inc.
%     

    if isfi(a) && isfi(b)
        c = fidivide(a,b);
    elseif isa(a,'double')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a / double(b);
        else
            c = fidivide(a,b);
        end
    elseif isa(b,'double')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = double(a) / b;
        else
            c = fidivide(a,b);
        end
    elseif isa(a,'single')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a / single(b);
        else
            c = fidivide(a,b);
        end
    elseif isa(b,'single')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = single(a) / b;
        else
            c = fidivide(a,b);
        end
    else
        c = fidivide(a,b);
    end
    
end

function c = fidivide(a,b)
%FIDIVIDE Fixed-point divide

    if prod(size(b)) ~= 1 %#ok numel doesn't work for fi objects
        error(message('fixed:fi:divideNonScalarDivisor'));
    end
    T = computeDivideType(a,b);
    c = divide(T,a,b);
    
end




