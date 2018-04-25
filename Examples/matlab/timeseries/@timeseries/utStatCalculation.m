function out = utStatCalculation(this,method,varargin) 
%UTSTATCALCULATION (used by statistical calculations)

% UTSTATCALCULATION return the result of statistical calculation on data.
% Method is a string, e.g. 'mean'. Varargin involves all the PV pairs for
% optional input arguments: 
%       'MissingData': 'remove' (default) or 'interpolate'
%           indicating how to treat missing data during the calculation
%       'Quality': a vector of integers
%           indicating which quality codes represent missing samples
%           (vector case) or missing observations (>2 dimensional array
%           case) 
%       'Weighting': 'none' (default) or 'time'
%           indicating if times are used as weighting factors during the
%           calculation.  Large time values mean large weight.
%

% Copyright 2004-2016 The MathWorks, Inc.

if numel(this)~=1
    error(message('MATLAB:timeseries:utStatCalculation:noarray'));
end
if this.Length==0
    out = [];
    return
end

% Get data
data = this.Data;
quality = this.Quality;
SampleSize = getdatasamplesize(this);

% Set default option values
HowToTreatMissingData = 'remove';
QualityCodeForMissingData = [];
WeightFactor = 'none';

% Check if extra input arguments exist in PV pair format
ni=nargin-2;
if nargin>2
    for i=1:2:ni
        % Set each Property Name/Value pair in turn. 
        Property = varargin{i};
        if i+1>ni
            error(message('MATLAB:timeseries:utStatCalculation:pvsetNoValue'))
        else
            Value = varargin{i+1};
        end
        % Perform assignment
        switch lower(char(Property))
            case 'missingdata'
                if ischar(Value) || (isstring(Value) && isscalar(Value))
                    % Single string or char vector
                    HowToTreatMissingData = Value;
                    if ~(strcmpi(HowToTreatMissingData,'interpolate') || strcmpi(HowToTreatMissingData,'remove'))
                        error(message('MATLAB:timeseries:utStatCalculation:missingdata'));
                    end                        
                else
                    error(message('MATLAB:timeseries:utStatCalculation:missingdata'));
                end
            case 'quality'
                if isnumeric(Value) && isequal(round(Value),Value)
                    QualityCodeForMissingData = Value;
                else
                    error(message('MATLAB:timeseries:utStatCalculation:quality'));
                end
            case 'weighting'
                if ischar(Value) || (isstring(Value) && isscalar(Value))
                    % Single string or char vector
                    WeightFactor = Value;
                    if ~(strcmpi(WeightFactor,'none') || strcmpi(WeightFactor,'time'))
                        error(message('MATLAB:timeseries:utStatCalculation:weighting'));
                    end                            
                else
                    error(message('MATLAB:timeseries:utStatCalculation:weighting'));
                end
            otherwise
                error(message('MATLAB:timeseries:utStatCalculation:pvsetInvalidVal'))
       end % switch
    end % for
end

% Find missing data based on 'TreatNaNasMissing' and 'quality' values
MissingDataIndex_Observation = false(size(data));
MissingDataIndex_Sample = false(this.Length,1);
is = repmat({':'},[1 length(SampleSize)]);
if this.TreatNaNasMissing
    MissingDataIndex_Observation = MissingDataIndex_Observation | isnan(data);
end
if ~isempty(quality)
    % quality is sample-based with size of nx1
    if isvector(quality) || (~this.IsTimeFirst && isequal(size(quality),[ones(1,ndims(data)-1) this.Length]))
        quality = quality(:);
        ind = ismember(quality,QualityCodeForMissingData);
        if ~any(ind)
            warning(message('MATLAB:timeseries:utStatCalculation:noqualitycode'))
        end
        MissingDataIndex_Sample = MissingDataIndex_Sample | ind;
        if this.IsTimeFirst
            tmp = [{MissingDataIndex_Sample} is];
        else
            tmp = [is {MissingDataIndex_Sample}];
        end
        MissingDataIndex_Observation(tmp{:})=true;
    elseif isequal(size(quality),size(data))
        ind = ismember(quality,QualityCodeForMissingData);
        if ~any(ind)
            warning(message('MATLAB:timeseries:utStatCalculation:noqualitycode'))
        end
        MissingDataIndex_Observation = MissingDataIndex_Observation | ind;
    end
