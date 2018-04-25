function C = normxcorr2(varargin)
%NORMXCORR2 Normalized two-dimensional cross-correlation.
%   C = NORMXCORR2(TEMPLATE,A) computes the normalized cross-correlation of
%   gpuArray TEMPLATE and A. The gpuArray A must be larger than the
%   gpuArray TEMPLATE for the normalization to be meaningful. The values of
%   TEMPLATE cannot all be the same. The resulting matrix C contains
%   correlation coefficients and its values may range from -1.0 to 1.0.
%
%   Class Support
%   -------------
%   The input matrices are numeric. The class underlying output matrix C is
%   double.
%
%   Remarks
%   -------
%   Normalized cross correlation is an undefined operation in regions where
%   A has zero variance over the full extent of the template. In these
%   regions, we assign correlation coefficients of zero to the output C.
%
%   Example
%   -------
%   template        = .2*gpuArray.ones(11);
%   % Make light gray plus on dark gray background
%   template(6,3:9) = .6;
%   template(3:9,6) = .6;
%   % Make white plus on black background
%   BW = template > 0.5;
%   figure, imshow(BW), figure, imshow(template)
%   % Make new image that offsets the template
%   offsetTemplate = .2*gpuArray.ones(21);
%   offset = [3 5];  % shift by 3 rows, 5 columns
%   offsetTemplate( (1:size(template,1))+offset(1),...
%                   (1:size(template,2))+offset(2) ) = template;
%   figure, imshow(offsetTemplate)
%
%   % cross-correlate BW and offsetTemplate to recover offset
%   cc = normxcorr2(BW,offsetTemplate);
%   [max_cc, imax] = max(abs(cc(:)));
%   [ypeak, xpeak] = ind2sub(size(cc),imax(1));
%   corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];
%   isequal(corr_offset,offset) % 1 means offset was recovered
%
%  See also CORRCOEF.

%   Copyright 2013-2015 The MathWorks, Inc.

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

[m,n] = size(T);
mn    = m*n;

local_sum_A = local_sum(A,m,n);
local_sum_A2 = local_sum(A.*A,m,n);

% Note: diff_local_sums should be nonnegative, but may have negative
% values due to round off errors. Below, we use max to ensure the
% radicand is nonnegative.
% diff_local_sums = ( local_sum_A2 - (local_sum_A.^2)/mn );
% denom_A = sqrt( max(diff_local_sums,0) );
% denom = denom_T*denom_A;
% numerator = (xcorr_TA - local_sum_A*sum(reshape(T,numel(T),1))/mn );

Tcol    = reshape(T,numel(T),1);
sumT    = sum(Tcol);
stdT    = std(Tcol);
denom_T = sqrt(mn-1)*stdT;
[numerator,denom] = arrayfun(@computeNumDen,local_sum_A,local_sum_A2,xcorr_TA);
    
    function [num,den] = computeNumDen(local_sum_a,local_sum_a2,xcorr_ta)
        diff_local_sum = local_sum_a2 - (local_sum_a^2)/mn;
        denom_A        = sqrt(max(diff_local_sum,0));
        den            = denom_T*denom_A;
        num            = xcorr_ta - local_sum_a*sumT/mn;
    end

% We know denom_T~=0 from input parsing;
% so denom is only zero where denom_A is zero, and in
% these locations, C is also zero.
% C = zeros(size(numerator));
% i_nonzero = find(denom > tol);
% C(i_nonzero) = numerator(i_nonzero) ./ denom(i_nonzero);
% Another numerics backstop. If any of the coefficients are outside the
% range [-1 1], the numerics are unstable to small variance in A or T. In
% these cases, set C to zero to reflect undefined 0/0 condition.
% C( ( abs(C) - 1 ) > sqrt(eps(1)) ) = 0;
tol = sqrt( eps( max(abs(reshape(denom,numel(denom),1)))) );
C   = arrayfun(@computeNCC,numerator,denom);
    function c = computeNCC(num,den)
        c = 0;
        if(den>tol)
            c = num/den;
        end
        c = (abs(c)-1<=sqrt(eps(1)))*c;
    end
end

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

% c = s(1+m:end-1,:)-s(1:end-m-1,:);
c =   subsref(s,substruct('()',{1+m:size(s,1)-1  ,':'})) ...
- subsref(s,substruct('()',{1  :size(s,1)-m-1,':'}));

s = cumsum(c,2);
% local_sum_A = s(:,1+n:end-1)-s(:,1:end-n-1);
local_sum_A =   subsref(s,substruct('()',{':',1+n:size(s,2)-1  })) ...
- subsref(s,substruct('()',{':',1  :size(s,2)-n-1}));
end

%-------------------------------
% Function  xcorr2_fast
%
function cross_corr = xcorr2_fast(T,A)

T_size = size(T);
A_size = size(A);
outsize = A_size + T_size - 1;

if (numel(T)<2500)
    cross_corr = conv2(rot90(T,2),A);
else
    cross_corr = freqxcorr(T,A,outsize);
end
end

%-------------------------------
% Function  freqxcorr
%
function xcorr_ab = freqxcorr(a,b,outsize)

% calculate correlation in frequency domain
Fa       = fft2(rot90(a,2),outsize(1),outsize(2));
Fb       = fft2(b,         outsize(1),outsize(2));
xcorr_ab = ifft2(Fa .* Fb, 'symmetric');
end

%-----------------------------------------------------------------------------
function [T, A] = ParseInputs(varargin)

narginchk(2,2)

T = gpuArray(varargin{1});
A = gpuArray(varargin{2});

hValidateAttributes(T,{'logical','numeric'},{'real','2d', 'finite','nonsparse'},...
    mfilename,'T',1);
hValidateAttributes(A,{'logical','numeric'},{'real','2d', 'finite','nonsparse'},...
    mfilename,'A',2);

checkSizesTandA(T,A)

% See geck 342320. If either A or T has a minimum value which is negative, we
% need to shift the array so all values are positive to ensure numerically
% robust results for the normalized cross-correlation.
A = shiftData(A);
T = shiftData(T);

checkIfFlat(T);
end

%-----------------------------------------------------------------------------
function B = shiftData(A)

B = double(A);

is_unsigned = strcmp(classUnderlying(A),'uint8')  || ...
    strcmp(classUnderlying(A),'uint16') || ...
    strcmp(classUnderlying(A),'uint32');
if ~is_unsigned
    
    min_B = min(reshape(B,numel(B),1));
    
    if min_B < 0
        B = B - min_B;
    end
    
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
end

%-----------------------------------------------------------------------------
function checkIfFlat(T)

s.type = '()'; s.subs = {1};
oneElement = subsref(T, s);
if all(oneElement==reshape(T,numel(T),1))
    error(message('images:normxcorr2:sameElementsInTemplate'))
end
end