function [L, exitflag] = logm(A)
%LOGM  Matrix logarithm.
%   L = LOGM(A) is the principal matrix logarithm A, the inverse of expm(A).
%
%   L is the unique logarithm with which every eigenvalue has imaginary
%   part lying strictly between -pi and pi. If A is singular or has any
%   real eigenvalues on the negative axis then the principal logarithm is
%   undefined, a non-principal logarithm is computed, and a warning message
%   is displayed.
%
%   [L,EXITFLAG] = LOGM(A) returns a scalar EXITFLAG that describes
%   the exit condition of LOGM:
%   EXITFLAG = 0: successful completion of algorithm.
%   EXITFLAG = 1: too many matrix square roots needed.
%                 Computed L may still be accurate, however.
%
%   Class support for input A:
%      float: double, single
%
%   See also EXPM, SQRTM, FUNM.

%   References:
%   A. H. Al-Mohy and Nicholas J. Higham, Improved inverse scaling and
%      squaring algorithms for the matrix logarithm, SIAM J. Sci. Comput.,
%      34(4), (2012), pp. C153-C169.
%   A. H. Al-Mohy, Nicholas J. Higham and Samuel D. Relton, Computing the
%      Frechet derivative of the matrix logarithm and estimating the
%      condition number, SIAM J. Sci. Comput., 35(4), (2013), C394-C410.
%
%   Nicholas J. Higham and Samuel D. Relton
%   Copyright 1984-2015 The MathWorks, Inc.

validateattributes(A, {'double', 'single'}, {'finite', 'square'});
maxroots = 100;
exitflag = 0;

% Check for triangularity.
schurInput = matlab.internal.math.isschur(A);
if schurInput
    T = A;
else
    [Q, T] = schur(A);
end
stayReal = isreal(A);

