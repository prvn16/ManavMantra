function idxmax = ixamax_gpu(n,x,ix0,incx)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(n,ix0,incx);

% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isreal(x)
    if isa(x,'single')
        fun = 'gpublasisamax';
        ftype = 'float';
    else
        fun = 'gpublasidamax';
        ftype = 'double';
    end
else
    if isa(x,'single')
        fun = 'gpublasicamax';
        ftype = 'cuComplex';
    else
        fun = 'gpublasizamax';
        ftype = 'cuDoubleComplex';
    end
end

idxmax = zeros(coder.internal.indexIntClass);

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun, n, cref(x(ix0), 'r', 'like', flt_type), ...
                incx, cref(idxmax, 'w'));
else
    idxmax = coder.internal.refblas.ixamax( ...
        cast(n,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass));
end

end
%--------------------------------------------------------------------------
