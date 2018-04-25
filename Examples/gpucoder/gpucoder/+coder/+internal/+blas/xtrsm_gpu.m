function B = xtrsm_gpu(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,A,ia0,lda,B,ib0,ldb)
%MATLAB GPU Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(ia0,ib0);

header_name = coder.internal.blas.getGpuBlasHeader();

if isreal(B)
    if isa(B,'single')
        fun = 'gpublasstrsm';
        ftype = 'float';
    else
        fun = 'gpublasdtrsm';
        ftype = 'double';
    end
else
    if isa(B,'single')
        fun = 'gpublasctrsm';
        ftype = 'cuComplex';
    else
        fun = 'gpublasztrsm';
        ftype = 'cuDoubleComplex';
    end
end

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun, SIDE, UPLO, TRANSA, DIAGA, m, n, cref(alpha1, 'like', flt_type), ...
                cref(A(ia0), 'r', 'like', flt_type), lda, cref(B(ib0), 'like', flt_type), ldb);
else
    B = coder.internal.refblas.xtrsm( ...
        SIDE, UPLO, TRANSA, DIAGA, ...
        cast(m,coder.internal.indexIntClass), cast(n,coder.internal.indexIntClass), ...
        alpha1+coder.internal.scalarEg(B), ...
        A, ia0, cast(lda,coder.internal.indexIntClass), ...
        B, ib0, cast(ldb,coder.internal.indexIntClass));
end

end

%--------------------------------------------------------------------------
