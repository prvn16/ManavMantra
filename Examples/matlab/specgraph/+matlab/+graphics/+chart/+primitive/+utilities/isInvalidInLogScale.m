function invalid_values = isInvalidInLogScale(varargin)
%isInvalidInLogScale locates the invalid data values in log scale 
% 
%  isInvalidInLogScale(scale, limits, data) returns a logical array the
%  same size as the input data and containing true values for those data
%  elements which can be transformed by a dataspace that is using the given
%  scale and limits.  The scale must be one of the strings 'linear' or
%  'log' and the limits must be a two element vector containing a lower and
%  upper limit.
%
%  isInvalidInLogScale(hProvider, ScaleName, LimsName, data, invalid) applies
%  the same algorithm but accepts an object that provides the scale and
%  limits in properties, with names defined by ScaleName and LimtsName.
%  The invalid input specifies which data points are already considered
%  invalid and do not need further testing.   This form of the function is
%  useful when the limits are expensive to provide, as it defers their
%  request until after the scale is checked.

%  Copyright 2012-2013 The MathWorks, Inc.

% If the dataspace is log: 
%   1. If the limits cross into the positive half of the axis, negative and 
%      zero values are invalid.
%   2. If no positive limits are present, zero and positive values are
%      invalid.


if nargin==3
    invalid_values = basicImpl(varargin{:});
else
    invalid_values = providerImpl(varargin{:});
end


function invalid_values = basicImpl(scale, lims, data)
if strcmp(scale, 'log')
    if any(lims>0)
        % Negative data is not displayed in these axes
        invalid_values = (data<=0);
    else
        % Positive data is not displayed in these axes
        invalid_values = (data>=0);
    end
else
    % All data is valid
    invalid_values = false(size(data));
end


function invalid_values = providerImpl(hProvider, ScaleProp, LimsProp, data, invalid_values)

if strcmp(hProvider.(ScaleProp), 'log')
    if any(hProvider.(LimsProp)>0)
        % Negative data is not displayed in these axes
        invalid_values(~invalid_values) = (data(~invalid_values)<=0);
    else
        % Positive data is not displayed in these axes
        invalid_values(~invalid_values) = (data(~invalid_values)>=0);
    end
end
