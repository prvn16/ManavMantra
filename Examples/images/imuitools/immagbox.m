function h = immagbox(varargin)
%IMMAGBOX Magnification box for scroll panel.
%   HBOX = IMMAGBOX(HPARENT,HIMAGE) creates a Magnification box for the
%   image displayed in a scroll panel created by IMSCROLLPANEL. HPARENT
%   is a handle to the figure or uipanel object that will contain the
%   magnification box. HIMAGE is a handle to the target image (the image
%   in the scroll panel). IMMAGBOX returns HBOX, which is a handle to 
%   the Magnification box uicontrol object.
%
%   A Magnification box is an editable text box uicontrol that contains
%   the current magnification of the target image. When you enter a new
%   value in the magnification box, the magnification of the target 
%   image changes.  When the magnification of the target image changes
%   for any reason, the magnification box updates the magnification value.
% 
%   API Function Syntaxes
%   ---------------------
%   A magnification box contains a structure of function handles,
%   called an API. You can use the functions in this API to manipulate
%   magnification box. To retrieve this structure, use the IPTGETAPI
%   function.
%
%       api = iptgetapi(HBOX)
%
%   Functions in the API, listed in the order they appear in the structure,
%   include:
%
%   setMagnification
%
%       Sets the magnification in units of screen pixels per image pixel.
%
%           api.setMagnification(new_mag) 
%
%       where new_mag is a scalar magnification factor. Multiply new_mag by
%       100 to get percent magnification. For example if you call
%       api.setMagnification(2), the magnification box will show the string
%       '200%.'
%
%   Example
%   -------
%    
%       hFig = figure('Toolbar','none',...
%                     'Menubar','none');
%       hIm = imshow('pears.png'); 
%       hSP = imscrollpanel(hFig,hIm);
%       set(hSP,'Units','normalized',...
%               'Position',[0 .1 1 .9])
%
%       hMagBox = immagbox(hFig,hIm);
%       pos = get(hMagBox,'Position');
%       set(hMagBox,'Position',[0 0 pos(3) pos(4)])
% 
%       % Change scroll panel mag and notice mag box updates
%       apiSP = iptgetapi(hSP);
%       apiSP.setMagnification(2)
%
%   See also IMSCROLLPANEL, IPTGETAPI.

%   Copyright 2003-2006 The MathWorks, Inc.
%   

  narginchk(2, 2);
  parent = varargin{1};
  himage = varargin{2};
  
  iptcheckhandle(parent,{'figure','uipanel','uicontainer'},mfilename,'HPARENT',1)
  iptcheckhandle(himage,{'image'},mfilename,'HIMAGE',2)
  
  hScrollpanel = checkimscrollpanel(himage,mfilename,'HIMAGE');
  apiScrollpanel = iptgetapi(hScrollpanel);

  h = uicontrol('Style','edit',...
                'BackgroundColor','w',...
                'Callback',@updateMag,...
                'Parent',parent);

  % initialize mag
  updateMagString(apiScrollpanel.getMagnification())
  
  % Give scroll panel a hook to update the mag box when mag changes
  apiScrollpanel.addNewMagnificationCallback(@setMagnification);
  
  % Allow other objects to tell the magnification box that the
  % magnification of its associated scroll panel has changed.
  api.setMagnification = @setMagnification;  
  iptsetapi(h,api)
  
  %----------------------------
  function updateMag(src,event)
  
    % The magnification stored in the scroll panel is treated as the "truth."
    origMag = apiScrollpanel.getMagnification();
    
    [newMag, isStringTypedValid] = parseMagString(src,origMag);
  
    if (isStringTypedValid)
       apiScrollpanel.setMagnification(newMag);
    end

    % Always update string, even if just to restore what was there before
    % bogus typing. 
    updateMagString(newMag)
       
  end 
  
  %-------------------------------   
  function updateMagString(newMag)
    
    set(h,'String',sprintf('%s%%',num2str(100*newMag)))
    
  end

  %----------------------
  function setMagnification(newMag)

    validateattributes(newMag,{'numeric'},...
                  {'real','scalar','nonempty','nonnan','finite',...
                   'positive','nonsparse'},'setMagnification','newMag',1)
    
    updateMagString(newMag)
    
  end
  
end

%----------------------------------------------------------------
function [newMag, isStringTypedValid] = parseMagString(src,origMag)

  s = get(src,'String');
  num = sscanf(s,'%f%%');

  if isempty(num) || ~isfinite(num) || num==0
      newMag = origMag;
      isStringTypedValid = false;
  else
      newMag = abs(num/100);
      isStringTypedValid = true;
  end

end
