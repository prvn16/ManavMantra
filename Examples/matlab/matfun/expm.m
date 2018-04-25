function F = expm(A)
%EXPM  Matrix exponential.
%   EXPM(A) is the matrix exponential of A and is computed using
%   a scaling and squaring algorithm with a Pade approximation.
%
%   Although it is not computed this way, if A has a full set
%   of eigenvectors V with corresponding eigenvalues D then
%   [V,D] = EIG(A) and EXPM(A) = V*diag(exp(diag(D)))/V.
%
%   EXP(A) computes the exponential of A element-by-element.
%
%   See also LOGM, SQRTM, FUNM.

%   References:
%   N. J. Higham, The scaling and squaring method for the matrix
%      exponential revisited. SIAM J. Matrix Anal. Appl., 26(4), (2005),
%      pp. 1179-1193.
%   A. H. Al-Mohy and N. J. Higham, A new scaling and squaring algorithm
%      for the matrix exponential, SIAM J. Matrix Anal. Appl., 31(3),
%      (2009), pp. 970-989.
%
%   Nicholas J. Higham and Samuel D. Relton
%   Copyright 1984-2015 The MathWorks, Inc.

validateattributes(A, {'double', 'single'}, {'square'});

schurFact = false;
recomputeDiags = false;

if ~all(isfinite(A(:)))
    F = NaN(size(A),class(A));
    return
end

T = A;
if matlab.internal.math.isschur(A)
    recomputeDiags = true;
    schurFact = false;
elseif schurFact || ishermitian(A)
    [Q, T] = schur(full(A));
    recomputeDiags = true;
    schurFact = true;
end
    
