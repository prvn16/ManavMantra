function [x,y] = xrot_gpu(n,x,ix0,incx,y,iy0,incy,c,s)
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
        fun = 'gpublassrot';
        ftype = 'float';
    else
        fun = 'gpublasdrot';
        ftype = 'double';
    end
else
    if isa(x,'single')
        fun = 'gpublascsrot';
        ftype = 'cuComplex';
    else
        fun = 'gpublaszdrot';
        ftype = 'cuDoubleComplex';
    end
end

if isa(x,'single')
    otype = 'float';
else
    otype = 'double';
end

% Call the BLAS function.
if coder.internal.blas.isNullEmpty(y)
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        out_type = coder.opaque(otype, 'HeaderFile', header_name);
        coder.ceval(fun, n, ...
                    cref(x(ix0), 'like', flt_type), incx, ...
                    cref(x(iy0), 'like', flt_type), incy, ...
                    cref(c, 'like', out_type), cref(s, 'like', out_type));
    else
        [x,y] = coder.internal.refblas.xrot(...
            cast(n,coder.internal.indexIntClass), ...
            x, ix0, cast(incx,coder.internal.indexIntClass), ...
            y, iy0, cast(incy,coder.internal.indexIntClass), ...
            cast(c,'like',real(x)), s+coder.internal.scalarEg(x));
    end
else
    xflag = logical(0);
    xflag = coder.ceval('-global','gpublascheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        out_type = coder.opaque(otype, 'HeaderFile', header_name);
        coder.ceval(fun, n, ...
                    cref(x(ix0), 'like', flt_type), incx, ...
                    cref(y(iy0), 'like', flt_type), incy, ...
                    cref(c, 'like', out_type), cref(s, 'like', out_type));
    else
        [x,y] = coder.internal.refblas.xrot(...
            cast(n,coder.internal.indexIntClass), ...
            x, ix0, cast(incx,coder.internal.indexIntClass), ...
            y, iy0, cast(incy,coder.internal.indexIntClass), ...
            cast(c,'like',real(x)), s+coder.internal.scalarEg(x));
    end
end

end

%--------------------------------------------------------------------------
