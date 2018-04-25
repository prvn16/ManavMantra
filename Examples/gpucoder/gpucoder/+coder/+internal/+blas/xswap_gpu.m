function [x,y] = xswap_gpu(n,x,ix0,incx,y,iy0,incy)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(n,ix0,incx,iy0,incy);

% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isreal(x)
    if isa(x,'single')
        fun = 'gpublassswap';
        ftype = 'float';
    else
        fun = 'gpublasdswap';
        ftype = 'double';
    end
else
    if isa(x,'single')
        fun = 'gpublascswap';
        ftype = 'cuComplex';
    else
        fun = 'gpublaszswap';
        ftype = 'cuDoubleComplex';
    end
end

% Call the BLAS function.
if coder.internal.blas.isNullEmpty(y)
    xflag = logical(0);
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        coder.ceval(fun, n, cref(x(ix0), 'like', flt_type), incx, ...
                    cref(x(iy0), 'like', flt_type), incy);
    else
        [x,y] = coder.internal.refblas.xswap( ...
            cast(n,coder.internal.indexIntClass), ...
            x, ix0, cast(incx,coder.internal.indexIntClass), ...
            y, iy0, cast(incy,coder.internal.indexIntClass));
    end
else
    xflag = logical(0);
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        coder.ceval(fun, n, cref(x(ix0), 'like', flt_type), incx, ...
                    cref(y(iy0), 'like', flt_type), incy);
    else
        [x,y] = coder.internal.refblas.xswap( ...
            cast(n,coder.internal.indexIntClass), ...
            x, ix0, cast(incx,coder.internal.indexIntClass), ...
            y, iy0, cast(incy,coder.internal.indexIntClass));
    end
end

end

%--------------------------------------------------------------------------
