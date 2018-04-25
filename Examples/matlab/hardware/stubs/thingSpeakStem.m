function thingSpeakStem(varargin)
%THINGSPEAKSTEM Discrete sequence or "stem" plot.
%   THINGSPEAKSTEM(Y) plots the data sequence Y as stems from the x axis
%   terminated with circles for the data value. If Y is a matrix then
%   each column is plotted as a separate series.
%
%   THINGSPEAKSTEM(X,Y) plots the data sequence Y at the values specified
%   in X.
%
%   THINGSPEAKSTEM(...,'filled') produces a stem plot with filled markers.
%
%   THINGSPEAKSTEM(...,'LINESPEC') uses the color specified for the stems and
%   markers.

%   Copyright 2015-2016 The MathWorks, Inc.


runFromFolder = pwd;
finishup = onCleanup(@() cd(runFromFolder));

% Check if the mltbx has been installed
try
   tsfcncallrouter('thingSpeakStem', varargin);
catch err
    throwAsCaller(err);
end