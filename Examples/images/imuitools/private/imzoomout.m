function imzoomout(obj,eventdata)
%IMZOOMOUT Interactive zoom out on scrollpanel.

%   Copyright 1993-2014 The MathWorks, Inc.

  hIm = obj;
  hScrollpanel = checkimscrollpanel(hIm,mfilename,'HIMAGE');
  apiScrollpanel = iptgetapi(hScrollpanel);

  hAx = get(obj,'parent');
  hFig = ancestor(obj, 'figure');

  pt = get(hAx,'CurrentPoint');
  x = pt(1,1);
  y = pt(1,2);

  singleClick = strcmp(get(hFig, 'SelectionType'), 'normal');
  doubleClick = strcmp(get(hFig, 'SelectionType'), 'open');  
  altKeyPressed = strcmpi(get(hFig,'CurrentModifier'),'alt');
  
  if singleClick
    
    if altKeyPressed
      direction = 'in'; 
    else
      direction = 'out';
    end

    newMag = images.internal.findZoomMag(direction,apiScrollpanel.getMagnification());
    apiScrollpanel.setMagnificationAndCenter(newMag,x,y)
    
  elseif doubleClick
      apiScrollpanel.setMagnification(apiScrollpanel.findFitMag())
  end
      
end
  
