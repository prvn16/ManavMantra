function [U,S,V,info] = xgesvd_gpu(A,jobU,jobV)
%MATLAB GPU Code Generation Library Function

%   Copyright 2017 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.inline('always');
coder.internal.prefer_const(jobU,jobV);

aZERO = coder.internal.scalarEg(A);
ONE = ones(coder.internal.indexIntClass());
m = coder.internal.indexInt(size(A,1));
n = coder.internal.indexInt(size(A,2));

header_name = coder.internal.lapack.LAPACKApi.register();

nru = m;
ncv = n;
minnm = min(n,m);
if jobU == 'A'
    ncu = m;
else
    ncu = minnm;
end
if jobV == 'A'
    nrv = n;
else
    nrv = minnm;
end

U = coder.nullcopy(eml_expand(aZERO,nru,ncu));
if jobU ~= 'N'
    ldu = nru;
else
    ldu = ONE;
end

Vt = coder.nullcopy(eml_expand(aZERO,nrv,ncv));
if jobV ~= 'N'
    ldv = nrv;
else
    ldv = ONE;
end

ns = minnm;
S = coder.nullcopy(zeros(ns,1,'like',real(A)));

% Choose the function to call
if isa(A, 'single')
    if isreal(A)
        fname = 'gpusolversgesvd';
        ftype = 'float';
    else
        fname = 'gpusolvercgesvd';
        ftype = 'cuComplex';
    end
else
    if isreal(A)
        fname = 'gpusolverdgesvd';
        ftype = 'double';
    else
        fname = 'gpusolverzgesvd';
        ftype = 'cuDoubleComplex';
    end
end

if ~isempty(A)
    info_t = zeros('like', coder.internal.lapack.info_t);
    info = zeros('like', coder.internal.lapack.info_t);
    
    if minnm > ONE
        superb = coder.nullcopy(zeros(minnm-ONE,ONE,'like',real(A)));
    else
        superb = coder.nullcopy(zeros(ONE,'like',real(A)));
    end
    
    % Evaluate the SVD
    xflag = logical(0);
    if coder.internal.isConst(isempty(U)) && isempty(U)
        if coder.internal.isConst(isempty(Vt)) && isempty(Vt)
            xflag = coder.ceval('-global','gpulapackcheck');
            if (xflag)
                % Call the LAPACK function
                flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
                coder.ceval(fname, jobU, jobV, m, n, ...
                            coder.ref(A(1), 'like', flt_type), m, ...
                            coder.wref(S(1)), coder.wref(U, 'like', flt_type), ...
                            ldu, coder.wref(Vt, 'like', flt_type), ldv, ...
                            coder.wref(superb(1)), coder.wref(info_t));

                info = cast(info_t, 'like', coder.internal.lapack.info_t);
            else
                % Fall back to MATLAB implementation
                [U,S,V] = coder.internal.reflapack.xzsvdc(A,jobU,jobV);
                return;
            end

        else

            xflag = coder.ceval('-global','gpulapackcheck');
            if (xflag)
                % Call the LAPACK function
                flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
                coder.ceval(fname, jobU, jobV, m, n, ...
                            coder.ref(A(1), 'like', flt_type), m, ...
                            coder.wref(S(1)), coder.wref(U, 'like', flt_type), ...
                            ldu, coder.ref(Vt(1), 'like', flt_type), ldv, ...
                            coder.wref(superb(1)), coder.wref(info_t));

                info = cast(info_t, 'like', coder.internal.lapack.info_t);
            else
                % Fall back to MATLAB implementation
                [U,S,V] = coder.internal.reflapack.xzsvdc(A,jobU,jobV);
                return;
            end

        end
        
    elseif coder.internal.isConst(isempty(Vt)) && isempty(Vt)
        
        xflag = coder.ceval('-global','gpulapackcheck');
        if (xflag)
            % Call the LAPACK function
            flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
            coder.ceval(fname, jobU, jobV, m, n, ...
                        coder.ref(A(1), 'like', flt_type), m, ...
                        coder.wref(S(1)), coder.wref(U(1), 'like', flt_type), ...
                        ldu, coder.ref(Vt, 'like', flt_type), ldv, ...
                        coder.wref(superb(1)), coder.wref(info_t));
            
            info = cast(info_t, 'like', coder.internal.lapack.info_t);
        else
            % Fall back to MATLAB implementation
            [U,S,V] = coder.internal.reflapack.xzsvdc(A,jobU,jobV);
            return;
        end

    else
        
        xflag = coder.ceval('-global','gpulapackcheck');
        if (xflag)
            % Call the LAPACK function
            flt_type = coder.opaque(ftype, 'HeaderFile', header_name);
            coder.ceval(fname, jobU, jobV, m, n, ...
                        coder.ref(A(1), 'like', flt_type), m, ...
                        coder.wref(S(1)), coder.wref(U(1), 'like', flt_type), ...
                        ldu, coder.ref(Vt(1), 'like', flt_type), ldv, ...
                        coder.wref(superb(1)), coder.wref(info_t));
            
            info = cast(info_t, 'like', coder.internal.lapack.info_t);
        else
            % Fall back to MATLAB implementation
            [U,S,V] = coder.internal.reflapack.xzsvdc(A,jobU,jobV);
            return;
        end
        
    end

else
    info = zeros('like', coder.internal.lapack.info_t);
end

[~,V] = getv(jobV,Vt,m,n);

if coder.internal.lapack.infocheck(info,fname,[],'negative')
    U(:) = coder.internal.nan;
    S(:) = coder.internal.nan;
    V(:) = coder.internal.nan;
end

%--------------------------------------------------------------------------

function [Vt, V] = getv(jobV,Vt,m,n)
coder.inline('always');
coder.internal.prefer_const(jobV,m,n);
minmn = min(m,n);
aZERO = coder.internal.scalarEg(Vt);
if jobV == 'S'
    V = coder.nullcopy(eml_expand(aZERO,[n,minmn]));
    for j = 1:minmn
        for i = 1:n
            V(i,j) = conj(Vt(j,i));
        end
    end
elseif jobV == 'A'
    V = Vt';
else
    V = eml_expand(aZERO,[0,0]);
end
