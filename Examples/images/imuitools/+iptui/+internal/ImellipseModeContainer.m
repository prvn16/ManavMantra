classdef ImellipseModeContainer < handle    
    % This undocumented class may change or be removed in a future release.
    
    % ImellipseModeContainer is a container of imellipse objects. Each
    % time a drag sequence consisting of buttondown, drag, and button up
    % completes, an additional instance of imellipse is added to the
    % property hROI. The client enables the ability to add to the container
    % by calling enableInteractivePlacement. When the client wants to stop
    % interactive placement, the client calls disableInteractivePlacement.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Access = private)
        MouseMotionCb
        ButtonUpCb
        ellipseSymbolAPI
        hFig
        hParent
        hGroup
        
        InitialPosition
        position
        
        OriginalPointerBehavior
        hTransparentOverlay
    end
    
    properties (GetAccess = public, Constant = true)
        Kind = 'Ellipse';
    end
    
    properties (SetAccess = private, SetObservable = true)
        hROI  % Handles to imellipse ROIs
    end
    
    methods
        function obj = ImellipseModeContainer(hParent)
                    
            obj.hFig = ancestor(hParent,'figure');
            obj.hParent = hParent;
            obj.hROI = imellipse.empty();
                                 
        end
        
        function disableInteractivePlacement(obj)

            iptSetPointerBehavior(obj.hTransparentOverlay, obj.OriginalPointerBehavior);
            delete(obj.hTransparentOverlay);

        end
        
        function enableInteractivePlacement(obj)
            
            % Create a transparent layer that sits on top of the HG stack
            % that grabs button down. This prevents interaction with other
            % HG objects that have button down behavior as we are placing
            % imellipse instances.
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
            ellipseSymbol = imuitoolsgate('FunctionHandle','ellipseSymbol');
            
            obj.hGroup = hggroup('Parent',obj.hParent);
            obj.ellipseSymbolAPI = ellipseSymbol();
            warning(warnstate);
            
            obj.ellipseSymbolAPI.initialize(obj.hGroup,'','','');
            colorChoices = iptui.getColorChoices();
            obj.ellipseSymbolAPI.setColor(colorChoices(1).Color);
            
            obj.MouseMotionCb = iptaddcallback(obj.hFig,'WindowButtonMotionFcn',@(~,~)  obj.ellipseDraw());
            obj.ButtonUpCb = iptaddcallback(obj.hFig,'WindowButtonUpFcn',@(~,~) obj.stopDraw());
            
            currentPoint = get(obj.hParent,'CurrentPoint');
            obj.InitialPosition = currentPoint(1,1:2);
            
            obj.ellipseDraw();
            obj.ellipseSymbolAPI.setVisible(true);
             
        end
        
        function ellipseDraw(obj)
            
            pos = obj.getCurrentPositionEllipse();
            obj.ellipseSymbolAPI.updateView(pos);
            obj.position = pos;
                         
        end
        
        function stopDraw(obj)
            
           ellipseDraw(obj); 
           
           delete(obj.hGroup);
           
           roi = imellipse(obj.hParent, obj.position);
           
           roi.setResizable(false);
           roi.setPositionConstraintFcn(@(pos)roi.getPosition());
           
           obj.hROI = roi;

           iptremovecallback(obj.hFig,'WindowButtonMotionFcn',obj.MouseMotionCb);
           iptremovecallback(obj.hFig,'WindowButtonUpFcn',obj.ButtonUpCb);
           
        end

        function pos = getCurrentPositionEllipse(obj)

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
            vertices = obj.hROI.getVertices();
            X = vertices(:,1);
            Y = vertices(:,2);
        end
    end
end
