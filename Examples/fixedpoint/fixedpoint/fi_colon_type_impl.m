function [Psigned, Py] = fi_colon_type_impl(J,D,K)
%FI_COLON_TYPE_IMPL Prototypes for fi colon arguments.
%
%   [Psigned, Py] = fi_colon_type_impl(J,D,K) determines the data
%   types for the colon operator J:D:K when one of J, D, or K is a
%   fi object.
%
%   Psigned is the prototype for a signed type that J, D, and
%   K will all fit without overflow or quantization.
%
%   Py is the prototype for the output Y of the colon operator
%   Y = J:D:K.
%
%   Helper function for @fi/colon().
%   
%   See also COLON.

%   Copyright 2011-2015 The MathWorks, Inc.
% This function is inferred in MATLAB during MATLAB Coder type inference,
% so it must be codegen-compliant.
%#codegen

    [is_fi_J,is_single_J,is_scaled_double_J,w_J,f_J,is_signed_J,F_J] = get_type(J);
    % The signedness of the increment argument D is not used to determine the
    % datatype of the output if either J or K is a fixed-point type.
    [is_fi_D,is_single_D,is_scaled_double_D,w_D,f_D,    ~      ,F_D] = get_type(D);
    [is_fi_K,is_single_K,is_scaled_double_K,w_K,f_K,is_signed_K,F_K] = get_type(K);
    
    if is_fi_J || is_fi_D || is_fi_K
        % The output will be fi.
        % The output wordlength only depends on the endpoints J and K, 
        % except when D is the only fixed-point argument.  If D is the only
        % fixed-point argument, then the output datatype is D's type.
        if is_fi_J || is_fi_K
            w = coder.internal.const(max([w_J w_K]));
        else
            w = w_D;
        end
        f_min = coder.internal.const(min([f_J f_D f_K]));
        if f_min<0
            % If the fraction length is negative, then this increases the
            % word length to make 1 representable.
            w = w-f_min;
        else
            % The else branch is required to keep MATLAB Coder inference
            % able to constant-fold w. 
            w = w; %#ok<ASGSL>
        end
        is_signed = is_signed_J || is_signed_K;
    
        % Use the first attached fimath, which is the same fimath rule as
        % concatenation [J K] or [J D K]
        if ~isempty(F_J)
            Fy = F_J;
        elseif ~isempty(F_D)
            Fy = F_D;
        elseif ~isempty(F_K)
            Fy = F_K;
        else
            Fy = int32([]);
        end

        % This is the case when changing unsigned to signed requires another bit in
        % the word length, such as fi(int8(1)):fi(uint8(255)).
        % The output wordlength only depends on the endpoints J & K if either
        % J or K is a fixed-point type.
        if is_signed && (is_fi_J&&~is_signed_J&&w_J>=w_K || ...
                         is_fi_K&&~is_signed_K&&w_K>=w_J)
            % Only add an extra bit if there is mixed signed and unsigned,
            % and the wordlength of the unsigned is greater-than or equal-to
            % the wordlength of the signed.
            w = w + 1;
        else
            % The else branch is required to keep MATLAB Coder inference
            % able to constant-fold w. 
            w = w; %#ok<ASGSL>
        end
        if is_scaled_double_J || is_scaled_double_D || is_scaled_double_K
            Ty = numerictype(is_signed, w, 0,'DataType','ScaledDouble');
        else
            Ty = numerictype(is_signed, w, 0);
        end            
        Py = setfimath(fi([],Ty),Fy); % Not just fi([],Ty,Fy) because Fy may be []
    elseif is_single_J || is_single_D || is_single_K
        % The output will be single
        Py = single([]);
        w = 23; %#ok<NASGU>
    else
        % The output will be double
        Py = double([]);
        w = 52; %#ok<NASGU>
    end


    if ~isfi(Py) || isfi(Py) && isscaleddouble(Py)
        Psigned = double([]);
    else
        % Make sure D always fits when it gets cast with Psigned, if the
        % wordlength of D is set larger than J and K
        if is_signed && isfi(D) && isfixed(D) && issigned(D)
            T_signed = numerictype(Ty, 'WordLength',max(Ty.WordLength,w_D));
        else
            T_signed = numerictype(Ty, 'WordLength',max(Ty.WordLength,w_D)+1, 'Signedness', 'Signed');
        end
        F_wrap = fimath('OverflowAction','Wrap',...
                        'RoundingMethod','Floor',...
                        'SumMode','SpecifyPrecision',...
                        'SumWordLength',T_signed.WordLength,...
                        'SumFractionLength',T_signed.FractionLength,...
                        'ProductMode','SpecifyPrecision',...
                        'ProductWordLength',T_signed.WordLength,...
                        'ProductFractionLength',T_signed.FractionLength);
        Psigned = fi([],T_signed,F_wrap);
    end
end


function [is_fi,is_single,is_scaled_double,w,f,is_signed,F] = get_type(x)
    if isinteger(x)
        % Cast builtin integers to fi
        x = fi(x);
    else
        % The else branch is required to keep MATLAB Coder inference
        % able to constant-fold x.
        x = x; %#ok<ASGSL>
    end
    is_fi = isfi(x);
    if is_fi && isfimathlocal(x)
        F = x.fimath;
    else
    F = int32([]);
    end
    if is_fi
        w = int32(x.WordLength);
        f = int32(x.FractionLength);
        is_signed = issigned(x);
        is_scaled_double = isscaleddouble(x);
        is_single = issingle(x);
        is_double = isdouble(x);
        is_logical = isboolean(x);
    else
        w = 0;
        f = 0;
        is_signed = false;  
        is_scaled_double = false;
        is_single = isa(x,'single');
        is_double = isa(x,'double');
        is_logical = isa(x,'logical');
    end
    if is_single || is_double
        w = 0;
        f = 0;
        is_fi = false;
    elseif is_logical
        w = 1;
        f = 0;
        is_fi = false;
    else
        % The else branch is required to keep MATLAB Coder inference
        % able to constant-fold w, f, is_fi.
        w = w; %#ok<ASGSL>
        f = f; %#ok<ASGSL>
        is_fi = is_fi; %#ok<ASGSL>
    end        
end

% LocalWords: Py Psigned Fy w f is_fi