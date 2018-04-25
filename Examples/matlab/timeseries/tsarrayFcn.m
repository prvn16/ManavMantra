function [x, nonNumericSamples] = tsarrayFcn(fcn ,time, data, len,varargin)
%
%TSARRAYFCN Utility function for processing arrays containing NaNs
%
% Utililty function used to evaluate functions of time indexed possibly NaN
% valued multi-dimensional arrays which are invariant under subindexing 
% non-time dimensions, i.e., if Y = f(X) then Y(I1,I2,...) = f(X(I(I1,I2,...)) 
% where I1,I2,... are arrays of indices not along the time dimension.
% For example in the 2 dimensional case the function f can be evaluated 
% one column at a time. If all observations are either NaN valued or
% all numeric then fcn is evaluated on the data. If some observations 
% contain NaN and numeric data the specified function is computed one column 
% at a time, excluding any NaNs in each column which may occur at
% different positions among the various columns. If the array is
% multi-dimensional, columns generalize to arrays and the functions is 
% called recursively.
%
%   Copyright 2004-2009 The MathWorks, Inc.

I = isnan(data);
nonNumericSamples = sum(I(:,:),2);

% Test whether NaN values data extends across entire samples. If so,
% then execute fcn on data
if ~any(nonNumericSamples) || (all(nonNumericSamples==size(I(:,:),2) | nonNumericSamples==0))
    x = feval(fcn{:},time,data,varargin{:});
else
    % One or more samples has NaN valued data combined with numeric
    % data. 
    s = size(data);
    x = zeros([len s(2:end)]);

    for k=1:s(2)
        if ndims(data)>=3
           % Get kth "column" - n1xn3xn4... matrix
           % coldata = data(:,k,:,:,...) with 2nd dimension compressed
           coldata = reshape(data(:,k,:),[s(1) s(3:end)]);
        else
           coldata = data(:,k);
        end
        % Recusively call this fcn to find the fcn of this "column" 
        [thiscolfcn, Jnew] = tsarrayFcn(fcn, time, coldata,len,varargin{:});
        nonNumericSamples = nonNumericSamples|Jnew; % Collect modified samples
        x(:,k,:) = reshape(thiscolfcn(:),size(x(:,k,:)));
    end
end