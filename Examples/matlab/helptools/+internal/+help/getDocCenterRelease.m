function release = getDocCenterRelease()
%% This function used by  MATLAB Connector in support of Help Data Service
%  getting Doc Center doc release. 
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%   Copyright 2016 The MathWorks, Inc.
    release = char(com.mathworks.mlservices.MLHelpServices.getDocRelease);
end