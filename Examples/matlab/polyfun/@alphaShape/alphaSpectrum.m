% alphaSpectrum  Sorted vector of alpha values giving distinct shapes
% As = alphaSpectrum(SHP) returns the sorted alpha values, largest to 
%    smallest, that produce distinct alpha shapes. The output As is a vector 
%    whose length Ns is the number of uniquely representable shapes. Each 
%    element in As corresponds to the value of the alpha radius that produces 
%    a change in shape. Alpha values I in the open interval As(j) < I < As(j+1), 
%    with 0 < j < Ns, do not produce a change in the alpha shape.
%
%    Example 1:
%    % Create an alpha shape from a set of points in the plane and query
%    % the alpha spectrum.
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Create an alphaShape from the set of points.
%      shp = alphaShape(x,y)
%      alphaspec = alphaSpectrum(shp);
%      % The number of distince alpha shapes is
%      numel(alphaspec)
%      % Observing the alpha spectrum, any value of alpha in the range 
%      % 7.4 to 14.6 produces the same shape.
%      figure
%      shp.Alpha = 14.6
%      plot(shp)  
%
%      shp.Alpha = 10
%      plot(shp)  % No change
%
%      shp.Alpha = 7.4
%      plot(shp)  % No change
%
%      shp.Alpha = 7.0
%      plot(shp)  % Changed: The alpha value dropped below a shape band in 
%                 % the spectrum.
%
%
%    See also alphaShape, alphaShape.Alpha, alphaShape.plot.

% Copyright 2013-2014 The MathWorks, Inc.