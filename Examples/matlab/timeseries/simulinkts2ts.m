function ts = simulinkts2ts(this)
%
% tstool utility function
%   Copyright 2005-2006 The MathWorks, Inc.

% Initialize the object
ts = timeseries(this.Data,this.Time,'IsTimeFirst',this.IsTimeFirst,'Name',...
    this.Name);
ts.TimeInfo.StartDate = this.TimeInfo.StartDate;
ts.TimeInfo.Units = this.TimeInfo.Units;
ts.QualityInfo.Code = this.QualityInfo.Code;
ts.QualityInfo.Description = this.QualityInfo.Description;
ts.TreatNaNasMissing = this.TreatNaNasMissing;
ts.DataInfo.Units = this.DataInfo.Units;
ts.DataInfo.Interpolation = this.DataInfo.Interpolation;
ts.Events = this.Events;
ts.Quality = this.Quality;

