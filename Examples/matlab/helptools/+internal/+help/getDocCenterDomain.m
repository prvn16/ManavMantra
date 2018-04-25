function domain = getDocCenterDomain()
%% This function used by  MATLAB Connector in support of Help Data Service
%  getting Doc Center web service endpoint. 
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%   Copyright 2016 The MathWorks, Inc.
    domain = char(com.mathworks.mlservices.MLHelpServices.getDocCenterDomain);
end