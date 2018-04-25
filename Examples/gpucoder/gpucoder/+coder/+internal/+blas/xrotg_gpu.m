function [a,b,c,s] = xrotg_gpu(a,b)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');

% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isreal(a)
    if isa(a,'single')
        fun = 'gpublassrotg';
        ftype = 'float';
    else
        fun = 'gpublasdrotg';
        ftype = 'double';
    end
else
    if isa(a,'single')
        fun = 'gpublascrotg';
        ftype = 'cuComplex';
    else
        fun = 'gpublaszrotg';
        ftype = 'cuDoubleComplex';
    end
end

% Declare C and S.
c = zeros(class(a)); % C is always real.
s = coder.internal.scalarEg(a); % S may be complex.

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun, cref(a, 'like', flt_type), ...
                cref(b, 'like', flt_type), ...
                cref(c, 'w', 'like', flt_type), ...
                cref(s, 'w', 'like', flt_type));
else
    [a,b,c,s] = coder.internal.refblas.xrotg(a,b);
end

end
    

%--------------------------------------------------------------------------
