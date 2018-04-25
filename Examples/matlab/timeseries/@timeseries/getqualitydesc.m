function out = getqualitydesc(this)
%GETQUALITYDESC  Return data quality descriptions based on the Quality
% values assigned to a time series object
%
%   Example:
% 
%   Create a time series object:
%   ts = timeseries(rand(5,1),1:5,[1;0;1;0;1]);
%
%   Set QualityInfo:
%   ts.QualityInfo.Code = [0 1];
%   ts.QualityInfo.Description = {'good' 'bad'};
%
%   Get the data quality strings for this object:
%   getqualitydesc(ts)
%

%   Copyright 2005-2011 The MathWorks, Inc.

if numel(this)~=1
    error(message('MATLAB:timeseries:getqualitydesc:noarray'));
end
if this.Length==0
    out = {};
    return
end
out = num2cell(this.Quality);
if ~isempty(this.Quality)
    for i=1:numel(this.Quality)
        [validcode,index] = ismember(out{i},this.QualityInfo.code);
        if validcode && index<=numel(this.Qualityinfo.Description)
            out(i) = this.Qualityinfo.Description(index);
        else
            error(message('MATLAB:timeseries:getqualitydesc:nodesc'));
        end
    end
end
