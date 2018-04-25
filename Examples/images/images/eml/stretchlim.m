function lowhigh = stretchlim(varargin) %#codegen
% Copyright 2014 The MathWorks, Inc.
%#ok<*EMCA>

narginchk(1, 2);

img = varargin{1};

validateattributes(img, {'uint8', 'uint16', 'double', 'int16', 'single'}, ...
    {'real', 'nonsparse', 'nonempty'}, mfilename, 'I or RGB', 1); 
coder.internal.errorIf((ndims(img) > 3), ...
    'images:stretchlim:dimTooHigh');

tol = [.01 .99]; %default
if nargin == 2
    coder.internal.errorIf((numel(varargin{2})>2||isempty(varargin{2})), ...
        'images:stretchlim:invalidTolSize');
    if (numel(varargin{2})==1)
            tol(1) = varargin{2};
            tol(2) = 1.0 - tol(1);
    else
        tol = varargin{2};
        coder.internal.errorIf((tol(1)>=tol(2)), 'images:stretchlim:invalidTolOrder');
    end
end

coder.internal.errorIf((tol(1) < 0.0)||(tol(1)>1.0)||(isnan(tol(1)))|| ...
                        (tol(2) < 0.0)||(tol(2)>1.0)||(isnan(tol(2))), ...
                        'images:stretchlim:tolOutOfRange');


if isa(img,'uint8')
    nbins = 256;
else
    nbins = 65536;
end

tol_low = tol(1);
tol_high = tol(2);
 
p = size(img,3);

if tol_low < tol_high
    ilowhigh = zeros(2,p);
    
    for i = 1:p                          % Find limits, one plane at a time
        N = imhist(img(:,:,i),nbins);
        cdf = cumsum(N)/sum(N); %cumulative distribution function
        
        findLowFlag = true;
        findHighFlag = true;
        ilow = 0;
        ihigh= 0;
        
        for idx = 1:numel(cdf)
            if(findLowFlag && (cdf(idx) > tol_low))
                ilow = idx;
                findLowFlag = false;
            end
            
            if(findHighFlag && (cdf(idx) >= tol_high))
                ihigh = idx;
                findHighFlag = false;
            end
        end
        
        if ilow == ihigh   % this could happen if img is flat
            ilowhigh(:,i) = [1, nbins];
        else
            ilowhigh(:,i) = [ilow, ihigh];
        end
    end
    lowhigh = (ilowhigh - 1)/(nbins-1);  % convert to range [0 1]

else
    lowhigh = [zeros(1,p);ones(1,p)];
end
