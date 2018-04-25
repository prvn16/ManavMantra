function x = xscal_gpu(n,a,x,ix0,incx)
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
        fun = 'gpublassscal';
        ftype = 'float';
    else
        fun = 'gpublasdscal';
        ftype = 'double';
    end
else
    if isa(x,'single')
        fun = 'gpublascscal';
        ftype = 'cuComplex';
    else
        fun = 'gpublaszscal';
        ftype = 'cuDoubleComplex';
    end
end

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun, n, cref(a, 'r', 'like', flt_type), cref(x(ix0), 'like', flt_type), incx);
else
    x = coder.internal.refblas.xscal( ...
        cast(n,coder.internal.indexIntClass), ...
        a+coder.internal.scalarEg(x), ...
        x, ix0, cast(incx,coder.internal.indexIntClass));
end

end

%--------------------------------------------------------------------------
