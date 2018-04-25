function y = xgemv_gpu(TRANSA,m,n,alpha1,A,ia0,lda,x,ix0,incx,beta1,y,iy0,incy)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(TRANSA,alpha1,m,n,ia0,lda,ix0,incx,beta1,iy0,incy);

% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isreal(y)
    if isa(y,'single')
        fun = 'gpublassgemv';
        ftype = 'float';
    else
        fun = 'gpublasdgemv';
        ftype = 'double';
    end
else
    if isa(y,'single')
        fun = 'gpublascgemv';
        ftype = 'cuComplex';
    else
        fun = 'gpublaszgemv';
        ftype = 'cuDoubleComplex';
    end
end

% Call the BLAS function.
if coder.internal.blas.isNullEmpty(A) && ...
        coder.internal.blas.isNullEmpty(x)
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fun, TRANSA, m, n, cref(alpha1, 'like', flt_type), cref(y(ia0), 'r', 'like', flt_type), ...
                    lda, cref(y(ix0), 'r', 'like', flt_type), incx, cref(beta1, 'like', flt_type), ...
                    cref(y(iy0), 'like', flt_type), incy);
    else
        y = coder.internal.refblas.xgemv(TRANSA, cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
        alpha1+coder.internal.scalarEg(y), A, ia0, cast(lda,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass), ...
        beta1+coder.internal.scalarEg(y), ...
        y, iy0, cast(incy,coder.internal.indexIntClass));
    end
elseif coder.internal.blas.isNullEmpty(A)
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fun, TRANSA, m, n, cref(alpha1, 'like', flt_type), cref(y(ia0), 'r', 'like', flt_type), ...
                    lda, cref(x(ix0), 'r', 'like', flt_type), incx, cref(beta1, 'like', flt_type), ...
                    cref(y(iy0), 'like', flt_type), incy);
    else
        y = coder.internal.refblas.xgemv(TRANSA, cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
        alpha1+coder.internal.scalarEg(y), A, ia0, cast(lda,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass), ...
        beta1+coder.internal.scalarEg(y), ...
        y, iy0, cast(incy,coder.internal.indexIntClass));
    end
elseif coder.internal.blas.isNullEmpty(x)
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fun, TRANSA, m, n, cref(alpha1, 'like', flt_type), cref(A(ia0), 'r', 'like', flt_type), ...
                    lda, cref(y(ix0), 'r', 'like', flt_type), incx, cref(beta1, 'like', flt_type), ...
                    cref(y(iy0), 'like', flt_type), incy);
    else
        y = coder.internal.refblas.xgemv(TRANSA, cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
        alpha1+coder.internal.scalarEg(y), A, ia0, cast(lda,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass), ...
        beta1+coder.internal.scalarEg(y), ...
        y, iy0, cast(incy,coder.internal.indexIntClass));
    end
else
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fun, TRANSA, m, n, cref(alpha1, 'like', flt_type), cref(A(ia0), 'r', 'like', flt_type), ...
                    lda, cref(x(ix0), 'r', 'like', flt_type), incx, cref(beta1, 'like', flt_type), ...
                    cref(y(iy0), 'like', flt_type), incy);
    else
        y = coder.internal.refblas.xgemv(TRANSA, cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
        alpha1+coder.internal.scalarEg(y), A, ia0, cast(lda,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass), ...
        beta1+coder.internal.scalarEg(y), ...
        y, iy0, cast(incy,coder.internal.indexIntClass));
    end
end

%--------------------------------------------------------------------------
