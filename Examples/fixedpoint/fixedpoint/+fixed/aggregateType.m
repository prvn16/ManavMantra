function aggNT = aggregateType(a, b)
%aggregateType Compute the aggregate numerictype
%   Syntax: aggNT = aggregateType(A, B)
%
%   A and B input arguments may be integers, binary point scaled
%   fixed-point FI objects, or numerictype objects. The aggregate
%   numerictype of A and B is the smallest binary point scaled numerictype
%   that is able to represent both the full range and full precision of the
%   numerictypes of A and B.
%
%   Examples:
%
%   a_nt  = numerictype(true,16,13); % a_nt: can represent range [-4, 4)
%   b_nt  = numerictype(true,18,16); % b_nt: one LSB can represent 2^-16
%   aggNT = fixed.aggregateType(a_nt, b_nt) % numerictype(true,19,16)
%
%   a_fi  = fi( pi, 0, 16, 14); % Unsigned, WordLength: 16, FractionLength: 14
%   b_fi  = fi(-pi, 1, 24, 21); % Signed,   WordLength: 24, FractionLength: 21
%   aggNT = fixed.aggregateType(a_fi, b_fi) % numerictype(true,24,21)
%
%   a_fi  = fi( pi, 0, 16, 14); % Unsigned, WordLength: 16, FractionLength: 14
%   cInt  = uint8(0);           % Unsigned, WordLength:  8, FractionLength:  0
%   aggNT = fixed.aggregateType(a_fi, cInt) % numerictype(false,22,14)
%
%   See also numerictype, fi

%   Copyright 2011-2016 The MathWorks, Inc.

%#codegen

    if (~isempty(coder.target)) && eml_ambiguous_types
        % codegen ambiguous-types default
        aggNT = numerictype(1,32,0);
        
    elseif ((isinteger(a) || isfi(a) || isnumerictype(a)) && ...
            (isinteger(b) || isfi(b) || isnumerictype(b)))
        % Treat as binary point scaled fixed-point (including Scaled doubles)
        if ~((isinteger(a) || isscalingbinarypoint(a))  && ...
             (isinteger(b) || isscalingbinarypoint(b)))
            throwInpArgError();
        end

        aNT = localGetInpArgNT(a); % numerictype for "a" input
        bNT = localGetInpArgNT(b); % numerictype for "b" input
        if isequal(aNT, bNT)
            aggNT = aNT; return; % EARLY RETURN
        end

        [aSigned, aFracLen, aIntBits] = localGet_SG_FL_IB(aNT);
        [bSigned, bFracLen, bIntBits] = localGet_SG_FL_IB(bNT);
        
        aggIntBits = localGetIntBits(aSigned, aIntBits, bSigned, bIntBits);
        aggFracLen = max(aFracLen, bFracLen);
        aggWordLen = aggIntBits + aggFracLen;
        aggSignVal = aSigned || bSigned;
        
        if aggWordLen>128 && ~isempty(coder.target)
            eml_invariant(false,eml_message('fixed:fi:maxWordLengthExceeded', aggWordLen, 128));
        end
        
        if (~isinteger(a) && isscaleddouble(a)) || (~isinteger(b) && isscaleddouble(b))
            % Scaled double: binary point scaling
            aggNT = numerictype(...
                'Signed',         aggSignVal,...
                'WordLength',     aggWordLen,...
                'FractionLength', aggFracLen,...
                'DataTypeMode',   'Scaled double: binary point scaling');
        else
            % Fixed-point: binary point scaling
            aggNT = numerictype(aggSignVal, aggWordLen, aggFracLen);
        end
        
    else
        throwInpArgError(); % Unsupported input argument type
    end

end

% =========================================================================
function uNT = localGetInpArgNT(u)
    if isnumerictype(u)
        uNT = u;
    elseif isfi(u)
        if isempty(coder.target)
            uNT = numerictype(u); % Simulation
        else
            uNT = eml_typeof(u);  % Code generation
        end
    else
        uNT = numerictype(class(u));
    end
end

% =========================================================================
function [uSG, uFL, uIB] = localGet_SG_FL_IB(uNT)
    uSG = uNT.Signed;
    uFL = uNT.FractionLength;
    uIB = uNT.WordLength - uFL;
end

% =========================================================================
function aggIntBits = localGetIntBits(aSigned, aIntBits, bSigned, bIntBits)
    if isequal(aSigned, bSigned)
        aggIntBits = max(aIntBits, bIntBits);
    elseif aIntBits == bIntBits
        % Account for extra sign bit for unsigned-to-signed conversion
        aggIntBits = aIntBits + 1;
    elseif aIntBits > bIntBits
        if aSigned
            % Case (aIntBits > bIntBits), and also:
            %   A is signed (B is unsigned) -> A has enough int bits for both.
            aggIntBits = aIntBits;
        else
            % Case (aIntBits > bIntBits), and also:
            %   A is unsigned (B is signed)
            aggIntBits = aIntBits + 1;
        end
    elseif bSigned
        % Case (bIntBits > aIntBits), and also:
        %   B is signed (A is unsigned) -> B has enough int bits for both.
        aggIntBits = bIntBits;
    else
        % Case (bIntBits > aIntBits), and also:
        %   B is unsigned (A is signed)
        aggIntBits = bIntBits + 1;
    end
end

% =========================================================================
function throwInpArgError()
    if isempty(coder.target)
        error(message('fixed:fi:inputsMustBeFixPtBPSOrNumTypeOrInt'));
    else
        eml_invariant(false, ...
                      eml_message('fixed:fi:inputsMustBeFixPtBPSOrNumTypeOrInt'));
    end
end

% LocalWords:  agg nt
