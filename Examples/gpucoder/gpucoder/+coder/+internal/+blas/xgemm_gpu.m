function C = xgemm_gpu(TRANSA,TRANSB,m,n,k,alpha1,A,ia0,lda,B,ib0,ldb,beta1,C,ic0,ldc)
%MATLAB GPU Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(ia0,ib0,ic0);

header_name = coder.internal.blas.getGpuBlasHeader();
if isreal(C)
    if isa(C, 'single')
        fun = 'gpublassgemm';
        ftype = 'float';
    else
        fun = 'gpublasdgemm';
        ftype = 'double';
    end
else
    if isa(C, 'single')
        fun = 'gpublascgemm';
        ftype = 'cuComplex';
    else
        fun = 'gpublaszgemm';
        ftype = 'cuDoubleComplex';
    end
end

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun,TRANSA,TRANSB,m,n,k, ...
                cref(alpha1, 'like', flt_type),cref(A(ia0), 'r', 'like', flt_type), lda, ...
                cref(B(ib0), 'r', 'like', flt_type), ldb, ...
                cref(beta1, 'like', flt_type),cref(C(ic0), 'w', 'like', flt_type), ldc);
else
    C = coder.internal.refblas.xgemm( ...
        TRANSA, TRANSB, ...
        cast(m,coder.internal.indexIntClass), ...
        cast(n,coder.internal.indexIntClass), ...
        cast(k,coder.internal.indexIntClass), ...
        alpha1+coder.internal.scalarEg(C), ...
        A, ia0, cast(lda,coder.internal.indexIntClass), ...
        B, ib0, cast(ldb,coder.internal.indexIntClass), ...
        beta1+coder.internal.scalarEg(C), ...
        C, ic0, cast(ldc,coder.internal.indexIntClass));
end

end

%--------------------------------------------------------------------------
