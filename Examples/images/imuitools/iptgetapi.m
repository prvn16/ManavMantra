function api = iptgetapi(varargin)
%IPTGETAPI Get Application Programmer Interface (API) for handle.
%   API = IPTGETAPI(H) returns the API associated with handle H if there is
%   one. Otherwise, IPTGETAPI returns an empty array.
%
%   For more information about handle APIs, see the help for IMMAGBOX, IMRECT,
%   or IMSCROLLPANEL.
%
%   Example
%   -------
%
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('tape.png');
%       hSP = imscrollpanel(hFig,hIm);
%       api = iptgetapi(hSP);
%       api.setMagnification(2) % 2X = 200%
%  
%   See also IMMAGBOX, IMRECT, IMSCROLLPANEL.

%   Copyright 1993-2007 The MathWorks, Inc.

   narginchk(1, 1);
   h = varargin{1};

   api = getappdata(h,'API');
