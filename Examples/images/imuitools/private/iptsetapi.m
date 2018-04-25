function iptsetapi(h,api)
%IPTSETAPI Set Application Programmer Interface (API) for handle.
%   IPTSETAPI(H,API) Sets the API associated with handle H.
%
%   Example
%   -------
%
%   hFig = figure;
%   hAx = axes;
%   h_group = hggroup('Parent',hAx);
%   api.setAxesColor = @(colorSpec) set(hAx,'Color',colorSpec);
%   iptsetapi(h_group,api)
%   api = iptgetapi(h_group);
%    
%   See also IPTGETAPI.

%   Copyright 2006 The MathWorks, Inc.


    setappdata(h,'API',api);
