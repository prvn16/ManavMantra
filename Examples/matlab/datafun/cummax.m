%CUMMAX Cumulative largest component.
%   Y = CUMMAX(X) computes the cumulative largest component of X along
%   the first non-singleton dimension of X. Y is the same size as X.
% 
%   Y = CUMMAX(X,DIM) cumulates along the dimension specified by DIM.
% 
%   Y = CUMMAX(___,DIRECTION) cumulates in the direction specified by
%   DIRECTION using any of the above syntaxes:
%     'forward' - (default) uses the forward direction, from beginning to end.
%     'reverse' -           uses the reverse direction, from end to beginning.
%
%   Y = CUMMAX(___,NANFLAG) specifies how NaN (Not-A-Number) values are treated.
%   'omitnan'    - (default) ignores all NaN values and returns the maximum of the 
%                            non-NaN elements. If all values are NaN, the
%                            result is NaN.
%   'includenan' -           returns NaN if any value is NaN.
%
%   If X is complex, CUMMAX compares the magnitude of the elements of X.
%   In the case of equal magnitude elements, the phase angle is also used.
%
%   Example: 
%       X = [0 4 3; 6 5 2]
%       cummax(X,1)
%       cummax(X,2)
%       cummax(X,1,'reverse')
%       cummax(X,2,'reverse')
%
%   See also MAX, MOVMAX, CUMMIN, CUMSUM, CUMPROD.

%   Copyright 1984-2016 The MathWorks, Inc.

%   Built-in function.

