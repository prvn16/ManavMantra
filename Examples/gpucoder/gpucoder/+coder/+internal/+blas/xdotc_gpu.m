function d = xdotc_gpu(n,x,ix0,incx,y,iy0,incy)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(n,ix0,incx,iy0,incy);

% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isreal(C)
    if isa(C, 'single')
        fun = 'gpublassdot';
        ftype = 'float';
    else
        fun = 'gpublasddot';
        ftype = 'double';
    end
else
    if isa(C, 'single')
        fun = 'gpublascdotc';
        ftype = 'cuComplex';
    else
        fun = 'gpublaszdotc';
        ftype = 'cuDoubleComplex';
    end
end

d = coder.internal.scalarEg(x);

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun, n, cref(x(ix0), 'r', 'like', flt_type), ...
                incx, cref(y(iy0), 'r', 'like', flt_type), ...
                incy, cref(d, 'w', 'like', flt_type));
else
    d = coder.internal.refblas.xdotc( ...
        cast(n,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass), ...
        y, iy0, cast(incy,coder.internal.indexIntClass));
end

end

%--------------------------------------------------------------------------
