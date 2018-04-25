function [SampleSize,varargout] = getdatasamplesize(this) 
%GETDATASAMPLESIZE  Return the size of each data sample for a time series object
%
%   Example:
% 
%   Create a time series object:
%   ts=timeseries(rand(5,1))
%
%   Get the data sample size for this object:
%   getdatasamplesize(ts)
%
%   Copyright 2005-2011 The MathWorks, Inc.

if numel(this)~=1
    error(message('MATLAB:timeseries:getdatasamplesize:noarray'));
end

% Empty timeseries
if this.Length==0 || isequal(this.Data,[])
    SampleSize = [];
    varargout = repmat({[]},[1,nargout-1]);
    return
end

% Initialize size vectors
if nargout>=2
    QualSampleSize = size(this.Quality);
end
SampleSize = size(this.Data);

if this.IsTimeFirst
    % 2d case, 1st dim is always 1 or the sample size would be scalar
    if length(SampleSize)==2
        SampleSize(1) = 1;
    % >2d case, remove the 1st dimension (time)
    else
        SampleSize = SampleSize(2:end);
    end
    
    if nargout>=2
        if length(QualSampleSize)==2
            if min(QualSampleSize)==0
                QualSampleSize = {};
            else
                QualSampleSize(1) = 1;
            end
        else
            QualSampleSize = QualSampleSize(2:end);
        end   
        varargout{1} = QualSampleSize;
    end
else
    % size(..Data,end) will not be 1 for a length 1 timeseries where
    % IsTimeFirst == false
    if this.Length==1 
        SampleSize = [SampleSize 1];
    end
    SampleSize = SampleSize(1:end-1);
    if nargout>=2
        if length(QualSampleSize)==2
            if min(QualSampleSize)==0
                QualSampleSize = {};
            else
                QualSampleSize(1) = 1;
            end
        else
            QualSampleSize = QualSampleSize(1:end-1);
        end   
        varargout{1} = QualSampleSize;
    end
end
    