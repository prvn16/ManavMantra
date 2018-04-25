function thingSpeakArea(varargin)
%THINGSPEAKAREA  Filled area plot.
%   THINGSPEAKAREA(X,Y) produces a stacked area plot suitable for showing the
%   contributions of various components to a whole.
%
%   For vector X and Y, THINGSPEAKAREA(X,Y) is the same as THINGSPEAKPLOT(X,Y) except that
%   the area between 0 and Y is filled.  When Y is a matrix, THINGSPEAKAREA(X,Y)
%   plots the columns of Y as filled areas.  For each X, the net
%   result is the sum of corresponding values from the columns of Y.
%
%   THINGSPEAKAREA(Y) uses the default value of X=1:SIZE(Y,1).
%
%   THINGSPEAKAREA(...,'Prop1',VALUE1,'Prop2',VALUE2,...) sets the specified
%   properties of the area plot.

%   Copyright 2015-2016 The MathWorks, Inc.

runFromFolder = pwd;
finishup = onCleanup(@() cd(runFromFolder));

% Check if the mltbx has been installed
try
    tsfcncallrouter('thingSpeakArea', varargin);    
catch err
    throwAsCaller(err);
end