function imzoomin(obj,varargin)
%IMZOOMIN Interactive zoom in on scrollpanel.

%   Copyright 2004-2017 The MathWorks, Inc.

  hIm = obj;
  hScrollpanel = checkimscrollpanel(hIm,mfilename,'HIMAGE');
  apiScrollpanel = iptgetapi(hScrollpanel);

  hAx = get(obj,'parent');
  hFig = ancestor(obj, 'figure');
  
  selectionType = get(hFig,'SelectionType');
  singleClick = strcmp(selectionType, 'normal');
  doubleClick = strcmp(selectionType, 'open');  
  altKeyPressed = strcmpi(get(hFig,'CurrentModifier'),'alt');

  % initialized for function scope
  prevButtonUpFcn = [];
  prevButtonMotionFcn = [];
  
  if singleClick
    
    % Create a box showing the current zoom location.
    [x, y] = getCurrentPoint(hAx);  
    hLine = line([x x x x x], [y y y y y], ...
      'Color', [0.5 0.5 0.5], ...
      'PickableParts', 'None', ...
      'HandleVisibility', 'off', ...
      'Parent', hAx); 
  
    handleSingleClick();
    
  elseif doubleClick
    apiScrollpanel.setMagnification(apiScrollpanel.findFitMag())
  end
    
  %----------------------------------------------------------
  function handleSingleClick()

    prevButtonUpFcn = get(hFig,'WindowButtonUpFcn');
    prevButtonMotionFcn = get(hFig, 'WindowButtonMotionFcn');
    set(hFig,'WindowButtonMotionFcn', @drawRectangleWhileMoving);
    set(hFig,'WindowButtonUpFcn',@buttonReleased);

  end %handleSingleClick
  
  %----------------------------------------------------------  
  function buttonReleased(~,varargin)
      
      if altKeyPressed
          zoomOnAltClick();
      else
          % We are mimicking the behavior of rbbox.  We could not use it 
          % because it called some sort of drawnow which causes the 
          % ButtonUp Event to be fired before handleSingleClick has 
          % finished executing.  See gecks.
          
          [x2, y2] = getCurrentPoint(hAx);
          
          % Must get the current magnification and scale the rect 
          % so that it is in the right coordinates for methods on
          % apiScrollpanel.
          currentMag = apiScrollpanel.getMagnification();
          zoomRect = [0 0 abs(x2-x)*currentMag abs(y2-y)*currentMag];
          
          % This constant specifies the number of pixels the mouse
          % must move in order to do a rbbox zoom.
          % Note: same value as matlab/graphics/@graphics/@zoom/buttonupfcn2D.m
          maxPixels = 5; 
      
          tinyWidthOrHeight = any(zoomRect(3:4) < maxPixels);
          
          if tinyWidthOrHeight
              zoomOnClick();
              
          else
              [x2,y2] = getCurrentPoint(hAx);
              
              midPoint = [x+x2, y+y2] * 0.5;
              zoomOnDragRect(midPoint,zoomRect(3),zoomRect(4))      
          end
          
      end % if altKeyPressed
      
      set(hFig, 'WindowButtonUpFcn', prevButtonUpFcn);
      set(hFig, 'WindowButtonMotionFcn', prevButtonMotionFcn);
      delete(hLine)
  end

  function drawRectangleWhileMoving(~, varargin)

    [xCurrent, yCurrent] = getCurrentPoint(hAx);
    set(hLine, 'XData', [x xCurrent xCurrent x x], ...
               'YData', [y y yCurrent yCurrent y])
      
  end

  %----------------------------------------------------------
  function zoomOnDragRect(rectCenter,rectWidth,rectHeight)

    currentMag = apiScrollpanel.getMagnification();
    
    rectWidthImcoords = rectWidth / currentMag;
    rectHeightImcoords = rectHeight / currentMag;
    
    mag = apiScrollpanel.findMagnification(rectWidthImcoords,...
                                           rectHeightImcoords);
    
    apiScrollpanel.setMagnificationAndCenter(mag, rectCenter(1),rectCenter(2));
    
  end 
  
  %----------------------------------------------------------  
  function zoomOnClick
    newMag = images.internal.findZoomMag('in',apiScrollpanel.getMagnification());
    apiScrollpanel.setMagnificationAndCenter(newMag,x,y)   
  end

  %----------------------------------------------------------
  function zoomOnAltClick
  % If the Alt key is pressed, zoom-out is performed
    newMag = images.internal.findZoomMag('out',apiScrollpanel.getMagnification());
    apiScrollpanel.setMagnificationAndCenter(newMag,x,y) 
  end

end %imzoomin
