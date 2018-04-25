function y = xaxpy_gpu(n,a,x,ix0,incx,y,iy0,incy)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(n,ix0,incx,iy0,incy);

% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isreal(y)
    if isa(y,'single')
        fun = 'gpublassaxpy';
        ftype = 'float';
    else
        fun = 'gpublasdaxpy';
        ftype = 'double';
    end
else
    if isa(y,'single')
        fun = 'gpublascaxpy';
        ftype = 'cuComplex';
    else
        fun = 'gpublaszaxpy';
        ftype = 'cuDoubleComplex';
    end
end

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun, n, cref(a, 'r', 'like', flt_type), ...
                cref(x(ix0), 'r', 'like', flt_type), incx, ...
                cref(y(iy0), 'like', flt_type), incy);
else
    y = coder.internal.refblas.xaxpy( ...
        cast(n,coder.internal.indexIntClass), a+coder.internal.scalarEg(y), ...
        x, ix0, cast(incx,coder.internal.indexIntClass), ...
        y, iy0, cast(incy,coder.internal.indexIntClass));
end

end

%--------------------------------------------------------------------------
