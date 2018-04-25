function varargout = deploytool(varargin)

% Copyright 2016 The MathWorks, Inc.

% mcc/deployment workflow not supported on MATLAB Online
nse = connector.internal.notSupportedError;
nse.throwAsCaller;
