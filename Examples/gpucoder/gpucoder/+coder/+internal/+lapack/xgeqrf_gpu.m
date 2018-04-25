function [A,tau] = xgeqrf_gpu(A)
%MATLAB Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');

m = coder.internal.indexInt(size(A,1));
n = coder.internal.indexInt(size(A,2));
info_t = coder.internal.lapack.info_t;
header_name = coder.internal.lapack.LAPACKApi.register();
if isempty(A)
    tau = zeros(0,1,'like',A);
else
    tau = coder.nullcopy(zeros(min(m,n),1,'like',A));
    if isa(A,'double')
        if isreal(A)
            fname = 'gpusolverdgeqrf';
            ftype = 'double';
        else
            fname = 'gpusolverzgeqrf';
            ftype = 'cuDoubleComplex';
        end
    else
        if isreal(A)
            fname = 'gpusolversgeqrf';
            ftype = 'float';
        else
            fname = 'gpusolvercgeqrf';
            ftype = 'cuComplex';
        end
    end

    xflag = logical(0);
    xflag = coder.ceval('-global','gpulapackcheck');
    if (xflag)
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fname, m, n, coder.ref(A(1), 'like', flt_type), ...
                    m, coder.wref(tau(1), 'like', flt_type), ...
                    coder.wref(info_t));
    
        info = cast(info_t,'like',coder.internal.lapack.info_t);

        % Since we don't return info, report any errors here
        NANARG = cast(-4,'like',info);
        if coder.internal.lapack.infocheck(info,fname,NANARG,'nonzero')
            A(:) = coder.internal.nan;
            tau(:) = coder.internal.nan;
        end

    else
        % Fall back to MATLAB implementation
        [A,tau] = coder.internal.reflapack.xzgeqp3(A);
    end

end

end
