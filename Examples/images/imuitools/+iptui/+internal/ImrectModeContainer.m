classdef ImrectModeContainer < handle    
    % This undocumented class may change or be removed in a future release.
    
    % imrectModeContainer is a container of imrect objects. Each
    % time a drag sequence consisting of buttondown, drag, and button up
    % completes, an additional instance of imrect is added to the
    % property hROI. The client enables the ability to add to the container
    % by calling enableInteractivePlacement. When the client wants to stop
    % interactive placement, the client calls disableInteractivePlacement.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Access = private)
        MouseMotionCb
        ButtonUpCb
        rectSymbolAPI
        hFig
        hParent
        hGroup
        
        InitialPosition
        position
        
        OriginalPointerBehavior
        hTransparentOverlay
    end
    
    properties (GetAccess = public, Constant = true)
        Kind = 'Rectangle';
    end
    
    properties (SetAccess = private, SetObservable = true)
        hROI  % Handles to imrect ROIs
    end
    
    methods
        function obj = ImrectModeContainer(hParent)
                    
            obj.hFig = ancestor(hParent,'figure');
            obj.hParent = hParent;
            obj.hROI = imrect.empty();
                                 
        end
        
        function disableInteractivePlacement(obj)

            iptSetPointerBehavior(obj.hTransparentOverlay, obj.OriginalPointerBehavior);
            delete(obj.hTransparentOverlay);

        end
        
        function enableInteractivePlacement(obj)
            
            % Create a transparent layer that sits on top of the HG stack
            % that grabs button down. This prevents interaction with other
            % HG objects that have button down behavior as we are placing
            % imrect instances.
            obj.hTransparentOverlay = axes('Parent',get(obj.hParent,'Parent'),...
                'Units',get(obj.hParent,'Units'),'Position',get(obj.hParent,'Position'),...
                'Visible','off','HitTest','on','ButtonDownFcn',@(hobj,evt) obj.beginDraw());
           
            iptPointerManager(obj.hFig);
            obj.OriginalPointerBehavior = iptGetPointerBehavior(obj.hTransparentOverlay);
            iptSetPointerBehavior(obj.hTransparentOverlay,@(~,~) set(obj.hFig,'Pointer','crosshair'));
            
            obj.hTransparentOverlay.PickableParts = 'all';
            uistack(obj.hTransparentOverlay,'top');
                        
        end
        
        function beginDraw(obj)
                       
            warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
            rectSymbol = imuitoolsgate('FunctionHandle','wingedRect');
            
            obj.hGroup = hggroup('Parent',obj.hParent);
            obj.rectSymbolAPI = rectSymbol();
            warning(warnstate);
            
            obj.rectSymbolAPI.initialize(obj.hGroup,'','','');
            colorChoices = iptui.getColorChoices();
            obj.rectSymbolAPI.setColor(colorChoices(1).Color);
            
            obj.MouseMotionCb = iptaddcallback(obj.hFig,'WindowButtonMotionFcn',@(~,~)  obj.rectDraw());
            obj.ButtonUpCb = iptaddcallback(obj.hFig,'WindowButtonUpFcn',@(~,~) obj.stopDraw());
            
            currentPoint = get(obj.hParent,'CurrentPoint');
            obj.InitialPosition = currentPoint(1,1:2);
            
            obj.rectDraw();
            obj.rectSymbolAPI.setVisible(true);
             
        end
        
        function rectDraw(obj)
            
            initial_position = obj.getCurrentPositionRect();
            obj.rectSymbolAPI.updateView(initial_position);
            obj.position = initial_position;
                         
        end
        
        function stopDraw(obj)
            
           rectDraw(obj); 
           
           delete(obj.hGroup);
           
           roi = imrect(obj.hParent, obj.position);
           
           roi.setResizable(false);
           roi.setPositionConstraintFcn(@(pos)roi.getPosition());
           
           obj.hROI = roi;

           iptremovecallback(obj.hFig,'WindowButtonMotionFcn',obj.MouseMotionCb);
           iptremovecallback(obj.hFig,'WindowButtonUpFcn',obj.ButtonUpCb);
           
        end

        function pos = getCurrentPositionRect(obj)

            currentPoint = get(obj.hParent, 'CurrentPoint');
            current_x = currentPoint(1,1);
            current_y = currentPoint(1,2);

            initialPosition = obj.InitialPosition;
            init_x = initialPosition(1,1);
            init_y = initialPosition(1,2);

            w = abs(current_x - init_x);
            h = abs(current_y - init_y);

            x = min(current_x,init_x);
            y = min(current_y,init_y);

            pos = [x y w h];

        end
        
        function[X, Y] = getPolygonPoints(obj)
            pos = obj.hROI.getPosition();
            
            xStart = pos(1);
            yStart = pos(2);
            width = pos(3);
            height = pos(4);
            X = [xStart, xStart + width, xStart + width, xStart];
            Y = [yStart, yStart, yStart + height, yStart + height];
        end
    end
end
