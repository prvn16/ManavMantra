function x = xtrsv_gpu(UPLO,TRANSA,DIAGA,n,A,ia0,lda,x,ix0,incx)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(UPLO,TRANSA,DIAGA,n,ia0,lda,ix0,incx);

% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isreal(x)
    if isa(x,'single')
        fun = 'gpublasstrsv';
        ftype = 'float';
    else
        fun = 'gpublasdtrsv';
        ftype = 'double';
    end
else
    if isa(x,'single')
        fun = 'gpublasctrsv';
        ftype = 'cuComplex';
    else
        fun = 'gpublasztrsv';
        ftype = 'cuDoubleComplex';
    end
end

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun, UPLO, TRANSA, DIAGA, n, ...
                cref(A(ia0), 'r', 'like', flt_type), lda, ....
                cref(x(ix0), 'like', flt_type), incx);
else
    x = coder.internal.refblas.xtrsv( ...
        UPLO, TRANSA, DIAGA, ...
        cast(n,coder.internal.indexIntClass), ...
        A, ia0, cast(lda,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass));
end

end

%--------------------------------------------------------------------------
