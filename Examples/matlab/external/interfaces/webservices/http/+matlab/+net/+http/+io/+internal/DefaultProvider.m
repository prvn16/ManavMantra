classdef (Sealed) DefaultProvider < matlab.net.http.io.ContentProvider
% DefaultProvider A ContentProvider with empty methods
%   This class is used to populate an empty array of ContentProviders.
    
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2017 The MathWorks, Inc.
    methods 
        function getData(~)
        end
    end
end