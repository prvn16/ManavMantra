function thingSpeakPlotYY(varargin)
%THINGSPEAKPLOTYY Graphs with y tick labels on the left and right
%
%   THINGSPEAKPLOTYY(X1,Y1,X2,Y2) plots Y1 versus X1 with y-axis labeling
%   on the left and plots Y2 versus X2 with y-axis labeling on
%   the right.

%   Copyright 2015-2016 The MathWorks, Inc.

runFromFolder = pwd;
finishup = onCleanup(@() cd(runFromFolder));

% Check if the mltbx has been installed
try
    tsfcncallrouter('thingSpeakPlotYY', varargin);
catch err
    throwAsCaller(err);
end