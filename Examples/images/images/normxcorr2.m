function C = normxcorr2(varargin)
%NORMXCORR2 Normalized two-dimensional cross-correlation.
%   C = NORMXCORR2(TEMPLATE,A) computes the normalized cross-correlation of
%   matrices TEMPLATE and A. The matrix A must be larger than the matrix
%   TEMPLATE for the normalization to be meaningful. The values of TEMPLATE
%   cannot all be the same. The resulting matrix C contains correlation
%   coefficients and its values may range from -1.0 to 1.0.
%
%   Class Support
%   -------------
%   The input matrices can be numeric. The output matrix C is double.
%
%   Remarks
%   -------
%   Normalized cross correlation is an undefined operation in regions where
%   A has zero variance over the full extent of the template. In these
%   regions, we assign correlation coefficients of zero to the output C.
%
%   Example
%   -------
%
%   % Load images
%   onion   = rgb2gray(imread('onion.png'));
%   peppers = rgb2gray(imread('peppers.png'));
%   imshowpair(peppers,onion,'montage')
% 
%   c = normxcorr2(onion,peppers);
%   figure, surf(c), shading flat
% 
%   [ypeak, xpeak] = find(c==max(c(:)));
%   % Compute translation from max location in correlation matrix
%   yoffSet = ypeak-size(onion,1);
%   xoffSet = xpeak-size(onion,2);
%   
%   % Display matched area
%   figure
%   hAx  = axes;
%   imshow(peppers,'Parent', hAx);
%   imrect(hAx, [xoffSet+1, yoffSet+1, size(onion,2), size(onion,1)]);
%
%  See also CORRCOEF.

%   Copyright 1993-2015 The MathWorks, Inc.

%   Input-output specs
%   ------------------
%   T:    2-D, real, full matrix
%         logical, uint8, uint16, or double
%         no NaNs, no Infs
%         prod(size(T)) >= 2
%         std(T(:))~=0
%
%   A:    2-D, real, full matrix
%         logical, uint8, uint16, or double
%         no NaNs, no Infs
%         size(A,1) >= size(T,1)
%         size(A,2) >= size(T,2)
%
%   C:    double

[T, A] = ParseInputs(varargin{:});

%   We normalize the cross correlation to get correlation coefficients using the
%   definition of Haralick and Shapiro, Volume II (p. 317), generalized to
%   two-dimensions. 
%
%   Lewis explicitly defines the normalized cross-correlation in two-dimensions
%   in this paper (equation 2):
%   
%      "Fast Normalized Cross-Correlation", by J. P. Lewis, Industrial Light & Magic.
%
%   Our technical reference document on NORMXCORR2 shows how to get from
%   equation 2 of the Lewis paper to the code below.

xcorr_TA = xcorr2_fast(T,A);

[m, n] = size(T);
mn = m*n;

local_sum_A = local_sum(A,m,n);
local_sum_A2 = local_sum(A.*A,m,n);

% Note: diff_local_sums should be nonnegative, but may have negative
% values due to round off errors. Below, we use max to ensure the
% radicand is nonnegative.
diff_local_sums = ( local_sum_A2 - (local_sum_A.^2)/mn );
denom_A = sqrt( max(diff_local_sums,0) ); 

denom_T = sqrt(mn-1)*std(T(:));
denom = denom_T*denom_A;
numerator = (xcorr_TA - local_sum_A*sum(T(:))/mn );

% We know denom_T~=0 from input parsing;
% so denom is only zero where denom_A is zero, and in 
% these locations, C is also zero.
C = zeros(size(numerator));
tol = sqrt( eps( max(abs(denom(:)))) );
i_nonzero = find(denom > tol);
C(i_nonzero) = numerator(i_nonzero) ./ denom(i_nonzero);

% Another numerics backstop. If any of the coefficients are outside the
% range [-1 1], the numerics are unstable to small variance in A or T. In
% these cases, set C to zero to reflect undefined 0/0 condition.
C( ( abs(C) - 1 ) > sqrt(eps(1)) ) = 0;

%-------------------------------
% Function  local_sum
%
function local_sum_A = local_sum(A,m,n)

% We thank Eli Horn for providing this code, used with his permission,
% to speed up the calculation of local sums. The algorithm depends on
% precomputing running sums as described in "Fast Normalized
% Cross-Correlation", by J. P. Lewis, Industrial Light & Magic.