if isdiag(T) % Check if T is diagonal.
    d = diag(T);
    if ~schurFact
        F = diag(exp(full(d)));
    else
        expd = exp(d);
        F = (Q.*expd.')*Q';
        if isreal(expd)
            F = (F+F')/2;
        end
    end
    return;
end

% Get block structure for recomputation of diagonal blocks.
if recomputeDiags
    blockformat = qtri_struct(T);
end

% Compute exponential
% Get scaling and Pade parameters.
[s, m, Tpowers] = expm_params(T);

% Rescale the powers of T appropriately.
if s ~= 0
    T = T/(2.^s);
    Tpowers = cellfun(@rdivide, Tpowers, ...
        num2cell(2.^(s * (1:length(Tpowers)))), 'UniformOutput', false);
end

% Evaluate the Pade approximant.
F = pade_approx(T, Tpowers, m);
if recomputeDiags
    F = recompute_block_diag(T, F, blockformat);
end

% Squaring phase.
for k = 1:s
    F = F*F;
    if recomputeDiags
        T = 2*T;
        F = recompute_block_diag(T, F, blockformat);
    end
end
end

% Subfunctions
function F = pade_approx(T, Tpowers, m)
%pade_approx Computes the Pade approximant to exp(T) of order [m/m].
c = get_pade_coefficients(m);
n = length(T);
I = eye(n,class(T));
switch m
    case {3, 5, 7, 9}
        strt = length(Tpowers) + 2;
        for k = strt:2:m-1
            Tpowers{k} = Tpowers{k-2}*Tpowers{2};
        end
        U = c(2)*I;
        V = c(1)*I; 
        for j = m:-2:3
            U = U + c(j+1)*Tpowers{j-1};
            V = V + c(j)*Tpowers{j-1};
        end
        U = T*U;
    case 13
        U = T * (Tpowers{6}*(c(14)*Tpowers{6} + c(12)*Tpowers{4} + ...
            c(10)*Tpowers{2}) + c(8)*Tpowers{6} + c(6)*Tpowers{4} + ...
            c(4)*Tpowers{2} + c(2)*I);
        V = Tpowers{6}*(c(13)*Tpowers{6} + c(11)*Tpowers{4} + ...
            c(9)*Tpowers{2}) + c(7)*Tpowers{6} + c(5)*Tpowers{4} + ...
            c(3)*Tpowers{2} + c(1)*I;
end
warns = warning('off','MATLAB:nearlySingularMatrix');
try
   F = (V-U)\(2*U) + I;  %F = (-U+V)\(U+V);
   warning(warns); 
catch e
   warning(warns); 
   rethrow(e);
end
end

function c = get_pade_coefficients(m)
%get_pade_coefficients Coefficients of numerator P of Pade approximant
%    C = get_pade_coefficients returns coefficients of numerator
%    of [m/m] Pade approximant, where m = 3,5,7,9,13.
switch m
    case 3
        c = [120, 60, 12, 1];
    case 5
        c = [30240, 15120, 3360, 420, 30, 1];
    case 7
        c = [17297280, 8648640, 1995840, 277200, 25200, 1512, 56, 1];
    case 9
        c = [17643225600, 8821612800, 2075673600, 302702400, 30270240, ...
            2162160, 110880, 3960, 90, 1];
    case 13
        c = [64764752532480000, 32382376266240000, 7771770303897600, ...
            1187353796428800,  129060195264000,   10559470521600, ...
            670442572800,      33522128640,       1323241920,...
            40840800,          960960,            16380,  182,  1];
end
end
        

function F = recompute_block_diag(T, F, block_struct)
%recompute_block_diag Recomputes block diagonal of F = expm(T).
n = length(T);
for j = 1:n-1
    switch block_struct(j)
        case 0
            % Not the start of a block, move on.
            continue;
        case 1
            % Start of a 2x2 triangular block.
            t11 = T(j,j);
            t22 = T(j+1,j+1);

            ave = (t11+t22)/2; df  = abs(t11-t22)/2;

            if max(ave,df) < log(realmax)
                % Formula fine unless it overflows.
                x12 = T(j,j+1)*exp(ave)*sinch((t22-t11)/2);
            else
                % Revert to formula that can suffer cancellation.
                x12 = T(j,j+1)*(exp(t22)-exp(t11))/(t22-t11);
            end
            F(j,j) = exp(t11);
            F(j,j+1) = x12;
            F(j+1,j+1) = exp(t22);
            
        case 2
            % Start of a 2x2 quasi-triangular (full) block.
            a = T(j,j); b = T(j,j+1);
            c = T(j+1,j); d = T(j+1,j+1);
            delta = sqrt((a-d)^2 + 4*b*c)/2;
            expad2 = exp((a+d)/2);
            coshdelta = cosh(delta);
            sinchdelta = sinch(delta);
            F(j,j)     = expad2 .* (coshdelta + (a-d)./2.*sinchdelta);
            F(j+1,j)   = expad2 .* c .* sinchdelta;
            F(j,j+1)   = expad2 .* b .* sinchdelta; 
            F(j+1,j+1) = expad2 .* (coshdelta + (d-a)./2.*sinchdelta);           
    end
end
end

function y = sinch(x)
%sinch Returns sinh(x)/x.
if x == 0
    y = 1;
else
    y = sinh(x)/x;
end
end

function t = ell(T, coeff, m_val)
%ell Function needed to compute optimal parameters.
scaledT = coeff.^(1/(2*m_val+1)) .* abs(T);
alpha = normAm(scaledT,2*m_val+1)/norm(T,1);
t = max(ceil(log2(2*alpha/eps(class(alpha)))/(2*m_val)),0);
end

function [s, m, Tpowers] = expm_params(T)
%expm_params Obtain scaling parameter and order of the Pade approximant.
% Coefficients of backwards error function.
coeff = [1/100800, 1/10059033600, 1/4487938430976000,...
     1/5914384781877411840000, 1/113250775606021113483283660800000000];

s = 0;
% m_val is one of [3 5 7 9 13];
% theta_m for m=1:13.
theta = [%3.650024139523051e-008
    %5.317232856892575e-004
    1.495585217958292e-002  % m_vals = 3
    %8.536352760102745e-002
    2.539398330063230e-001  % m_vals = 5
    %5.414660951208968e-001
    9.504178996162932e-001  % m_vals = 7
    %1.473163964234804e+000
    2.097847961257068e+000  % m_vals = 9
    %2.811644121620263e+000
    %3.602330066265032e+000
    %4.458935413036850e+000
    5.371920351148152e+000];% m_vals = 13

Tpowers{2} = T*T;
Tpowers{4} = Tpowers{2}*Tpowers{2};
Tpowers{6} = Tpowers{2}*Tpowers{4};
d4 = norm(Tpowers{4},1)^(1/4);
d6 = norm(Tpowers{6},1)^(1/6);
eta1 = max(d4, d6);
if (eta1 <= theta(1) && ell(T, coeff(1), 3) == 0)
    m = 3;
    return;
end
if (eta1 <= theta(2) && ell(T, coeff(2), 5) == 0)
    m = 5;
    return;
end

isSmall = size(T,1) < 150; %Compute matrix power explicitly
if isSmall
    d8 = norm(Tpowers{4}*Tpowers{4},1)^(1/8);
else
    d8 = normAm(Tpowers{4}, 2)^(1/8);
end
eta3 = max(d6, d8);
if (eta3 <= theta(3) && ell(T, coeff(3), 7) == 0)
    m = 7;
    return;
end
if (eta3 <= theta(4) && ell(T, coeff(4), 9) == 0)
    m = 9;
    return;
end
if isSmall
    d10 = norm(Tpowers{4}*Tpowers{6},1)^(1/10);
else
    d10 = normAm(Tpowers{2}, 5)^(1/10);
end
eta4 = max(d8, d10);
eta5 = min(eta3, eta4);
s = max(ceil(log2(eta5/theta(5))), 0);
s = s + ell(T/2^s, coeff(5), 13);
if isinf(s)
    % Overflow in ell subfunction. Revert to old estimate.
    [t, s] = log2(norm(T,1)/theta(end));
    s = s - (t == 0.5); % adjust s if normA/theta(end) is a power of 2.
end
m = 13;
end
