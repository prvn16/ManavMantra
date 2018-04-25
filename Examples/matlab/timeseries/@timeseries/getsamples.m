function tsout = getsamples(this,I)
%GETSAMPLES Obtain a subset of timeseries samples as another timeseries using a
%subscript/index array.
%
%   This operation returns a timeseries defined by the subset of timeseries
%   samples extracted based in the supplied subscript/index array.
%
%   TSOUT = GETSAMPLES(TSIN,I) returns a timeseries obtained from the samples 
%   of the timeseries TSIN corresponding to the time(s) TSIN.TIME(I).
%
%   See also TIMESERIES/GETDATASAMPLES, TIMESERIES/RESAMPLE

%   Copyright 2009-2011 The MathWorks, Inc.

if numel(this)~=1
    error(message('MATLAB:timeseries:getsamples:noarray'));
end
if isempty(I)
    tsout = timeseries;
    return;
elseif islogical(I)
    if length(I)>this.Length
        error(message('MATLAB:timeseries:getsamples:badlogicalsubscript'))
    end
    I = find(I);
elseif isnumeric(I) && isvector(I) && isreal(I)
    if this.Length==0 || any(I<1) || any(I>this.Length) || ~isequal(round(I),I)
        error(message('MATLAB:timeseries:getsamples:badsubscript'))
    end
else
    error(message('MATLAB:timeseries:getsamples:badind'));
end

% Slice data and create timeseries object
data = this.Data;
time = this.Time;
qual = this.Quality;
ind = repmat({':'},[ndims(data) 1]);
if isempty(I)
    data = [];
    time = [];
    qual = [];
elseif this.IsTimeFirst
    data = data(I,ind{2:end});
    if isvector(qual)
         qual = qual(I);
    elseif ~isempty(qual)
         qual = qual(I,ind{2:end});
    end
else
    if length(time)==1
        data = data(ind{:},I);
    else
        data = data(ind{1:end-1},I);
    end
    if isvector(qual)
        qual = qual(I);
    elseif ~isempty(qual)
        qual = qual(ind{1:end-1},I);
    end
end
time = time(I);
    
% Build the output timeseries
tsout = this;
if length(time)==1 && this.IsTimeFirst~=tsdata.datametadata.isTimeFirst(size(data),1,this.DataInfo.InterpretSingleRowDataAs3D)
    tsout = init(tsout,data,time,qual,'Name','unnamed','IsTimeFirst',...
        this.IsTimeFirst,'InterpretSingleRowDataAs3D',~this.DataInfo.InterpretSingleRowDataAs3D);
else
    tsout = init(tsout,data,time,qual,'Name','unnamed','IsTimeFirst',...
       this.IsTimeFirst,'InterpretSingleRowDataAs3D',this.DataInfo.InterpretSingleRowDataAs3D);
end

% Slice events
if ~isempty(time)
    etimes = cell2mat(get(this.Events,{'Time'}));
    I = (etimes>=time(1) & etimes<=time(end));
    if any(I)
        tsout = addevent(tsout,this.Events(I));
    end
end

