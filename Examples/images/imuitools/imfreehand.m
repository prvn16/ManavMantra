%IMFREEHAND Create draggable freehand region.
%   H = IMFREEHAND begins interactive placement of a freehand region of
%   interest on the current axes. The function returns H, a handle to an
%   imfreehand object.
%
%   A freehand region of interest can be dragged interactively using the
%   mouse.
%   
%   The freehand region has a context menu associated with it that allows
%   you to copy the current position to the clipboard and change the color
%   used to display the freehand region. Right-click on the freehand region
%   to access this context menu.
%
%   H = IMFREEHAND(HPARENT) begins interactive placement of a freehand
%   region of interest on the object specified by HPARENT. HPARENT
%   specifies the HG parent of the freehand region graphics, which is
%   typically an axes but can also be any other object that can be the
%   parent of an hggroup.
%
%   H = IMFREEHAND(...,PARAM1,VAL1,PARAM2,VAL2,...) creates a freehand
%   region, specifying parameters and corresponding values that control the 
%   behavior of the freehand region. Parameter names can be abbreviated,
%   and case does not matter
%    
%   Parameters include:
%    
%   'Closed'                       A scalar logical that controls whether the 
%                                  freehand region is closed. True creates a 
%                                  closed freehand region. False creates an open 
%                                  freehand region.
%       
%   'PositionConstraintFcn'        Function handle fcn that is called whenever
%                                  the freehand region is dragged using the mouse.
%                                  Type "help imfreehand/setPositionConstraintFcn"
%                                  for information on valid function handles.
%
%   Methods
%   -------
%   Type "methods imfreehand" to see a list of the methods.
%
%   For more information about a particular method, type 
%   "help imfreehand/methodname" at the command line.
%
%   Remarks
%   -------    
%   If you use IMFREEHAND with an axis that contains an image object, and
%   do not specify a position constraint function, users can drag the
%   freehand region outside the extent of the image and lose the freehand
%   region.  When used with an axis created by the PLOT function, the axis
%   limits automatically expand to accommodate the movement of the freehand
%   region.
%
%   To cancel the interactive placement press the escape key. IMFREEHAND
%   will return an empty object.
%    
%   Example 1
%   ---------    
%   Interactively place a closed freehand region of interest by clicking and
%   dragging over an image.
% 
%   figure, imshow('pout.tif');
%   h = imfreehand(gca);
%
%   Example 2
%   ---------
%   Interactively place a freehand region by clicking and dragging. Use
%   wait to block the MATLAB command line. Double-click on the freehand
%   region to resume execution of the MATLAB command line.
%
%   figure, imshow('pout.tif');
%   h = imfreehand;
%   position = wait(h);      
%
%   See also  IMELLIPSE, IMLINE, IMPOINT, IMPOLY, IMRECT, IPTGETAPI, makeConstrainToRectFcn.

%   Copyright 2007-2017 The MathWorks, Inc.

classdef imfreehand < imroi
       
    methods
       
        function obj = imfreehand(varargin)
            %imfreehand  Constructor for imfreehand.

            [h_group,draw_api] = imfreehandAPI(varargin{:});
            obj = obj@imroi(h_group,draw_api);

        end
        
        function pos = getPosition(obj)
            %getPosition  Return current position of freehand region.
            %
            %   pos = getPosition(h) returns the current position of the
            %   freehand region h. The returned position, pos, is an N-by-2
            %   array [X1 Y1;...;XN YN].
            
            pos = obj.api.getPosition();
            
        end
                
        function setClosed(obj,TF)
            %setClosed  Set geometry of freehand region.
            %
            %   setClosed(h,TF) sets the geometry of the freehand region h.
            %   TF is a logical scalar. True means that the freehand region
            %   is closed. False means that the freehand region is open.

            obj.api.setClosed(TF);
            
        end
               
    end
     
end


