function vq = interp1(x,v,xq,method,extrapVal)
%INTERP1 1-D interpolation on datetimes (table lookup)
%   Vq = interp1(X,V,Xq) interpolates to find Vq, the values of the
%   underlying function V = F(X) at the query points Xq.
%
%   X and/or V can be datetime arrays. If X is a datetime array, so must Xq.
%
%   X must be a vector. The length of X is equal to N.
%   If V is a vector, V must have length N, and Vq is the same size as Xq.
%   If V is an array of size [N,D1,D2,...,Dk], then the interpolation is
%   performed for each D1-by-D2-by-...-Dk value in V(i,:,:,...,:). If Xq
%   is a vector of length M, then Vq has size [M,D1,D2,...,Dk]. If Xq is 
%   an array of size [M1,M2,...,Mj], then Vq is of size
%   [M1,M2,...,Mj,D1,D2,...,Dk].
%
%   Interpolation is the same operation as "table lookup".  Described in
%   "table lookup" terms, the "table" is [X,V] and interp1 "looks-up"
%   the elements of Xq in X, and, based upon their location, returns
%   values Vq interpolated within the elements of V.
%
%   Vq = interp1(X,V,Xq,METHOD) specifies the interpolation method.
%   The available methods are:
%
%     'linear'   - (default) linear interpolation
%     'nearest'  - nearest neighbor interpolation
%     'next'     - next neighbor interpolation
%     'previous' - previous neighbor interpolation
%     'spline'   - piecewise cubic spline interpolation (SPLINE)
%     'pchip'    - shape-preserving piecewise cubic interpolation
%     'cubic'    - same as 'pchip'
%     'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                  extrapolate and uses 'spline' if X is not equally
%                  spaced.
%
%   Vq = interp1(X,V,Xq,METHOD,'extrap') uses the interpolation algorithm
%   specified by METHOD to perform extrapolation for elements of Xq outside
%   the interval spanned by X.
%
%   Vq = interp1(X,V,Xq,METHOD,EXTRAPVAL) replaces the values outside of the
%   interval spanned by X with EXTRAPVAL.  NaN and 0 are often used for
%   EXTRAPVAL.  The default extrapolation behavior with four input arguments
%   is 'extrap' for 'spline' and 'pchip' and EXTRAPVAL = NaN for the others.
%
%   Example:
%
%      % Construct a sine wave as a function of time and then interpolate
%      % it to a finer time resolution.
%
%      % Create a vector of hourly datetimes and corresponding data values.
%      dt_coarse = datetime(2015,11,5,0:1:24,0,0);
%      wave_coarse=sin(datenum(dt_coarse)*24./2);
%   
%      % Create fine resolution vector (every 15 minutes).
%      dt_fine = datetime(2015,11,5,0,0:15:60*24,0);
%   
%      % Interpolate coarse data to fine time resolution.
%      wave_fine = interp1(dt_coarse,wave_coarse,dt_fine,'pchip');
%   
%      % Plot the coarse and fine resolution data.
%      % Note that time is automatically shown on the x axis.
%      plot(dt_coarse,wave_coarse,'*-')
%      hold on
%      plot(dt_fine,wave_fine,'o-')
%      hold off
%
%   See also duration/interp1.

%   Copyright 2015 The MathWorks, Inc.

import matlab.internal.datetime.datetimeAdd
import matlab.internal.datetime.datetimeMean
import matlab.internal.datetime.datetimeSubtract
import matlab.internal.datatypes.throwInstead

narginchk(3,5); % interp1(V,Xq) is not supported

if nargin < 4
    method = 'linear';
elseif isa(method,'datetime')
    % Let interp1 handle a common mistake, interp1(X,V,Xq,EXTRAPVAL)
    method = char(method);
end

% If X and Xq are datetimes, convert them to numeric after making sure they're
% compatible. Either can be datetime strings if the other is datetimes.
if isa(x,'datetime') || isa(xq,'datetime')
    try
        [x,xq] = datetime.compareUtil(x,xq);
    catch ME
        throwInstead(ME,'MATLAB:datetime:InvalidComparison',message('MATLAB:datetime:interp1:XandXqBothDatetimes'));
    end
    % Convert to double precision offsets from the mean x location
    x0 = datetimeMean(x(:),1,false); % x0 = mean(x,'includenan')
    x = datetimeSubtract(x,x0); % x = milliseconds(x - x0)
    xq = datetimeSubtract(xq,x0); % xq = milliseconds(xq - x0)
end

% If V (and extrapVal, if given as a value) are datetimes, convert them to
% numeric after making sure they're compatible. Either can be datetime
% strings if the other is datetimes.
timey = isa(v,'datetime') || (nargin > 4 && isa(extrapVal,'datetime'));
if timey
    if nargin < 5 || strcmpi(extrapVal,'extrap')
        vqOut = v; % use as a template for the output
        v0 = datetimeMean(v.data(:),1,false); % v0 = mean(v(:),'includenan')
        v = datetimeSubtract(v.data,v0,true); % v = milliseconds(v - v0), full precision
        haveLowOrder = ~isreal(v) && nnz(imag(v)) > 0;
        if haveLowOrder
            vLow = imag(v); v = real(v);
            extrapValLow = 0; % Extrapolate using zero for interp1(...,'extrap')
        end
    else
        try
            [v,extrapVal,vqOut] = datetime.compareUtil(v,extrapVal);
        catch ME
            throwInstead(ME,'MATLAB:datetime:InvalidComparison',message('MATLAB:datetime:interp1:VandExtrapValBothDatetimes'));
        end
        v0 = datetimeMean(v(:),1,false); % v0 = mean(v(:),'includenan')
        v = datetimeSubtract(v,v0,true); % v = milliseconds(v - v0), full precision
        extrapVal = datetimeSubtract(extrapVal,v0,true); % extrapVal = milliseconds(extrapVal - v0)
        haveLowOrder = (~isreal(v) && nnz(imag(v)) > 0) ...
                    || (~isreal(extrapVal) && nnz(imag(extrapVal)) > 0);
        if haveLowOrder
            vLow = imag(v); v = real(v);
            extrapValLow = imag(extrapVal); extrapVal = real(extrapVal);
        end
    end
end

% Do the interpolation on (numeric) ms since 1970. If there's a low-order part,
% do linear interpolation on that separately, to be added in later. This makes
% querying the original x data return exactly the original v data.
if nargin < 5
    vq = interp1(x,v,xq,method);
    if timey && haveLowOrder
        % Extrapolate the low-order part using zero for interp1(x,v,xq,method),
        % otherwise it would end up as NaN for 'linear' and others.
        vqLow = interp1(x,vLow,xq,'linear',0);
    end
else % interp1(...,'extrap') or interp1(...,extrapVal)
    vq = interp1(x,v,xq,method,extrapVal);
    if timey && haveLowOrder
        vqLow = interp1(x,vLow,xq,'linear',extrapValLow);
    end
end

% Convert output to datetime.
if timey
    if haveLowOrder
        vq = datetimeAdd(vq,vqLow); % vq = milliseconds(vq + vqLow)
    end
    % Add back the datetime "origin"
    vqOut.data = datetimeAdd(v0,vq); % vq = v0 + milliseconds(vq)
    vq = vqOut;
end
