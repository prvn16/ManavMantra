function A = xorgqr_gpu(m,n,k,A,ia0,lda,tau,itau0)
%MATLAB GPU Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');

header_name = coder.internal.lapack.LAPACKApi.register();

if ~isempty(A)
    info_t = coder.internal.lapack.info_t();

    if isa(A,'double')
        fname = 'gpusolverdorgqr';
        ftype = 'double';
    else
        fname = 'gpusolversorgqr';
        ftype = 'float';
    end

    xflag = logical(0);
    xflag = coder.ceval('-global','gpulapackcheck');
    if (xflag)
        % Call the LAPACK function
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fname, m, n, k, coder.ref(A(ia0),'like', flt_type), ...
                    lda, coder.rref(tau(itau0)), coder.wref(info_t));

    info = cast(info_t,'like',coder.internal.lapack.info_t);
    % Since we don't return info, report any errors here
    NANARGS = [cast(-7,'like',info), cast(-5,'like',info)];
    if coder.internal.lapack.infocheck(info,fname,NANARGS,'nonzero')
        A(:) = coder.internal.nan;
    end

    else
        % Fall back to MATLAB implementation
        A = coder.internal.reflapack.xzungqr(m,n,k,A,ia0,lda,tau,itau0);
    end
end

end
