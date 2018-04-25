function d = xdot_gpu(n,x,ix0,incx,y,iy0,incy)
%MATLAB GPU Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');

coder.internal.prefer_const(ix0,iy0);
% Select BLAS function.
header_name = coder.internal.blas.getGpuBlasHeader();
if isa(x,'single')
    fun = 'gpublassdot';
    ftype = 'float';
else
    fun = 'gpublasddot';
    ftype = 'double';
end

% Declare the output type.
d = coder.internal.scalarEg(x);

xflag = logical(0);
xflag = coder.ceval('-global','gpublascheck');
if (xflag)
    % Call the BLAS function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fun, n, cref(x(ix0) ,'r', 'like', flt_type), ...
                incx, cref(y(iy0), 'r', 'like', flt_type), ...
                incy, cref(d, 'w', 'like', flt_type));
else
    d = coder.internal.refblas.xdot( ...
        cast(n,coder.internal.indexIntClass), ...
        x, ix0, cast(incx,coder.internal.indexIntClass), ...
        y, iy0, cast(incy,coder.internal.indexIntClass));
end

end

%--------------------------------------------------------------------------
