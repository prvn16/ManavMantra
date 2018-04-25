function [I, time, varargout] = tssorttime(time,varargin)
%
% timeseries utility function

%   Copyright 2004-2016 The MathWorks, Inc.

% TSSORTTIME Utility to sort time vector and detect duplicate records
%
% Sort time numeric or cell array datestr data, remove duplicate 
% samples with identical data. If a data vector is supplied this function
% will error out if duplicate time records exist with non duplicate data. 

len = length(time);
istimefirstprovided = [];
if nargin>=2
    data = varargin{1};
    s = size(data);
    if s(1)~=len && s(end)~=len && len>1
        error(message('MATLAB:tssorttime:mismatch'))
    end
    if nargin==3
        istimefirstprovided = varargin{2};
    end
end

% Return [] if empty
if isempty(time)
    I = [];
    if nargin>=2
        varargout{1}=data;
    end
    return
end

% Convert datestr times to numeric vector
if iscell(time)
    if iscellstr(time)
        time = datenum(time);
    else
        time = datenum(cellstr(time));
    end
elseif isstring(time)
    time = datenum(cellstr(time));
end
    

% Return the same if single 
if isscalar(time)
    I = 1;
    if nargin>=2
        varargout{1}=data;
    end
    return
end

%% Sort generate sorting index, sort both time and data
timeissorted = issorted(time);
if ~timeissorted
    [time, I] = sort(time);
    % rearrange data
    if nargin>=2
        % Slice data
        if s(1)==len && s(end)~=len
            ind = [{I} repmat({':'}, [1 length(s)-1])];
        elseif s(1)~=len && s(end)==len
            ind = [repmat({':'}, [1 length(s)-1]) {I}];
        elseif s(1)==len && s(end)==len
            if isempty(istimefirstprovided)
                error(message('MATLAB:tssorttime:istimefirst'))
            end
            if istimefirstprovided
                ind = [{I} repmat({':'}, [1 length(s)-1])];
            else
                ind = [repmat({':'}, [1 length(s)-1]) {I}];         
            end     
        end
        data = data(ind{:});
    end
else 
   I = (1:length(time))';
end


if nargin>=2
    varargout{1}=data;
end