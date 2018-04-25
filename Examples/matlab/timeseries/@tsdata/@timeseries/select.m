function I = select(this,rule,varargin)

% Copyright 2004-2012 The MathWorks, Inc.

h = this.tsValue;

%% Initialize and restrict to 2d arrays
data = h.data;
if h.IsTimeFirst && ndims(data)>2
    error(message('MATLAB:tsdata:timeseries:select:nodims'))
elseif ~h.IsTimeFirst && (ndims(data)>4 || (ndims(data)==3 && size(data,2)>1))
    error(message('MATLAB:tsdata:timeseries:select:nodims'))
end
rule = lower(rule);

%% Parse input args
cols = [];
switch rule
    case 'outliers'
        if nargin<4
            error(message('MATLAB:tsdata:timeseries:select:noWinlengthAndConfLevel'))
        end
        % default value can be 10% of the length of data
        winlength = varargin{1};
        % default value can be 95, which mean 95%
        conf = varargin{2};
        if nargin>=5
            cols = varargin{3};
        end
    case 'flatlines'
        if nargin<3
           error(message('MATLAB:tsdata:timeseries:select:noWinLength'))
        end
        winlength = varargin{1};
        if nargin>=4
            cols = varargin{3};
        end        
    otherwise
           error(message('MATLAB:tsdata:timeseries:select:arginv'));
end

%% Initialize the columns
if isempty(cols)
    if h.IsTimeFirst
        cols = 1:size(data,2);
        data = data(:,cols);
    else
        cols = 1:size(data,1);
        data = squeeze(data(cols,1,:))';
    end
end


%% Initialize output
if h.IsTimeFirst
    I = false(h.TimeInfo.Length,length(cols));
else
    I = false(length(cols),h.TimeInfo.Length);
end
        
switch lower(rule)
    case 'outliers'
        confconst = sqrt(2)*erfinv(2*conf/100-1);
        erfconst = .5/(sqrt(2)*erfinv(.5));
        for row=1:h.TimeInfo.Length
            L = min(max(row-floor(winlength/2),1),h.TimeInfo.Length-winlength);
            U = L+winlength;
            I(row,:) = localoutlier(data(L:U,cols),confconst,erfconst,data(row,:));
        end
    case 'flatlines'
        % Insert infs at the start and end to ensure we detect flatlines
        % which occur at the start and end
        dX = diff(diff([inf*ones(1,length(cols));data;inf*ones(1,length(cols))])==0);
        % Find indices of leading and trailing edges of constant periods
        for col=1:length(cols)
           I1 = find(dX(:,col)==1);
           I2 = find(dX(:,col)==-1);
           for row=1:size(I1,1)
              % If the constant period is longer than the window length set
              % all the corresponding indices to excluded
                I(I1(row):I2(row),col) = ...
                        (I2(row)-I1(row)+1>=winlength);
           end
        end
    otherwise
           error(message('MATLAB:tsdata:timeseries:select:arginv'));
        
end

function idx = localoutlier(x,confconst,erfconst,thisx)

%% Local function to estimate the whether the observation thisx (row)
%% falls outside the confidence band defined by confconst for the
%% dataset defined by x. Note that each observation of x is a row.

med = median(x);

%% TO DO: Better estimates of iqr
%% TO DO: Add iqr calc, can we do this more efficiently recursively?
if size(x,1)<4
    sigma = std(x);
else % Robust estimate of sigma from iqr
    [xsort, I] = sort(x);
    sigma = erfconst*(xsort(ceil(3*size(x,1)/4),:)-xsort(floor(size(x,1)/4),:));
end
idx = (thisx>med+confconst*sigma | thisx<med-confconst*sigma);