else
    if ~isempty(QualityCodeForMissingData)
        warning(message('MATLAB:timeseries:utStatCalculation:noquality'))
    end        
end
        
% No weighting factor
if strcmpi(WeightFactor,'none')
    if this.TreatNaNasMissing 
        % interpolate missing data
        if strcmpi(HowToTreatMissingData,'interpolate')
            interpobj = this.DataInfo.Interpolation;
            tmp_data = interpobj.interpolate(this.Time, this.Data, this.Time,[],...
                this.hasduplicatetimes);
        % remove missing data
        else
            tmp_data = data;
            tmp_data(MissingDataIndex_Observation) = NaN;
        end
    else
        tmp_data = data;
    end
% Weighted by time
else
    % calculate time factor
    dt = diff(this.Time)/2;
    dt1 = [dt(1);dt];
    dt2 = [dt;dt(end)];
    dt = dt1+dt2;
    
    if this.TreatNaNasMissing 
        % interpolate missing data
        if strcmpi(HowToTreatMissingData,'interpolate')
            interpobj = this.DataInfo.Interpolation;
            data = interpobj.interpolate(this.Time, this.Data, this.Time, [], ...
                this.hasduplicatetimes);
            datasize = size(this.Data);
            if this.IsTimeFirst
                data = data.*repmat(dt,[1 datasize(2:end)]);
            else
                data = data.*repmat(dt',[datasize(1:end-1) 1]);
            end
            tmp_data = data/mean(dt);
        % remove missing data
        else
            datasize = size(this.Data);
            if this.IsTimeFirst
                data = data.*repmat(dt,[1 datasize(2:end)]);
            else
                data = data.*repmat(shiftdim(dt',-1),[datasize(1:end-1) 1 1]);
            end
            tmp_data = data/mean(dt);
            tmp_data(MissingDataIndex_Observation) = NaN;
        end
    else
        tmp_data = data;
    end
end
        
% Calculation
if this.IsTimeFirst
    dim = 1;
else
    dim = length(size(tmp_data));    
    dim = dim(end);
end
if this.TreatNaNasMissing 
    switch char(method)
        case 'mean'
            out = tsnanmean(tmp_data,dim);
        case 'median'
            out = tsnanmedian(tmp_data,dim);
        case 'std'
            out = tsnanstd(tmp_data,0,dim);
        case 'iqr'
            out = tsnaniqr(tmp_data,dim);
        case 'sum'
            out = tsnansum(tmp_data,dim);
        case 'max'
            out = tsnanmax(tmp_data,[],dim);
        case 'min'
            out = tsnanmin(tmp_data,[],dim);
        case 'var'
            out = tsnanvar(tmp_data,0,dim);
        case 'mode'
            out = tsnanmode(tmp_data,dim);
        otherwise
            error(message('MATLAB:timeseries:utStatCalculation:method'))                
    end
else
     switch char(method)
        case 'mean'
            out = mean(tmp_data,dim);
        case 'median'
            out = median(tmp_data,dim);
        case 'std'
            out = std(tmp_data,0,dim);
        case 'iqr'
            out = iqr(tmp_data,dim);
        case 'sum'
            out = sum(tmp_data,dim);
        case 'max'
            out = max(tmp_data,[],dim);
        case 'min'
            out = min(tmp_data,[],dim);
        case 'var'
            out = var(tmp_data,0,dim);
        case 'mode'
            out = mode(tmp_data,dim);
        otherwise
            error(message('MATLAB:timeseries:utStatCalculation:method'))                
     end
end

