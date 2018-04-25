function C = xunormqr_gpu(Q,C,tau)
%MATLAB GPU Code Generation Private Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen 
coder.allowpcode('plain');
coder.inline('always');

m = coder.internal.indexInt(size(Q,1));
n = coder.internal.indexInt(size(Q,2));
if m < n
    mn = m;
else
    mn = n;
end

header_name = coder.internal.lapack.LAPACKApi.register();

if ~isempty(Q) && ~isempty(C)
    if isa(Q,'double')
        if isreal(Q)
            fname = 'gpusolverdormqr';
            ftype = 'double';
        else
            fname = 'gpusolverzunmqr';
            ftype = 'cuDoubleComplex';
        end
    else
        if isreal(Q)
            fname = 'gpusolversormqr';
            ftype = 'float';
        else
            fname = 'gpusolvercunmqr';
            ftype = 'cuComplex';
        end
    end

    info_t = zeros([1 1], 'like', coder.internal.lapack.info_t);
    xflag = logical(0);
    xflag = coder.ceval('-global','gpulapackcheck');
    if (xflag)
        side = 'L';
        if isreal(Q)
            trans = 'T';
        else
            trans = 'C';
        end
        
        flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
        coder.ceval(fname, side, trans, ...
                    coder.internal.indexInt(size(C,1)), ...
                    coder.internal.indexInt(size(C,2)), mn, ...
                    coder.rref(Q(1), 'like', flt_type), ...
                    m, coder.rref(tau(1), 'like', flt_type), ...
                    coder.ref(C(1), 'like', flt_type), ...
                    coder.internal.indexInt(size(C,1)), coder.ref(info_t));
        
        info = cast(info_t,'like',coder.internal.lapack.info_t);
        NANARG = [];
        
        if coder.internal.lapack.infocheck(info,fname,NANARG,'nonzero')
            C(:) = coder.internal.nan;
        end
    else
        % Fall back to MATLAB implementation
        C = coder.internal.reflapack.xzunormqr(Q,C,tau);
    end
end

end