% Compute the logarithm.
if isdiag(T)      % Check if T is diagonal.
    d = diag(T);
    if any(real(d) <= 0 & imag(d) == 0)
        warning(message('MATLAB:logm:nonPosRealEig'))
    end
    if schurInput
        L = diag(log(d));
    else
        logd = log(d);
        L = (Q.*logd.')*Q';
        if isreal(logd)
            L = (L+L')/2;
        end
    end
else
    n = size(T,1);
    % Check for negative real eigenvalues.
    ei = ordeig(T);
    warns = any(ei == 0);
    if any(real(ei) < 0 & imag(ei) == 0 )
        warns = true;
        if stayReal
            if schurInput
                % Output will be complex - change to complex Schur form.
                Q = eye(n, class(T));
                schurInput = false; % Need to undo rsf2csf at end.
            end
            [Q, T] = rsf2csf(Q, T);
        end
    end
    if warns
        warning(message('MATLAB:logm:nonPosRealEig'));
        s = struct('identifier', {'MATLAB:illConditionedMatrix',...
                   'MATLAB:nearlySingularMatrix'}, 'state', 'off');
        warn = warning(s);
        w = onCleanup(@()warning(warn));
    end
    
    % Get block structure of Schur factor.
    blockformat = qtri_struct(T);

    % Get parameters.
    [s, m, Troot, exitflag] = logm_params(T, maxroots);
    
    % Compute Troot - I = T(1/2^s) - I more accurately.
    Troot = recompute_diag_blocks_sqrt(Troot, T, blockformat, s);
            
    % Compute Pade approximant.
    L = pade_approx(Troot, m);

    % Scale back up.
    L = 2^s * L;

    % Recompute diagonal blocks.
    L = recompute_diag_blocks_log(L, T, blockformat);

    if ~schurInput
        L = Q*L*Q';  
    end
end
end

% Subfunctions
function [s, m, Troot, exitflag] = logm_params(T, maxroots)
exitflag = 0;
n = size(T,1);
I = eye(n,class(T));

xvals = [1.586970738772063e-005
         2.313807884242979e-003
         1.938179313533253e-002
         6.209171588994762e-002
         1.276404810806775e-001
         2.060962623452836e-001
         2.879093714241194e-001];
     
mmax = 7; 
foundm = false;

% Get initial s0 so that T^(1/2^s0) < xvals(mmax).
s = 0;
d = ordeig(T);
while norm(d-1, 'inf') > xvals(mmax) && s < maxroots
    d = sqrt(d);
    s = s + 1;
end
s0 = s;
if s == maxroots
    warning(message('MATLAB:logm:TooManyMatrixSquareRoots'))
    exitflag = 1;
end

Troot = T;
for k = 1:min(s, maxroots)
    Troot = sqrtm_tri(Troot);
end

% Compute value of s and m needed.
TrootmI = Troot - I;
d2 = normAm(TrootmI, 2)^(1/2);
d3 = normAm(TrootmI, 3)^(1/3);
a2 = max(d2, d3);
if a2 <= xvals(2)
    m = find(a2 <= xvals(1:2), 1); 
    foundm = true;
end
p = 0;
while ~foundm
    more = false; % More norm checks needed.
    if s > s0
        d3 = normAm(TrootmI, 3)^(1/3);
    end
    d4 = normAm(TrootmI, 4)^(1/4);
    a3 = max(d3, d4);
    if a3 <= xvals(mmax)
        j = find(a3 <= xvals(3:mmax), 1) + 2;
        if j <= 6
            m = j;
            break
        else
            if a3/2 <= xvals(5) && p < 2
                more = true;
                p = p + 1;
            end
        end
    end
    if ~more
        d5 = normAm(TrootmI, 5)^(1/5);
        a4 = max(d4, d5);
        eta = min(a3, a4);
        if eta <= xvals(mmax)
            m = find(eta <= xvals(6:mmax), 1) + 5;
            break
        end
    end
    if s == maxroots
        if exitflag == 0
            warning(message('MATLAB:logm:TooManyMatrixSquareRoots'))
        end
        exitflag = 1;
        m = mmax; % No good value found so take largest.
        break;
    end
    Troot = sqrtm_tri(Troot);
    TrootmI = Troot - I;
    s = s + 1;
end
end

function u = unwinding(z)
%unwinding Unwinding number of z.
   u = ceil( (imag(z) - pi)/(2*pi) );
end

function L = recompute_diag_blocks_log(L, T, blockStruct)
% Recomputes diagonal blocks of L = log(T) accurately.
n = length(T);
last_block = 0;
for j = 1:n-1
    switch blockStruct(j)
        case 0 % Not start of a block.
            if last_block ~= 0
                last_block = 0;
                continue;
            else
                last_block = 0;
                L(j,j) = log(T(j,j));
            end
        case 1 % Start of upper-tri block.
            last_block = 1;
            a1 = T(j,j);
            a2 = T(j+1,j+1);
            loga1 = log(a1);
            loga2 = log(a2);
            L(j,j) = loga1;
            L(j+1,j+1) = loga2;
            if (a1 < 0 && imag(a1)==0) || (a2 < 0 && imag(a1)==0)
                % Problems with 2 x 2 formula for (1,2) block
                % since atanh is nonstandard, just redo diagonal part.
                continue;
            end
            if a1 == a2
                a12 = T(j,j+1)/a1;
            elseif abs(a1) < 0.5*abs(a2) || abs(a2) < 0.5*abs(a1)
                a12 =  T(j,j+1) * (loga2 - loga1) / (a2 - a1);
            else % Close eigenvalues.
                z = (a2-a1)/(a2+a1);
                dd = (2*atanh(z) + 2*pi*1i*(unwinding(loga2-loga1))) / (a2-a1);
                a12 = T(j,j+1)*dd;
            end
            L(j,j+1) = a12;
        case 2 % Start of quasi-tri block.
            last_block = 2;
            f = 0.5 * log(T(j,j)^2 - T(j,j+1)*T(j+1,j));
            t = atan2(sqrt(-T(j,j+1)*T(j+1,j)), T(j,j))/sqrt(-T(j,j+1)*T(j+1,j));
            L(j,j) = f;
            L(j+1,j) = t*T(j+1,j);
            L(j,j+1) = t*T(j,j+1);
            L(j+1,j+1) = f;
    end
end
end

function val = sqrt_obo(a, s)
% sqrt_obo Computes a^(1/2^s) - 1 accurately.
if s == 0
    val = a-1;
    return
end
% If s ~= 0 perform computation avoiding subtractive cancellation.
n0 = s;
if angle(a) >= pi/2
    a = sqrt(a); n0 = s-1;
end
z0 = a - 1;
a = sqrt(a);
r = 1 + a;
for i=1:n0-1
    a = sqrt(a);
    r = r*(1+a);
end
val = z0/r;
end

function Troot = recompute_diag_blocks_sqrt(Troot, T, blockStruct, s)
% Recomputes diagonal blocks of T = X^(1/2^s) - 1 more accurately.
n = length(T);
last_block = 0;
for j = 1:n-1
    switch blockStruct(j)
        case 0 % Not start of a block.
            if last_block ~= 0
                last_block = 0;
                continue
            else % In a 1x1 block.
                last_block = 0;
                a = T(j,j);
                Troot(j,j) = sqrt_obo(a, s);
            end
        otherwise
            % In a 2x2 block.
            last_block = blockStruct(j);
            I = eye(2, class(T));
            if s == 0 
                Troot(j:j+1,j:j+1) = T(j:j+1,j:j+1) - I; 
                continue 
            end
            A = sqrtm_tbt(T(j:j+1,j:j+1));

            Z0 = A - I;
            if s == 1
                Troot(j:j+1,j:j+1) = Z0;
                continue
            end
            A = sqrtm_tbt(A);
            P = A + I;
            for i = 1:s - 2
                A = sqrtm_tbt(A);
                P = P*(I + A);
            end
            Troot(j:j+1,j:j+1) = Z0 / P;
            % If block is upper triangular recompute the (1,2) element.
            % Skip when T(j,j) or T(j+1,j+1) < 0 since the implementation
            % of atanh is nonstandard.
            if T(j+1,j) == 0 && T(j,j) >= 0 && T(j+1,j+1) >= 0
                Troot(j,j+1) = powerm2by2(T(j:j+1,j:j+1), 1/(2^s)); 
            end
    end
end
% If last diagonal entry is not in a block it will have been missed.
if blockStruct(end) == 0
    a = T(n,n);
    Troot(n,n) = sqrt_obo(a, s);
end
end

function x12 = powerm2by2(A,p)
%powerm2by2 Power of 2-by-2 upper triangular matrix.
%   powerm2by2(A,p) is the (1,2) element of the pth power of the 2 x 2 
%   upper triangular matrix A, where p is an arbitrary real number.

a1 = A(1,1);
a2 = A(2,2);

if a1 == a2
   x12 = p*A(1,2)*a1^(p-1);
elseif abs(a1) < 0.5*abs(a2) || abs(a2) < 0.5*abs(a1)
   a1p = a1^p;
   a2p = a2^p;
   x12 =  A(1,2) * (a2p - a1p) / (a2 - a1);
else % Close eigenvalues.
   loga1 = log(a1);
   loga2 = log(a2);
   w = atanh((a2-a1)/(a2+a1)) + 1i*pi*unwinding(loga2-loga1);
   dd = 2 * exp(p*(loga1+loga2)/2) * sinh(p*w) / (a2-a1);
   x12 = A(1,2) * dd;
end
end

function [x, w] = gauss_legendre(n)
%gauss_legendre Nodes and weights for Gauss-Legendre quadrature.
%   [x,w] = gauss_legendre(n) computes the nodes x and weights w
%   for n-point Gauss-Legendre quadrature.

% Reference:
% G. H. Golub and J. H. Welsch, Calculation of Gauss quadrature
%    rules, Math. Comp., 23(106):221-230, 1969.
k = 1:n-1;
v = k./sqrt((2*k).^2-1);
[V, x] = eig(diag(v,-1)+diag(v,1),'vector');
w = 2*(V(1,:)'.^2);
end

function L = pade_approx(T, m)
%pade_approx Pade approximation to log(1 + T) via partial fractions.
    [nodes, wts] = gauss_legendre(m);
    % Convert from [-1,1] to [0,1].
    nodes = (nodes + 1)/2;
    wts = wts/2;
    n = size(T,1);
    L = zeros(n,class(T));
    for j=1:m
        K = nodes(j).*T;
        K(1:n+1:end) = K(1:n+1:end) + 1;
        L = L + wts(j) .* (K \ T);
    end
end

