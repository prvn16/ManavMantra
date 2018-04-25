function varNames = defaultVariableNames(varIndices)
% DEFAULTVARIABLENAMES returns variable names consistent with tabular default convension

%   Copyright 2016-2017 The MathWorks, Inc.

varNames = matlab.internal.tabular.private.varNamesDim.dfltLabels(varIndices);