function y = xnrm2_gpu(n,x,ix0,incx)
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
        fun = 'gpublassnrm2';
        ftype = 'float';
    else
        fun = 'gpublasdnrm2';
        ftype = 'double';
    end
else
    if isa(x,'single')
        fun = 'gpublasscnrm2';
        ftype = 'cuComplex';
    else
        fun = 'gpublasdznrm2';
        ftype = 'cuDoubleComplex';
    end
end

if isa(x,'single')
    otype = 'float';
else
    otype = 'double';
end

y = coder.nullcopy(zeros(class(x)));

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    out_type = coder.opaque(otype, 'HeaderFile', header_name);
    y = coder.nullcopy(zeros(class(x)));
    coder.ceval(fun, n, cref(x(ix0), 'r', 'like', flt_type), ...
                incx, cref(y, 'w', 'like', out_type));
else
    y = coder.internal.refblas.xnrm2( ...
        cast(n,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass));
end

end
    
%--------------------------------------------------------------------------
