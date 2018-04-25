function varargout = arraytolimits( varargin )
% ARRAYTOLIMITS returns data extents of given vector
%     OUT = ARRAYTOLIMITS(IN) converts an array of values (IN) to a 4x1
%     vector of data extents in the form  [min, maxneg, minpos, max],
%     where:
%
%       min     : minimum value of vector (NaN if all NaNs)
%       maxneg  : maximum negative number in vector (NaN if no negatives)
%       minpos  : minimum positive number in vector (NaN if no positives)
%       max     : maximum value of vector (NaN if all NaNs)

%   Copyright 2012-2017 The MathWorks, Inc.

% Loop over each input array
varargout = cell(nargin);
for i = 1:nargin
    varargout{i} = localGetLimits(varargin{i});
end
end


function lims = localGetLimits(array)
% Bin values into two ranges: one for positive values and one for negative
% values.  Also check for the zero value separately

% Initial values that are extremes of their respective ranges.
negmn = inf;
negmx = -inf;
posmn = inf;
posmx = -inf;
hasZero = false;

for n = 1:numel(array)
    
    % Use double values for comparison to ensure we properly support
    % int data comparing against our initial inf's
    val = double(array(n));
    
    if ~isnan(val)
        if val>0
            % Check the positive range
            if val<posmn
                posmn = val;
            end
            if val>posmx
                posmx = val;
            end
            
        elseif val<0
            % Check the negative range
            if val<negmn
                negmn = val;
            end
            if val>negmx
                negmx = val;
            end
            
        else
            % Note that there is a zero
            hasZero = true;
        end
    end
end

% Combine results from each range and the zero detection for the overall
% limits
mn = min(negmn, posmn);
if hasZero
    mn = min(0, mn);
end

mx = max(negmx, posmx);
if hasZero
    mx = max(0, mx);
end

% Check for cases where our initial extreme value have not been altered.
% We can detect these as cases where the maximum is less than the minimum.
if mn>mx
    mn = NaN;
    mx = NaN;
end
if negmn>negmx
    negmx = NaN;
end
if posmn>posmx
    posmn = NaN;
end

lims = [mn negmx posmn mx];
end
