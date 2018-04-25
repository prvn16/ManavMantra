function out = openmlappinstall(filename)
%OPENMLAPPINSTALL   Install MATLAB App.  Helper function
%   for OPEN.
%
%   See OPEN.

%   Copyright 2012 The MathWorks, Inc. 

if nargout, out = []; end
appManagementApiBuilder = com.mathworks.appmanagement.AppManagementApiBuilder;
appManagementApi = appManagementApiBuilder.getAppManagementApi;
appManagementApi.installAsynchronously(filename)

