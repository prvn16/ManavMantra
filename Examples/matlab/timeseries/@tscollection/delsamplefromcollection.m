function this = delsamplefromcollection(this,method,value)
%DELSAMPLEFROMCOLLECTION  Delete sample(s) from a tscollection object.
%
%   TSC = DELSAMPLEFROMCOLLECTION(TSC,'Index',VALUE) removes samples from
%   the tscollection
%   object TSC. Here, VALUE specifies the indices of the TSC time vector that
%   correspond to the samples you want to remove.
%   
%   TSC = DELSAMPLEFROMCOLLECTION(TSC,'Value',VALUE) removes samples from the tscollection
%   object TSC. Here, VALUE specifies the time values that correspond to the
%   samples you want to remove.  
%
%   See also TSCOLLECTION/TSCOLLECTION, TSCOLLECTION/ADDSAMPLETOCOLLECTION

%   Copyright 2005-2016 The MathWorks, Inc.


% Process input args
if (ischar(method) && isvector(method)) || (isstring(method) && isscalar(method))
    % Single string or char vector
    switch lower(char(method))
        case 'index'
            if ~isnumeric(value) || ~isvector(value)
                error(message('MATLAB:tscollection:delsamplefromcollection:needinteger'));
            else
                % Make sure indices are unique
                selectedIndexArray = unique(value);
                % Check if all the indices are valid    
                if ~isequal(round(selectedIndexArray),selectedIndexArray) || any(selectedIndexArray<0) || ...
                        any(selectedIndexArray>this.Length)
                    error(message('MATLAB:tscollection:delsamplefromcollection:badindex'))
                end
            end
        case 'value'
            % If it is an array of chars or strings (absolute dates)
            if ischar(value) || iscellstr(value) || isstring(value) || (iscell(value) && all(cellfun('isclass',value,'string'))) 
                % If time series object requires relative time points, error out
                if isempty(this.Timeinfo.Startdate)
                    error(message('MATLAB:tscollection:delsamplefromcollection:badvalue'));      
                else  % Otherwise, get time values relative to the StartDate and Units values   
                    value = tsAnalyzeAbsTime(value,this.Timeinfo.Units,this.Timeinfo.Startdate);
                end
            elseif isnumeric(value) && isvector(value)
                % Make sure time is a column vector
                if size(value,2) > 1
                    value = value';
                end
            else
                error(message('MATLAB:tscollection:delsamplefromcollection:badtimeformat'));
            end
            try
                selectedIndexArray = ismember(this.Time,value);
            catch %#ok<*CTCH>
                error(message('MATLAB:tscollection:delsamplefromcollection:badformat'))
            end
            if isempty(selectedIndexArray)
                return;
            end
        case 'nearest'
            % TO DO
        otherwise
            error(message('MATLAB:tscollection:delsamplefromcollection:badsyntax'))
    end
else
    error(message('MATLAB:tscollection:delsamplefromcollection:badmethod'))
end

% Delete sample in a loop

% Modify the time vector
time = this.Time;
time(selectedIndexArray) = [];
this.TimeInfo = setlength(this.TimeInfo,length(time));
this.Time = time;

% Modify the members
for k=1:length(this.Members_)   
    ind = repmat({':'},[1 ndims(this.Members_(k).Data)-1]);
    if this.Members_(k).IsTimeFirst
        this.Members_(k).Data(selectedIndexArray,ind{:}) = [];
        if ~isempty(this.Members_(k).Quality)
           ind = repmat({':'},[1 ndims(this.Members_(k).Quality)-1]);
           this.Members_(k).Quality(selectedIndexArray,ind{:}) = [];
        end
    else
        this.Members_(k).Data(ind{:},selectedIndexArray) = [];
        if ~isempty(this.Members_(k).Quality)
           ind = repmat({':'},[1 ndims(this.Members_(k).Quality)-1]);
           this.Members_(k).Quality(ind{:},selectedIndexArray) = [];
        end
    end
end