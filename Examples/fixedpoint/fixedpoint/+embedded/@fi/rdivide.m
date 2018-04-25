function c = rdivide(a,b)
%./ Right array divide.
%    RDIVIDE(A,B) is called for A./B.
%
%    If either A or B is a fi object, then the output type is the same as
%    the "Inherit via internal rule" in the Simulink Divide block.
%    The Simulink documentation is found in
%
%       Fixed-Point Designer User's Guide >
%         Recommendations for Arithmetic and Scaling >
%         Division >
%         Inherited Scaling for Speed
%
%    The Inherited Scaling for Speed algorithm is to make it resolve into a
%    simple integer divide. Here is the formula:
%
%       C = A/B = (Qa*2^-fa)/(Qb*2^-fb) = (Qa/Qb)*2^-(fa-fb)
%
%    where Q denotes the stored integer and f denotes the fraction length.
%
%    Output Signedness:
%      If either input is Signed, then the output is Signed.
%      If both inputs are Unsigned, then the output is Unsigned.
%
%    Output WordLength:
%      Output wordlength is the max of the input wordlength.
%
%    Output FractionLength:
%      In C = A/B,
%
%        C.fractionlength = A.FractionLength - B.FractionLength
%
%    Inter-operation with builtin integers:
%      Builtin integers are treated as fixed-point. In other words,
%
%        A = fi(pi);
%        B = int8(2);
%        C = A/B
%
%      treats B as an s8,0 fi object.
%
%    Inter-operation with constants:
%      In Embedded MATLAB, treat constant integers as fixed-point with
%      fraction-length 0 (i.e. do not autoscale). For example
%
%        A = fi(pi);
%        C = A/2
%
%      treats 2 as fixed-point data with fraction-length 0, and the same word
%      length as A.
%
%    Inputs with mixed data types:
%      Similar to all other fi operators, when A and B have different data
%      types, then the data type with the higher precedence determines the
%      output type.
%
%      The order of precedence is:
%        Scaled double
%        Fixed point
%        builtin double
%        builtin single
%
%      If both A and B are fi objects, then only ScaledDouble and FixedPoint
%      datatypes are allowed to mix. All other combinations produce an
%      error.
%
%    Limitations:
%      Only element-wise division is supported.
%        A/B is supported only when B is a scalar.
%        A./B is supported when A and B have the same size, or when one is a
%        scalar.
%
%      The denominator B must be real.
%        A./B and A/B error if B is complex
%
%      If A is complex, then the division is done by
%        C = complex(real(A)/B, imag(A)/B)
%
%      Slope/bias arithmetic is not supported.
%
%
%   See also EMBEDDED.FI/MRDIVIDE, RDIVIDE.

%   Thomas A. Bryan and Becky Bryan, 30 December 2008
%   Copyright 2008-2012 The MathWorks, Inc.
%     
    if isfi(a) && isfi(b)
        c = fidivide(a,b);
    elseif isa(a,'double')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a ./ double(b);
        else
            c = fidivide(a,b);
        end
    elseif isa(b,'double')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = double(a) ./ b;
        else
            c = fidivide(a,b);
        end
    elseif isa(a,'single')
        F = get(b,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = a ./ single(b);
        else
            c = fidivide(a,b);
        end
    elseif isa(b,'single')
        F = get(a,'fimath');
        if strcmp(F.FixedOpFloatingYields,'Floating')
            c = single(a) ./ b;
        else
            c = fidivide(a,b);
        end
    else
        c = fidivide(a,b);
    end
    
end

function c = fidivide(a,b)
%FIDIVIDE Fixed-point divide

% If the sizes don't match, either A or B must be a scalar
    if ~isequal(size(a),size(b)) && (prod(size(a))~=1) && (prod(size(b))~=1) %#ok numel doesn't work for fi
        error(message('fixed:fi:DimAgree'));
    end
    T = computeDivideType(a,b);
    c = divide(T,a,b);
    
end

% LocalWords:  Qa Qb fb FIDIVIDE