B = padarray(A,[m n]);
s = cumsum(B,1);
c = s(1+m:end-1,:)-s(1:end-m-1,:);
s = cumsum(c,2);
local_sum_A = s(:,1+n:end-1)-s(:,1:end-n-1);

%-------------------------------
% Function  xcorr2_fast
%
function cross_corr = xcorr2_fast(T,A)

T_size = size(T);
A_size = size(A);
outsize = A_size + T_size - 1;

% figure out when to use spatial domain vs. freq domain
conv_time = time_conv2(T_size,A_size); % 1 conv2
fft_time = 3*time_fft2(outsize); % 2 fft2 + 1 ifft2

if (conv_time < fft_time)
    cross_corr = conv2(rot90(T,2),A);
else
    cross_corr = freqxcorr(T,A,outsize);
end


%-------------------------------
% Function  freqxcorr
%
function xcorr_ab = freqxcorr(a,b,outsize)
  
% calculate correlation in frequency domain
Fa = fft2(rot90(a,2),outsize(1),outsize(2));
Fb = fft2(b,outsize(1),outsize(2));
xcorr_ab = ifft2(Fa .* Fb,'symmetric');

%-------------------------------
% Function  time_conv2
%
function time = time_conv2(obssize,refsize)

% time a spatial domain convolution for 10-by-10 x 20-by-20 matrices

% a = ones(10);
% b = ones(20);
% mintime = 0.1;

% t1 = cputime;
% t2 = t1;
% k = 0;
% while (t2-t1)<mintime
%     c = conv2(a,b);
%     k = k + 1;
%     t2 = cputime;
% end
% t_total = (t2-t1)/k;

% % convolution time = K*prod(size(a))*prod(size(b))
% % t_total = K*10*10*20*20 = 40000*K
% K = t_total/40000;

% K was empirically calculated by the commented-out code above.
K = 2.7e-8; 
            
% convolution time = K*prod(obssize)*prod(refsize)
time =  K*prod(obssize)*prod(refsize);


%-------------------------------
% Function  time_fft2
%
function time = time_fft2(outsize)

% time a frequency domain convolution by timing two one-dimensional ffts

R = outsize(1);
S = outsize(2);

% Tr = time_fft(R);
% K_fft = Tr/(R*log(R)); 

% K_fft was empirically calculated by the 2 commented-out lines above.
K_fft = 3.3e-7; 
Tr = K_fft*R*log(R);

if S==R
    Ts = Tr;
else
%    Ts = time_fft(S);  % uncomment to estimate explicitly
   Ts = K_fft*S*log(S); 
end

time = S*Tr + R*Ts;

% %-------------------------------
% % Function time_fft
% %
% function T = time_fft(M)

% % time a complex fft that is M elements long

% vec = complex(ones(M,1),ones(M,1));
% mintime = 0.1; 

% t1 = cputime;
% t2 = t1;
% k = 0;
% while (t2-t1) < mintime
%     dummy = fft(vec);
%     k = k + 1;
%     t2 = cputime;
% end
% T = (t2-t1)/k;


%-----------------------------------------------------------------------------
function [T, A] = ParseInputs(varargin)

narginchk(2,2)

T = varargin{1};
A = varargin{2};

validateattributes(T,{'logical','numeric'},{'real','nonsparse','2d','finite'},mfilename,'T',1)
validateattributes(A,{'logical','numeric'},{'real','nonsparse','2d','finite'},mfilename,'A',2)

checkSizesTandA(T,A)

% See geck 342320. If either A or T has a minimum value which is negative, we
% need to shift the array so all values are positive to ensure numerically
% robust results for the normalized cross-correlation.
A = shiftData(A);
T = shiftData(T);

checkIfFlat(T);

%-----------------------------------------------------------------------------
function B = shiftData(A)

B = double(A);

is_unsigned = isa(A,'uint8') || isa(A,'uint16') || isa(A,'uint32');
if ~is_unsigned
    
    min_B = min(B(:)); 
    
    if min_B < 0
        B = B - min_B;
    end
    
end

%-----------------------------------------------------------------------------
function checkSizesTandA(T,A)

if numel(T) < 2
    error(message('images:normxcorr2:invalidTemplate'))
end

if size(A,1)<size(T,1) || size(A,2)<size(T,2) 
    error(message('images:normxcorr2:invalidSizeForA'))
end

%-----------------------------------------------------------------------------
function checkIfFlat(T)

if std(T(:)) == 0
    error(message('images:normxcorr2:sameElementsInTemplate'))
end
