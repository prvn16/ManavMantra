function varargout = sharedplotfunc(fname,inputvals)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2009-2016 The MathWorks, Inc.

% Default display functions for shared toolbox plots

n = length(inputvals);
toshow = false;
switch lower(fname)
    case 'bolling' % Numeric vector or matrix and optional grouping variable
        if n==2
            asset = inputvals{1};
            samples = inputvals{2};
            toshow = isnumeric(asset) && isvector(asset) && all(asset>0) && ...
                isnumeric(samples) && isscalar(samples) && samples>0 && round(samples)==samples;
        elseif n==3
            asset = inputvals{1};
            samples = inputvals{2};
            alpha = inputvals{3};
            toshow = isnumeric(asset) && isvector(asset) && all(asset>0) && ...
                 isnumeric(samples) && isscalar(samples) && samples>0 && round(samples)==samples && ...
                isscalar(alpha) && alpha>0;
        elseif n==4
            asset = inputvals{1};
            samples = inputvals{2};
            alpha = inputvals{3};
            width = inputvals{4};
            toshow = isnumeric(asset) && isvector(asset) && all(asset>0) && ...
                 isnumeric(samples) && isscalar(samples) && samples>0 && round(samples)==samples && ...
                isscalar(alpha) && alpha>0 && isscalar(width) && width>0;
        end
    case 'highlow'
        if n==3
            high = inputvals{1};
            low = inputvals{2};
            close = inputvals{3};
            toshow = isnumeric(high) && isnumeric(low) && isnumeric(close) && ...
                isvector(high) && size(high,2)==1 && isequal(size(high),size(low)) && ...
                isequal(size(high),size(close));
        elseif n==4
            high = inputvals{1};
            low = inputvals{2};
            close = inputvals{3};
            open = inputvals{4};
            toshow = isnumeric(high) && isnumeric(low) && isnumeric(close) && isnumeric(open) && ...
                isvector(high) && size(high,2)==1 && isequal(size(high),size(low)) && ...
                isequal(size(high),size(close)) && (isempty(open) || isequal(size(high),size(open)));
        elseif n==5
            high = inputvals{1};
            low = inputvals{2};
            close = inputvals{3};
            open = inputvals{4};
            color = inputvals{5};
            toshow = isnumeric(high) && isnumeric(low) && isnumeric(close) && isnumeric(open) && ...
                isvector(high) && size(high,2)==1 && isequal(size(high),size(low)) && ...
                isequal(size(high),size(close)) && (isequal(size(high),size(open)) || isempty(open)) && ...
                ischar(color);
        end
    case 'candle'
        if n==4
            high = inputvals{1};
            low = inputvals{2};
            close = inputvals{3};
            open = inputvals{4};
            toshow = isnumeric(high) && isnumeric(low) && isnumeric(close) && isnumeric(open) && ...
                iscolumn(high) && iscolumn(low) && iscolumn(close) && ...
                iscolumn(open) && length(high)==length(low) && length(high)==length(close) && ...
                length(high)==length(open);
        end
    case 'kagi'
        if n==1
            x = inputvals{1};
            toshow = (isnumeric(x) && ismatrix(x) && size(x,2)==2 && ...
                size(x,1)>1 && all(x(:,2)>=0))|| checkDateTable(x,2);
        end
    case 'renko'
        if n==1
            x = inputvals{1};
            toshow = (isnumeric(x) && ismatrix(x) && size(x,2)==2 && ...
                size(x,1)>1 && all(x(:,2)>=0))|| checkDateTable(x,2);
        elseif n==2
            x = inputvals{1};
            threshold = inputvals{2};
            toshow = ((isnumeric(x) && ismatrix(x) && size(x,2)==2 && ...
                size(x,1)>1 && all(x(:,2)>=0))|| checkDateTable(x,2))&&...
                isscalar(threshold) && threshold>=0;
        end
    case 'movavg'
        if n==3
            asset = inputvals{1};
            lead = inputvals{2};
            lag = inputvals{3};
            toshow = isnumeric(asset) && isvector(asset) && all(asset(:)>=0) && ...
                isscalar(lead) && isscalar(lag) && lead<=lag && round(lead)==lead && ...
                round(lag)==lag;
        elseif n==4
            asset = inputvals{1};
            lead = inputvals{2};
            lag = inputvals{3};
            alpha = inputvals{4};
            toshow = isnumeric(asset) && isvector(asset) && all(asset(:)>=0 | isnan(asset)) && ...
                isscalar(lead) && isscalar(lag) && lead<=lag && round(lead)==lead && ...
                round(lag)==lag && ((isnumeric(alpha) && isscalar(alpha) && alpha>=0) || ...
                    (ischar(alpha) && strcmp(alpha,'e')));
        end
    case 'priceandvol'
        if n==1
            x = inputvals{1};
            toshow = (isnumeric(x) && ismatrix(x) && size(x,1)>1 && size(x,2)==6 && ...
                all(x(:)>=0)) || checkDateTable(x,6);
        end
    case 'pointfig'
         if n==1
            x = inputvals{1};
            toshow = isnumeric(x) && isvector(x) && ~isscalar(x) && all(x(:)>=0);
         end
    case 'volarea'
         if n==1
            x = inputvals{1};
            toshow = (isnumeric(x) && ismatrix(x) && size(x,1)>1 && size(x,2)==3 && ...
                all(x(:)>=0)) || checkDateTable(x,3);  
         end    
end
varargout{1} = toshow;

end

function dtCheck = checkDateTable(x,numCols)
%This function is used for some of the finance charting functions to look
%for tables where the first column is datetimes or another date format, and the rest positive
%numerics

%Check that x is a table with the correct number of columns and that the
%first column contains a valid date format
dtCheck = istable(x) && size(x,2)==numCols && size(x,1) > 1 && ...
    (isnumeric(x{:,1}) || ischar(x{:,1}) || iscellstr(x{:,1}) || isdatetime(x{:,1}));

%Check that all other rows numeric and positive
for n = 2:numCols
    dtCheck = dtCheck && isnumeric(x{:,n}) && all(x{:,n}>=0);
end

end


