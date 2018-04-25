function isFirstUpdate = updateHistData(ntx,data, inputDataTypeObject)
% Update stored histogram with new data from user application.
% Also update data statistics.

%   Copyright 2010 The MathWorks, Inc.

% assume this is the first data update
isFirstUpdate = true;

% Nothing to do if data is empty
% Moreover, later comparisons may fail with empty
if isempty(data)
    return
end

% Before updating the data count, test if we're at "zero count" state
% We can use this for any first-time-only computations
isFirstUpdate = (ntx.DataCount==0);

% If first update, then check to see if he incoming data is a fixed-point
% type. In the case of a fixed-point type,  but not a fi-double, fi-single,  update the BitAllocation panel
% parameters to match the incoming data type. This is done only the first
% time data is passed in.
if isFirstUpdate 
    % Cannot use isfixed() since it returns false for a scaled-double FI
    % object.
    if ~isfloat(data) || (~isempty(inputDataTypeObject) && ~isfloat(inputDataTypeObject))
        if isa(data,'embedded.fi')
            dataTypeObject = data.numerictype;
        elseif isinteger(data)
            switch class(data)
                % 'int64' & 'uint64' not supported by fixdt - see G627624.
                case 'int64'
                    dataTypeObject = fixdt('sfix64');
                case 'uint64'
                    dataTypeObject = fixdt('ufix64');
                otherwise
                    % get the data type object for the integer type.
                    dataTypeObject = fixdt(class(data));
            end
        else
            dataTypeObject = inputDataTypeObject;
        end
        wordLength = dataTypeObject.WordLength;
        fractionLength = dataTypeObject.FractionLength;
        signedness = dataTypeObject.Signedness;
        % Update the Word Length, Fraction Length and Signedness parameters on the Bit Allocation panel.
        dlg = ntx.hBitAllocationDialog;
        % Set "Specify constraint" to "Fractional bits" and specify the fraction
        % length.
        setBAILFLMethod(dlg, 5); % Fractional bits
        setBAFLBits(dlg,fractionLength);
        % Set the Word Length mode to "Specify" and update the word length
        % value.
        setBAWLMethod(dlg,2);
        setBAWLBits(dlg,wordLength);
        % Update the Signedness property
        switch lower(signedness)
            case 'signed'
                setSignedMode(dlg,2); % Signed.
            case 'unsigned'
                setSignedMode(dlg, 3); % unsigned
        end
    end
end
% Force data into a column of doubles. N-D data is vectorized into one
% column. If the data is complex, the real and imaginary part of the data
% are vectorized into one column. Complex data can only have a single
% quatizer applied to it i.e., real and imaginary parts cannot be quantized
% differently. 
if ~isreal(data)
    data_re = real(data(:));
    data_im = imag(data(:));
    data = [data_re;data_im];
