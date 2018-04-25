function [A,info] = xpotrf_gpu(uplo,n,A,ia0,lda)
%MATLAB GPU Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');

info_t = coder.internal.lapack.info_t();
header_name = coder.internal.lapack.LAPACKApi.register();
complexDiag = false;
badIndex = zeros('like',n);
if ~isreal(A)
    % Check for non-zero imaginary part on diagonal since LAPACK doesn't
    for k = 1:n
        if imag(A(k,k)) ~= 0
            complexDiag = true;
            badIndex = k;
            break
        end
    end
end

% Use LAPACKE_xpotrf_work to bypass NaN checks for nargout == 2 case of chol
if isa(A,'double')
    if isreal(A)
        fname = 'gpusolverdpotrf';
        ftype = 'double';
    else
        fname = 'gpusolverzpotrf';
        ftype = 'cuDoubleComplex';
    end
else
    if isreal(A)
        fname = 'gpusolverspotrf';
        ftype = 'float';
    else
        fname = 'gpusolvercpotrf';
        ftype = 'cuComplex';
    end
end

xflag = logical(0);
xflag = coder.ceval('-global','gpulapackcheck');
if (xflag)
    % Call the LAPACK function.
    flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
    coder.ceval(fname, uplo, n, coder.ref(A(ia0),'like',flt_type), ...
                lda, coder.wref(info_t));

    info = cast(info_t,'like',coder.internal.lapack.info_t);
    if coder.internal.lapack.infocheck(info,fname,[],'negative')
        A(:) = coder.internal.nan;
    else
        if complexDiag && (info == 0 || badIndex < info)
            info = cast(badIndex,'like',info);
        end
    end
else
    % Fall back to MATLAB implementation
    [A,info] = coder.internal.reflapack.xzpotrf(uplo,n,A,ia0,lda);
end

end
