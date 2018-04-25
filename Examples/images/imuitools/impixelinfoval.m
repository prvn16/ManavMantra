function huic = impixelinfoval(parent,himage)
%IMPIXELINFOVAL Pixel Information tool without text label.
%   HTEXT = IMPIXELINFOVAL(HPARENT,HIMAGE) creates a pixel information tool in
%   HPARENT that provides information about the pixels in the image specified by
%   HIMAGE. HPARENT is a handle to a figure or uipanel object.  HIMAGE can be a
%   handle to an image or an array of image handles.
%
%   The pixel information tool displays information about the pixel in an image
%   that the cursor is positioned over. The tool displays pixel information for
%   all the images in a figure.
%
%   When created with IMPIXELINFO, the tool is a uipanel object, positioned in
%   the lower-left corner of the figure, that contains the text label "Pixel
%   Info:" followed by the x and y coordinates of the pixel and its
%   value. When created with IMPIXELINFOVAL, the tool is a uicontrol object
%   positioned in the lower-left corner of the figure, that displays the pixel
%   information without the text label.
%
%   The pixel information provided varies, depending on the image type. See
%   IMPIXELINFO for more information.
%
%   Note
%   ----    
%   To copy the pixel information string to the clipboard, right-click while the
%   cursor is positioned over a pixel. In the context menu, choose Copy pixel
%   info.
%
%   Example
%   -------
%       ankle = dicomread('CT-MONO2-16-ankle.dcm');
%       h = imshow(ankle,[]);
%       hText= impixelinfoval(gcf,h);
%       set(hText,'FontWeight','bold')
%       set(hText,'FontSize',10)
%
%   See also IMPIXELINFO.

%   Copyright 2004-2014 The MathWorks, Inc.

iptcheckhandle(parent,{'figure','uipanel','uicontainer'},mfilename, ...
   'HPARENT',1);
checkImageHandleArray(himage,mfilename);

[himage,axesHandles,hFig] = imhandles(himage);

huic = uicontrol('Parent',parent,...
   'Style','text',...
   'Units','pixels',...
   'HorizontalAlignment','left',...
   'BusyAction','queue',...
   'enable', 'inactive',...
   'Interruptible','off',...
   'Visible','off',...
   'DeleteFcn',@deleteFcn,...
   'Tag','pixelinfo text');

iptui.internal.setChildColorToMatchParent(huic,parent);

% declare so they will have scope in nested functions
imageModels = getimagemodel(himage);
xystring = '(X, Y)';
twoSpaces = '  ';
oneSpace = ' ';
stringForMultipleImages = getString(...
    message('images:impixelinfovalUIString:stringForMultipleImages'));

is_rset = strcmp(get(himage(1),'tag'),'rset overview');

% create Context menu
cmenu = uicontextmenu('Parent', hFig);
set(himage, 'UIContextMenu', cmenu);         
menuItemHandle = uimenu(cmenu,...
   'Label',getString(message('images:impixelinfovalUIString:copyMenuLabel')), ...
   'Callback',@copyPixInfoToClipboard,...
   'Tag','Copy pixel info menu item');

   %---------------------------------------
   function copyPixInfoToClipboard(obj,evt) %#ok<INUSD>
      clipboard('copy', pixelString);
   end

