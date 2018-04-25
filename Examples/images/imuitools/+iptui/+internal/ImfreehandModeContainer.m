classdef ImfreehandModeContainer < handle    
    % This undocumented class may change or be removed in a future release.
    
    % imfreehandModeContainer is a container of imfreehand objects. Each
    % time a drag sequence consisting of buttondown, drag, and button up
    % completes, an additional instance of imfreehand is added to the
    % property hROI. The client enables the ability to add to the container
    % by calling enableInteractivePlacement. When the client wants to stop
    % interactive placement, the client calls disableInteractivePlacement.
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    properties (Access = private)
        MouseMotionCb
        ButtonUpCb
        freehandSymbolAPI
        hFig
        hParent
        hGroup
        
        OriginalPointerBehavior
        hTransparentOverlay

        position
    end
    
    properties (GetAccess = public, Constant = true)
        Kind = 'Freehand';
    end
    
    properties (SetAccess = private, SetObservable = true)
        hROI  % Handles to imfreehand ROIs
    end
    
    methods
        function obj = ImfreehandModeContainer(hParent)
                    
            obj.hFig = ancestor(hParent,'figure');
            obj.hParent = hParent;
            obj.hROI = imfreehand.empty();
                                 
        end
        
        function disableInteractivePlacement(obj)

            iptSetPointerBehavior(obj.hTransparentOverlay, obj.OriginalPointerBehavior);
            delete(obj.hTransparentOverlay);

        end
        
        function enableInteractivePlacement(obj)
            
            % Create a transparent layer that sits on top of the HG stack
            % that grabs button down. This prevents interaction with other
            % HG objects that have button down behavior as we are placing
            % freehand instances.
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
                       
            obj.MouseMotionCb = iptaddcallback(obj.hFig,'WindowButtonMotionFcn',@(~,~)  obj.freehandDraw());
            obj.ButtonUpCb = iptaddcallback(obj.hFig,'WindowButtonUpFcn',@(~,~) obj.stopDraw());
            
            warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
            freehandSymbol = imuitoolsgate('FunctionHandle','freehandSymbol');
            
            obj.hGroup = hggroup('Parent',obj.hParent);
            obj.freehandSymbolAPI = freehandSymbol();
            warning(warnstate);
            
            obj.freehandSymbolAPI.initialize(obj.hGroup);
            obj.freehandSymbolAPI.setVisible(true);
            colorChoices = iptui.getColorChoices();
            obj.freehandSymbolAPI.setColor(colorChoices(1).Color);
            
            currentPoint = get(obj.hParent,'CurrentPoint');
            currentX = currentPoint(1,1);
            currentY = currentPoint(1,2);
            
            obj.position = [currentX currentY];
            
            obj.freehandSymbolAPI.updateView(obj.position);
             
        end
        
        function freehandDraw(obj)
            
            currentPoint = get(obj.hParent,'CurrentPoint');
            currentX = currentPoint(1,1);
            currentY = currentPoint(1,2);
            
            obj.position(end+1,:) = [currentX currentY];
            
            obj.freehandSymbolAPI.updateView(obj.position);
                         
        end
        
        function stopDraw(obj)
            
           freehandDraw(obj); 
           obj.freehandSymbolAPI.setClosed(true);
           
           delete(obj.hGroup);
           
           obj.hROI(end+1) = imfreehand(obj.hParent,obj.position);

           iptremovecallback(obj.hFig,'WindowButtonMotionFcn',obj.MouseMotionCb);
           iptremovecallback(obj.hFig,'WindowButtonUpFcn',obj.ButtonUpCb);
           
        end
        
        function[X, Y] = getPolygonPoints(obj)
            X = obj.position(:,1);
            Y = obj.position(:,2);
        end
    end
end
