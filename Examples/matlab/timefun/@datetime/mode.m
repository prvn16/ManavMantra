function [m,f,c] = mode(a,dim)
%MODE Most frequent datetime value.
%   M = MODE(T), when T is a vector of datetimes, computes M as the sample mode,
%   or most frequently occurring value in T.  When T is a matrix, MODE(T) is a
%   row vector containing the mode of each column.  For N-D arrays, MODE(T) is
%   the mode of the elements along the first non-singleton dimension of T.
%   
%   When there are multiple values occurring equally frequently, MODE returns
%   the smallest of those values.
%   
%   [M,F] = MODE(T) also returns an array F, of the same size as M. Each element
%   of F is the number of occurrences of the corresponding element of M.
%   
%   [M,F,C] = MODE(T) also returns a cell array C, of the same size as M.  Each
%   element of C is a sorted vector of all the values having the same frequency
%   as the corresponding element of M.
%  
%   [...] = MODE(T,DIM) takes the mode along the dimension DIM of T.
%   
%   This function is most useful with discrete or coarsely rounded data. The
%   mode for a continuous probability distribution is defined as the peak of its
%   density function.  Applying the mode function to a sample from that
%   distribution is unlikely to provide a good estimate of the peak; it would be
%   better to compute a histogram or density estimate and calculate the peak of
%   that estimate.  Also, the mode function is not suitable for finding peaks in
%   distributions having multiple modes.
%
%   Example:
%
%       % Create a vector of datetimes and find the most common (mode)
%       % datetime.
%       dts = [datetime('1995-10-01 02:45 PM'),...
%              datetime('08/23/2010 16:35'),...
%              datetime('August 23, 2010 4:35 PM'),...
%              datetime('-44-03-15 00:00'),...
%              datetime('21-Oct-2015 12:01:00')]
%
%       mode(dts)
%
%   See also MEAN, MEDIAN, STD.

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isScalarInt

aData = a.data;
if nargin < 2
    needDim = true; % let the core functions handle this case
else
    needDim = false;
    if ~isScalarInt(dim,1)
        error(message('MATLAB:datetime:InvalidDim'));
    end
end

% Because of the way complex sorts by default (on the magnitude, then the
% angle), if the datetimes have high precision and there are multiple tied
% values, the built-in mode will actually return the datetime closest to 1970
% rather than the earliest. Fix that by looking at the third output when any
% of the data have a low-order part and are pre-1970.
getThirdOutput = ~isreal(aData(:)) && any(aData(:) < 0); % < only looks at real part

if nargout < 3 && ~getThirdOutput
    if needDim
        [mData,f] = mode(aData);
    else
        [mData,f] = mode(aData,dim);
    end
else
    if needDim
        [mData,f,c] = mode(aData);
    else
        [mData,f,c] = mode(aData,dim);
    end
    for i = 1:numel(c)
        c_i_data = c{i};
        if ~isscalar(c_i_data) && any(c_i_data < 0) % only sort if necessary
            c_i_data = sort(c_i_data,'ComparisonMethod','real'); % sort as double-doubles
            mData(i) = c_i_data(1); % return smallest double-double
        end
        c_i = a;
        c_i.data = c_i_data;
        c{i} = c_i;
    end
end
m = a;
m.data = mData;