callbackID = iptaddcallback(hFig,'WindowButtonMotionFcn', @displayPixelInfo);
reactToImageChangesInFig(himage,huic,@reactDeleteFcn,@reactRefreshFcn);
registerModularToolWithManager(huic,himage);


   %-------------------------------
   function reactDeleteFcn(obj,evt) %#ok<INUSD>
      if ishghandle(huic)
         delete(huic);
      end
   end


   %-------------------------------
   function reactRefreshFcn(obj,evt) %#ok<INUSD>
       imageModels = getimagemodel(himage);
       displayPixelInfo();
   end


   %--------------------------
   function deleteFcn(obj,evt) %#ok<INUSD>

      iptremovecallback(hFig,'WindowButtonMotionFcn',callbackID);
      if ishghandle(cmenu)
         delete(cmenu);
      end
      if ishghandle(menuItemHandle)
         delete(menuItemHandle);
      end

   end


   %---------------------------------
   function displayPixelInfo(obj,evt) %#ok<INUSD>
     
       [index,x,y] = findAxesThatTheCursorIsOver(axesHandles);
       him = himage(index);

       if isempty(him) || isCursorOutsideVisibleImage(him,x,y)
           % if we are not over an image...
           displayDefaultString;
       
       elseif strcmp(get(him,'tag'),'rset overview')
           % if we are over an rset overview image...
           createXString = @(x) sprintf('%1d', round(x));
           createYString = createXString;
           pixelString = sprintf('(%s,%s%s)', ...
               createXString(x), ...
               oneSpace, ...
               createYString(y));
           set(huic,'String',pixelString);
           
       else
           % else display pixel info string as usual
           [nrows,ncols,~] = size(get(him,'Cdata'));
           if nrows == 0 || ncols == 0
               displayDefaultString;
             
           else
               [isXDataDefault,isYDataDefault] = isDefaultXYData(him);
               xdata = get(him,'XData');
               ydata = get(him,'YData');
               
               if isXDataDefault && isYDataDefault
                   createXString = @(x) sprintf('%1d', round(x));
                   createYString = createXString;

               else
                   createXString = @(x) sprintf('%1.2f', x);
                   createYString = createXString;

                   isXDataTheSame = isscalar(xdata);
                   isYDataTheSame = isscalar(ydata);
                   if isXDataTheSame
                     createXString = @(x) sprintf('%1.2f', xdata(1));
                   end
                   
                   if isYDataTheSame
                     createYString = @(y) sprintf('%1.2f', ydata(1));
                   end
               end

               % Construct pixel value string
               imModel = imageModels(index);
               rp = axes2pix(nrows,ydata,y);
               cp = axes2pix(ncols,xdata,x);
               r = min(nrows,max(1,round(rp)));
               c = min(ncols,max(1,round(cp)));

               valueString = getPixelInfoString(imModel,r,c);

               pixelString = sprintf('(%s,%s%s)%s%s', ...
                                     createXString(x), ...
                                     oneSpace, ...
                                     createYString(y), ...
                                     twoSpaces, ...
                                     valueString);
               set(huic,'String',pixelString);
           end
       end

       %----------------------------
       function displayDefaultString

           if numel(himage) ~= 1
               defaultPixelInfoString = stringForMultipleImages;
           elseif is_rset
               defaultPixelInfoString = '';
           else
               defaultPixelInfoString = getDefaultPixelInfoString(imageModels);
           end
           pixelString = sprintf('%s%s%s',xystring,twoSpaces, ...
               defaultPixelInfoString);
           set(huic,'String',pixelString);
       end

   end % displayPixelInfo

   % Set position of string so that it could fit the largest pixel value.
   % Turn pixel reporting on by default, after resetting hPixelInfoValue's
   % string to ''.
   set(huic,'String','(0000,0000) [0.00E+00 0.00E+00 0.00E+00]');
   pixInfoExtent = matlab.ui.internal.PositionUtils.getDevicePixelExtent(huic);
   fudge = 2;
   posPixInfoValue = [1 1 pixInfoExtent(3)+3*fudge pixInfoExtent(4)];
   matlab.ui.internal.PositionUtils.setDevicePixelPosition(huic,posPixInfoValue);
   pixelString = sprintf('%s%s%s',xystring,twoSpaces, stringForMultipleImages);
   set(huic,'String',pixelString);
   set(huic,'Visible','on');

end % impixelinfoval


%--------------------------------------------------------
function isOutside = isCursorOutsideVisibleImage(him,x,y)

hSp = imshared.getimscrollpanel(him);

if isempty(hSp)
    isOutside = false;

else
    api = iptgetapi(hSp);
    rect = api.getVisibleImageRect();
    xmin = rect(1);
    ymin = rect(2);
    width = rect(3);
    height = rect(4);
    outsideRect = x < xmin || x > xmin + width || y < ymin || y > ymin ...
        + height;
    if outsideRect
        isOutside = true;
    else
        isOutside = false;
    end
end

end % isCursorOutsideVisibleImage
