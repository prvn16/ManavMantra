function [A,ipiv,info] = xgetrf_gpu(m,n,A,iA0,lda)
%MATLAB GPU Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');

header_name = coder.internal.lapack.LAPACKApi.register();

if isempty(A)
    ipiv = zeros(1,0,'like',coder.internal.indexInt(1));
    info = zeros('like',coder.internal.lapack.info_t);
else
    % This must be a column to keep LLVM happy
    ipiv_t = coder.nullcopy(repmat(coder.internal.indexInt(1),max(min(m,n),1),1));
    info_t = coder.internal.lapack.info_t;  %int();
    
    % Call LAPACKE_xgetrf_work to bypass NaN check
    if isa(A,'double')
        if isreal(A)
            fname = 'gpusolverdgetrf';
            ftype = 'double';
        else
            fname = 'gpusolverzgetrf';
            ftype = 'cuDoubleComplex';
        end
    else
        if isreal(A)
            fname = 'gpusolversgetrf';
            ftype = 'float';
        else
            fname = 'gpusolvercgetrf';
            ftype = 'cuComplex';
        end
    end

    xflag = logical(0);
    xflag = coder.ceval('-global','gpulapackcheck');
    if (xflag)
        % Call the LAPACK function
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fname, m, n, coder.ref(A(iA0), 'like', flt_type), ...
                    lda, coder.wref(ipiv_t(1)), coder.wref(info_t));

        info = cast(info_t, 'like', coder.internal.lapack.info_t);
        NANARG = [];
        ipiv = coder.nullcopy(zeros(1,numel(ipiv_t),coder.internal.indexIntClass));
        NPIV = coder.internal.indexInt(numel(ipiv));
        if coder.internal.lapack.infocheck(info,fname,NANARG,'negative')
            A(:) = coder.internal.nan;
            for k = 0:NPIV-1
                ipiv(k+1) = cast(k+1,'like',ipiv);
            end
        else
            for k = 0:NPIV-1
                ipiv(k+1) = cast(ipiv_t(k+1),'like',ipiv);
            end
        end
    else
        % Fall back to MATLAB implementation
        [A,ipiv,info] = coder.internal.reflapack.xzgetrf(m,n,A,iA0,lda);
    end
    
end

end

