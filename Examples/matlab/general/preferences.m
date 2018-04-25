function preferences(varargin)
%PREFERENCES Bring up MATLAB user settable preferences dialog.
%   PREFERENCES opens up general MATLAB preferences.  
% 
%   PREFERENCES COMPONENT displays general MATLAB preferences with the
%   specified component name selected.
%
%   Examples:
%      preferences
%         displays MATLAB user settable preferences dialog
%
%      preferences('Editor/Debugger')
%         displays Editor user settable preferences
%

%   Copyright 1984-2007 The MathWorks, Inc.

%preferences('ComponentName')
% if no swing, error
error(javachk('swing', mfilename));
com.mathworks.mlservices.MLPrefsDialogServices.showPrefsDialog(varargin{:});
