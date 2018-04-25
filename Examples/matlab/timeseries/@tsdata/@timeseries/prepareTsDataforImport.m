function status = prepareTsDataforImport(ts,varargin)
%Check is time series data is fit for importing into tstool.
%  - Return "failed" status if data is complex.
%  - Make time the first dimension (so that IsTimeFirst is true).
%  - Fold higher dimensions as columns.
%  - Convert non-double data into double.
%  - convert sparse data into full.
%  - Throw error if '/' appears in the name of timeseries.
%  - Scalarize StartTime/EndTime.
%  - Convert Infs into NaNs.
%  - Remove Quality info if quality description is empty.
%  - Reconcile the units of events and timeseries.

% This function should be called by the createTsToolNode methods of
% timeseries, and simulink timeseries, and also by the data replacement
% subroutine of simulinkParentNode/createChild method.

%   Author(s): Rajiv Singh
%   Copyright 2005-2012 The MathWorks, Inc.

status = true;

% Look for slashes in the name of Timeseries object
I = strfind(ts.tsValue.Name,'/');
if ~isempty(I)
    error(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:invalidsignalname'))
end

% No complex numbers allowed for data
if ~isreal(ts.tsValue.Data)
    msg = sprintf(getString(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:CannotUseComplexvaluedTS',...
        ts.tsValue.Name)));
    errordlg(msg, getString(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:TimeSeriesTools')),'modal')
    status = false;
    return
end

%% No empty names allowed for timeseries name
if isempty(ts.tsValue.Name) && ~isa(ts.tsValue,'Simulink.Timeseries') %Simulink Timeseries can have empty names, and they are repopulated..
    msg = getString(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:CannotUseTSWithEmptyNames'));
    errordlg(msg, getString(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:TimeSeriesTools')),'modal')
    status = false;
    return
end

% Sample-based quality values not allowed, if data is multi-column
szq = size(ts.tsValue.Quality);
if sum(szq>1)>1
    msg = getString(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:TimeSeriesQualitySameSizeAsTimeVector'));
    errordlg(msg, getString(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:TimeSeriesTools')),'modal')
    status = false;
    return
end


% check isTimeFirst value and make it true if it is false
if ~ts.tsValue.IsTimeFirst
    % Since IsTimefirst cannot be used to flip the data dimensions in transpose method, 
    % reshaping the data and quality
    data = reshape(ts.tsValue.Data ,[length(ts.tsValue.Time) numel(ts.tsValue.Data)/length(ts.tsValue.Time)]);
    ts.tsValue.Data = data;
    if ~isempty(ts.tsValue.Quality)
        quality = reshape(ts.tsValue.Quality ,[length(ts.tsValue.Time) numel(ts.tsValue.Quality)/length(ts.tsValue.Time)]);
        ts.tsValue.Quality = quality;
    end
end

% check the size of each sample and return error if the sample size is not
% 1-by-1 or a vector
s = size(ts.tsValue.Data);
if length(s)>2 
    data = reshape(ts.tsValue.Data,s(1),prod(s(2:end))); %we know Time is first column
    ts.tsValue.Data = data;
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:NDdata', ts.Name, num2str( s )))
    warning(b_state);
end

% Check data class and sparseness
if ~isa(ts.tsValue.Data,'double')
    ts.tsValue.Data = double(ts.tsValue.Data);
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:nondoubledata', ts.Name))
    warning(b_state);
end

if issparse(ts.tsValue.data)
    try
        ts.tsValue.Data = full(ts.tsValue.Data);
        b_state = warning('query','backtrace');
        warning off backtrace;
        warning(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:sparsedata', ts.Name)) 
        warning(b_state);
    catch me %#ok<NASGU>
        disp(getString(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:ConvertingSparseDataInTimeSeriesToDouble')))
        error(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:largesparsedata', ts.Name))
    end
end

% Check for Inf/-Inf and convert them into NaNs
iInf = isinf(ts.tsValue.Data);
if sum(iInf(:))>0
    ts.tsValue.Data(iInf) = NaN;
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:infindata', ts.tsValue.Name))
    warning(b_state);
end


% Check for Quality codes with missing description, and remove them 
if ~isempty(ts.tsValue.Quality) && ...
        isempty(ts.tsValue.QualityInfo.Description)
    ts.Quality = [];
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:missingqualitydesc', ts.tsValue.Name))
    warning(b_state);
end

% Reconcile the units of ts.Events with that of ts
if ~isempty(ts.tsValue.Events) && isa(ts.tsValue.Events,'tsdata.event')
    tsunits = ts.tsValue.TimeInfo.Units;
    for k = 1:length(ts.tsValue.Events)
        evunits = ts.tsValue.Events(k).Units;
        % backward compatibility
        if isempty(evunits);
            ts.tsValue.Events(k).Units = 'seconds';
            evunits = 'seconds';
        end
        if ~strcmp(tsunits,evunits)
            ts.tsValue.Events(k).Units = tsunits; 
            ts.tsValue.Events(k).Time = ...
                ts.tsValue.Events(k).Time*tsunitconv(tsunits,evunits);
            if isempty(ts.tsValue.Events(k).StartDate) || ...
                    isempty(ts.tsValue.TimeInfo.StartDate)
                ts.tsValue.Events(k).StartDate = ...
                    ts.tsValue.TimeInfo.StartDate;
            end
            b_state = warning('query','backtrace');
            warning off backtrace;
            warning(message('MATLAB:tsdata:timeseries:prepareTsDataforImport:eventunitsreconciled', ts.tsValue.Events( k ).Name, ts.tsValue.Name))
            warning(b_state);
        end
    end
end
