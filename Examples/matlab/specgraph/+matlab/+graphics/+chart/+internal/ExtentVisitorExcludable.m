
%   Copyright 2010-2015 The MathWorks, Inc.

classdef (                   AllowedSubclasses={?matlab.graphics.chart.primitive.FunctionLine})ExtentVisitorExcludable < handle
    % This class provides the ExtentVisitorExcludable interface which
    % enables class such as FunctionLine to exclude themselves from from
    % the peer extent calculation performed in the getXYZExtents method in
    % matlab.graphics.chart.internal.ChartHelpers.getChildExtentsWithExclusion
end
    
