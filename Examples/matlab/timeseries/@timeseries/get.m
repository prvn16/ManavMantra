function Value = get(ts,varargin)
%GET  Access/Query time series property values.
%
%   VALUE = GET(TS,'PropertyName') returns the value of the 
%   specified property of the time series object.  An equivalent
%   syntax is 
%
%       VALUE = TS.PropertyName 
%   
%   GET(TS) displays all properties of TS and their values.  
%
%   See also TIMESERIES\SET, TIMESERIES\TSPROPS.

%   Copyright 2004-2016 The MathWorks, Inc.

if isempty(ts)
    Value = [];
    return;
end

if numel(ts)==1 % get on a scalar timeseries
    Value = uttsget(ts,varargin{:});
    return
end

% Process array values
if nargin>=2 % get on a timeseries array with specified properties
    if ischar(varargin{1}) || (isstring(varargin{1}) && isscalar(varargin{1}))
        % Single char vector or single string
        Value = cell(size(ts));
        for k=1:numel(ts)
            Value{k} = uttsget(ts(k),varargin{:});
        end
    elseif iscell(varargin{1}) || isstring(varargin{1})
        % cellstr array or an array of string
        props = varargin{1};
        Value = cell(numel(ts),length(props));
        for k=1:numel(ts)
            for j=1:length(props)
                % Note that props{j} is a char array, when props is a string
                Value{k,j} = uttsget(ts(k),props{j});
            end
        end
    end
else % Return a stuct array for a timeseries array with no props
    for k=numel(ts):-1:1
        Value(k) = uttsget(ts(k),varargin{:});
    end
end
