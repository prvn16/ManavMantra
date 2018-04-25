function y = xasum_gpu(n,x,ix0,incx)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(n,ix0,incx);

header_name = coder.internal.blas.getGpuBlasHeader();
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'gpublassasum';
        ftype = 'float';
    else
        fun = 'gpublasdasum';
        ftype = 'double';
    end
else
    if isa(x,'single')
        fun = 'gpublasscasum';
        ftype = 'cuComplex';
    else
        fun = 'gpublasdzasum';
        ftype = 'cuDoubleComplex';
    end
end

if isa(x,'single')
    otype = 'float';
else
    otype = 'double';
end

% Declare the output type.
y = zeros(class(x));

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    out_type = coder.opaque(otype, 'HeaderFile', header_name);
    coder.ceval(fun, n, cref(x(ix0), 'r', 'like', flt_type), ...
                incx, cref(y, 'w', 'like', out_type));
else
    y = coder.internal.refblas.xasum( ...
        cast(n,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass));
end

end

%--------------------------------------------------------------------------