end
data = double(data(:).');

% Update count of data values
%
% Do this now, before removing zeros
% (Zeros count as data!)
ntx.DataCount = ntx.DataCount + numel(data);

% Record number of "exact zero" values and remove them
%
iZero = (data==0);
ntx.DataZeroCnt = ntx.DataZeroCnt + sum(iZero);
data(iZero) = [];

% If we removed all the data, there's nothing more to do. Also, don't process the data any further if they are all Infs/NaNs
if isempty(data) || all(isinf(data(:))) || all(isnan(data(:))) 
    return
end

% Update data statistics
%
% Note that IsSigned, BinCounts, and BinCenters are updated later in this
% function
% DataMax and DataMin will be empty after a reset
if isempty(ntx.DataMax)
    ntx.DataMax = max(data);
else
    ntx.DataMax = max(ntx.DataMax,max(data));
end
if isempty(ntx.DataMin)
    ntx.DataMin = min(data);
else
    ntx.DataMin = min(ntx.DataMin,min(data));
end
% Sum of (possibly signed) data values
ntx.DataSum = ntx.DataSum + sum(data);

% Check for Inf & NaN. Remove these from the data before processing them
% further
inf_indx = isinf(data);
data(inf_indx) = [];

posVals = (data>0); % logical vector
numPosVals = sum(posVals);
ntx.DataPosCnt = ntx.DataPosCnt + numPosVals;

negVals = (data<0); % logical vector
numNegVals = sum(negVals);
ntx.DataNegCnt = ntx.DataNegCnt + numNegVals;


% Update statistics necessary for SQNR computation
% Uses the PREVIOUS settings for signedness, WL, FL, etc.
%
% NOTE: This must be "dumped" every time the int/frac bits change
[~,fl,wl,isSigned] = getWordSize(ntx,true);
roundMode = getRoundingMode(ntx.hBitAllocationDialog);
% Determine vector of quantized (double-prec) values, and whether each
% value was saturated or not
[qdata,qsat] = embedded.ntxui.quantizeVector(data,isSigned,wl,fl,roundMode);
if ntx.OptionIgnoreOverflowInSQNR
    qdata = qdata(~qsat); % quantized non-saturated values
    nqdata = data(~qsat); % corresponding non-quantized values
else
    nqdata = data;
end
ntx.SSQ = ntx.SSQ + sum(nqdata.^2);           % sum of squared data
ntx.SSQE = ntx.SSQE + sum((nqdata-qdata).^2); % sum of squared error
ntx.NumSSQE = ntx.NumSSQE + numel(nqdata);    % maintain independent count

% Determine min and max bin center for incoming data
% We do this regardless of floating or fixed-point values
% We don't want "canonical" ranges, we want value-based estimates
%
% Get power-of-2 exponent of data
bin_data = getBinsForData(ntx, data);

% Determine min and max range based on absolute values
% Compute reasonable bin limits.
xmax_exp = ceil(max(bin_data)); 
xmin_exp = floor(min(bin_data))-1; 

% Compute histogram on data
%
% We maintain separate bin count vectors for pos and neg data.
% This provides flexibility in our display:
%  - option for stacked bars of pos/neg values
%  - option for changing signed-ness during updates
%    and assessing the impact of that decision
%
% We maintain one global bin-center vector that is updated with each new
% vector of data received, and establishes one common (and growing)
% x-axis of dynamic range bins.  All bin center entries in the one bin
% center vector are "absolute values."
%
% This means we use the same bin center vector across both "computeHist" calls.
% There may be zero-counts returned for some bins when the pos-only and
% neg-only local histograms are computed. Consistency in bin centers is
% achieved, albeit with minor computational overhead of giving computeHist() a
% bin center range that is not tight to the pos-only and neg-only data
% ranges; it's a global bin center range that spans both pos and neg abs
% value ranges.

% CAUTION: Computation of xmin_exp is critical.
%
% Each histogram bin will contain:
%         2^n < Vals <= 2^(n-1) or (2^n, 2^n-1] for positive numbers
%        -2^n <= Vals < -2^(n-1) [-2^n, -2^n-1) for negative numbers
%
% The underflow cursor always goes to the right of the Fraction length
%
% Compute local pos and neg data value histograms
localCenters   = xmin_exp : xmax_exp; % exponents (N), not values (2^N)
localPosCounts = zeros(size(localCenters));
localNegCounts = zeros(size(localCenters));
pos_bin_data = bin_data(posVals);
neg_bin_data = bin_data(negVals);
offset = 1-(xmin_exp);
% Add offset that now become indices into localCenters.
for k=(pos_bin_data+offset)
    localPosCounts(k) = localPosCounts(k)+1; 
end
for k=(neg_bin_data+offset)
    localNegCounts(k) = localNegCounts(k)+1; 
end
try
    % Update global data value histograms
    [ntx.BinEdges,ntx.PosBinCounts,ntx.NegBinCounts] = ...
        updateLocalHist( ...
        ntx.BinEdges,ntx.PosBinCounts,ntx.NegBinCounts, ...
        localCenters,localPosCounts,localNegCounts);
    
    % Create a combined "pos+neg" histogram bin count vector for convenience.
    % Because of the consistency we maintain in the bin centers, we can add
    % these vectors directly.
    ntx.BinCounts = ntx.PosBinCounts + ntx.NegBinCounts;
    
    % This is a mini version of updateSignedStatus()
    % Only need updates to signed status if Auto mode selected
    %
    % NOTE: updateBar() calls us, then calls updateNumericTypesAndSigns(),
    %       so on-screen updates will occur later
    dlg = ntx.hBitAllocationDialog;
    if dlg.BASigned==1 % Auto
        ntx.IsSigned = ntx.DataNegCnt > 0;
    end
catch ntx_exception %#ok<NASGU>
   % Data could not be binned since it either contained Infs & NaNs. Ignore
   % error.
end

function [globalCenters,globalPosCounts,globalNegCounts] = ...
    updateLocalHist( ...
    globalCenters,globalPosCounts,globalNegCounts,...
    localCenters,localPosCounts,localNegCounts )
% Update global running histogram data based on new "local" histogram data
%
% - Merge new bin counts into global bins.
% - Identify where new bin centers fall with respect to old,
%   and expand bin center vector when necessary.
%
% Assumption: BinCenters are always consecutive integers

if isempty(globalCenters)
    % Global histogram has never been updated
    % Take local data as-is and return
    globalCenters   = localCenters;
    globalPosCounts = localPosCounts;
    globalNegCounts = localNegCounts;
else
    % Update non-empty global histogram vectors
    l1 = localCenters(1);  % "local" updates to histogram info
    l2 = localCenters(end);
    g1 = globalCenters(1);  % "global" histogram info
    g2 = globalCenters(end);
    
    if l1 >= g1 && l2 <= g2
        % local bins fall completely within old bins
        %
        % this should be the most common case for typical data statistics
        % after a few iterations
        %
        % No need to update BinCenters
        i1 = l1-g1+1; % starting index within BinCounts
        i2 = l2-g1+1; % ending index
        globalPosCounts(i1:i2) = globalPosCounts(i1:i2) + localPosCounts;
        globalNegCounts(i1:i2) = globalNegCounts(i1:i2) + localNegCounts;
        
    elseif l2 < g1
        % local bins fall to left of old bins
        globalCenters = l1:g2;  % local start index, old end index
        N = g1-l2-1; % # empty bins between local and old bins
        globalPosCounts = [localPosCounts zeros(1,N) globalPosCounts];
        globalNegCounts = [localNegCounts zeros(1,N) globalNegCounts];
        
    elseif l1 > g2
        % local bins fall to right of old bins
        globalCenters = g1:l2;  % old start index, local end index
        N = l1-g2-1; % # empty bins between old and local bins
        globalPosCounts = [globalPosCounts zeros(1,N) localPosCounts];
        globalNegCounts = [globalNegCounts zeros(1,N) localNegCounts];
        
    elseif l1 <= g1 && l2 >= g2
        % old bins fall completely within local bins
        % swap roles of local and old bins
        i1 = g1-l1+1; % starting index within localCenters
        i2 = g2-l1+1; % ending index
        localPosCounts(i1:i2) = localPosCounts(i1:i2) + globalPosCounts;
        globalPosCounts = localPosCounts; % swap
        localNegCounts(i1:i2) = localNegCounts(i1:i2) + globalNegCounts;
        globalNegCounts = localNegCounts; % swap
        globalCenters = localCenters;
        
    elseif l1 < g1
        % local bins overlap old bins on the left
        % Number of bins that fall to left of old bins
        globalCenters = l1:g2;  % local start index, old end index
        N = g1-l1;   % # local bins falling to left of old bins
        M = l2-g1+1; % # bins overlapped by localbins
        globalPosCounts(1:M) = globalPosCounts(1:M) + localPosCounts(N+1:end);
        globalPosCounts = [localPosCounts(1:N) globalPosCounts];
        globalNegCounts(1:M) = globalNegCounts(1:M) + localNegCounts(N+1:end);
        globalNegCounts = [localNegCounts(1:N) globalNegCounts];
        
    else % l2 > g2
        % assert(l2>g2);
        % local bins overlap old bins on the right
        globalCenters = g1:l2;
        N = g2-l1+2; % bin of local that is to the right of old
        M = l1-g1+1; % index of first old overlap bin
        globalPosCounts(M:end) = globalPosCounts(M:end) + localPosCounts(1:N-1);
        globalPosCounts = [globalPosCounts localPosCounts(N:end)];
        globalNegCounts(M:end) = globalNegCounts(M:end) + localNegCounts(1:N-1);
        globalNegCounts = [globalNegCounts localNegCounts(N:end)];
    end
end
