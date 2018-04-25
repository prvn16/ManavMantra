function vq = interp1(x,v,xq,method,extrapVal)
%INTERP1 1-D interpolation on durations (table lookup)
%   Vq = interp1(X,V,Xq) interpolates to find Vq, the values of the
%   underlying function V = F(X) at the query points Xq.
%
%   X and/or V can be duration arrays. If X is a duration array, so must Xq.
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
%      dt_coarse = hours(0:24);
%      wave_coarse=sin(seconds(dt_coarse)*24./(2.*3600));
%   
%      % Create fine resolution vector (every quarter hour).
%      dt_fine = hours(0:.25:24);
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
%   See also datetime/interp1.

%   Copyright 2015 The MathWorks, Inc.

import matlab.internal.datatypes.throwInstead

narginchk(3,5); % interp1(V,Xq) is not supported

if nargin < 4, method = 'linear'; end

% Convert X and Xq to numeric if necessary
if isa(x,'duration') || isa(xq,'duration')
    try
        [x,xq] = duration.compareUtil(x,xq);
    catch ME
        throwInstead(ME,{'MATLAB:duration:InvalidComparison','MATLAB:duration:AutoConvertString'},message('MATLAB:duration:interp1:XandXqBothDurations'));
    end
end

% Convert V (and extrapVal, if given as a value) to durations if necessary
timey = isa(v,'duration') || (nargin == 5 && isa(extrapVal,'duration'));
if timey
    if nargin < 5 || strcmpi(extrapVal,'extrap')
        vqOut = v;
        v = v.millis;
    else
        try
            [v,extrapVal,vqOut] = duration.compareUtil(v,extrapVal);
        catch ME
            throwInstead(ME,{'MATLAB:duration:InvalidComparison','MATLAB:duration:AutoConvertString'},message('MATLAB:duration:interp1:VandExtrapValBothDurations'));
        end
    end
end

% Do the interpolation on (numeric) ms.
if nargin < 5
    vq = interp1(x,v,xq,method);
else
    vq = interp1(x,v,xq,method,extrapVal);
end

% Convert output to duration.
if timey
    vqOut.millis = vq;
    vq = vqOut;
end