function [h_group,draw_api] = imfreehandAPI(varargin)
    

  [commonArgs,specificArgs] = roiParseInputs(0,2,varargin,mfilename,{'Closed'});
  
  xy_position_vectors_specified = (nargin > 2) && ...
                                  isnumeric(varargin{2}) && ...
                                  isnumeric(varargin{3});
  
  if xy_position_vectors_specified
      error(message('images:impoly:invalidPosition'))
  end

  position              = commonArgs.Position;
  interactive_placement = commonArgs.InteractivePlacement;
  h_parent              = commonArgs.Parent;
  h_axes                = commonArgs.Axes;
  h_fig                 = commonArgs.Fig;
 
  is_closed = specificArgs.Closed;
    
  stop_draw_id = [];
  draw_id = [];
  
  positionConstraintFcn = commonArgs.PositionConstraintFcn;
  if isempty(positionConstraintFcn)
      % constraint_function is used by dragMotion() to give a client the
      % opportunity to constrain where the point can be dragged.
      positionConstraintFcn = identityFcn;
  end
 
  try
    h_group = hggroup('Parent', h_parent,'Tag','imfreehand');
  catch ME 
    error(message('images:imfreehand:invalidHandle'))
  end
  
  draw_api = freehandSymbol();
  basicPolygonAPI = basicPolygon(h_group,draw_api,positionConstraintFcn);
  
  % Create function handle aliases for basicPolygonAPI methods used within
  % imfreehand.
  setClosed                 = basicPolygonAPI.setClosed;
  setPosition               = basicPolygonAPI.setPosition;
  getPosition               = basicPolygonAPI.getPosition;
  
  % Used to stop interactive placement for any buttonDown or buttonUp event
  % after user left clicks the first time.
  placementStarted = false;
 
  if interactive_placement
      
      placement_aborted = manageInteractivePlacement(h_axes,h_group,@placeFreehand);
      if placement_aborted
          h_group = [];
          return;
      end
      
  else
      setPosition(position);
  end
  
  setClosed(is_closed);
  draw_api.setVisible(true);
      
  cmenu = [];
  cmenu = createROIContextMenu(h_fig,getPosition,@setColor);
  setContextMenu(cmenu);
  
  set(h_group,'DeleteFcn',@deleteContextMenu)

  % Create API for imfreehand
  api.getPosition               = getPosition;
  api.setClosed                 = setClosed;
  api.delete                    = basicPolygonAPI.delete;
  api.addNewPositionCallback    = basicPolygonAPI.addNewPositionCallback; 
  api.removeNewPositionCallback = basicPolygonAPI.removeNewPositionCallback;
  api.getPositionConstraintFcn  = basicPolygonAPI.getPositionConstraintFcn;
  api.setPositionConstraintFcn  = basicPolygonAPI.setPositionConstraintFcn;
  api.setColor                  = @setColor;
  
  % Undocumented API methods.
  api.setContextMenu = @setContextMenu;
  api.getContextMenu = @getContextMenu;

  iptsetapi(h_group,api);
        
  %-----------------------
  function setColor(color)
      if ishghandle(getContextMenu())
        updateColorContextMenu(getContextMenu(),color);
      end
      draw_api.setColor(matlab.images.internal.stringToChar(color));
  end
  
  %--------------------------------- 
  function setContextMenu(cmenu_new)
    
     cmenu_obj = findobj(h_group,'Type','line','-or','Type','patch');
     set(cmenu_obj,'uicontextmenu',cmenu_new);
      
     cmenu = cmenu_new;
     
  end
  
  %-------------------------------------
  function context_menu = getContextMenu
     
      context_menu = cmenu;
  
  end
  
  %----------------------------------- 
  function deleteContextMenu(varargin)
      if ishghandle(cmenu)
          delete(cmenu);
      end
  end
  
  %------------------------------------------------
  function completed = placeFreehand(init_x,init_y)
	
      isLeftClick = strcmp(get(h_fig, 'SelectionType'), 'normal');
      if ~isLeftClick
          if ~placementStarted
              completed = false;
          else
              stopDrag();
              completed = true;
              placementStarted = false;
          end
          return
      end
      
      placementStarted = true;
      
	  setPosition([init_x,init_y]);
      
      draw_api.setVisible(true);
	 	  
      draw_id = iptaddcallback(h_fig,'WindowButtonMotionFcn',@freehandDraw);
	  stop_draw_id = iptaddcallback(h_fig,'WindowButtonUpFcn',@stopDrag);      
      % Pointer manager will revert pointer behavior back to previous state once
      % placeFreehand has fired. Want to continue displaying crosshair
      % pointer until freehand placement has finished. Disable pointer
      % manager and re-enable once placement of freehand region has
      % completed.
	  iptPointerManager(h_fig,'Disable');
	  set(h_fig,'Pointer','crosshair');
      
      % endOnButtonUp specified as true to manageInteractivePlacement. placement
      % not complete until buttonUp event occurs.
      completed = false;
	  
	  %------------------------------
	  function freehandDraw(varargin)
		 
		  [x,y] = getCurrentPoint(h_axes);
          candidate_pos = [ getPosition(); x,y ];
          new_pos = positionConstraintFcn(candidate_pos);
          
          setPosition(new_pos);
		  
	  end %freehandDrag
	  
	  %--------------------------
	  function stopDrag(varargin)
		 
          iptremovecallback(h_fig,'WindowButtonMotionFcn',draw_id);
		  iptremovecallback(h_fig,'WindowButtonUpFcn',stop_draw_id);

		  setClosed(is_closed);
          
          % Re-enable pointer management now that placement of freehand region is
          % complete.
          iptPointerManager(h_fig,'Enable');
          		  		  
	  end %stopDrag
	  	  
  end %placeFreehand
            
end %imfreehand

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function imroi
    
    
    
    
    
