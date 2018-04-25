classdef ImpolyModeContainer < handle    
    % This undocumented class may change or be removed in a future release.
    
    % ImpolyModeContainer is a container of impoly objects. Each time an
    % interactive placement gesture of impoly is completed, an additional
    % instance of impoly is added to the property hROI. The client enables
    % the ability to add to the container by calling
    % enableInteractivePlacement. When the client wants to stop interactive
    % placement, the client calls disableInteractivePlacement.
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    properties (Access = private)
        ButtonDownEvt
        MouseMotionCB
        polygonSymbolAPI
        pointSymbolAPI
        hFig
        hParent
        hGroup
        hFirstVertex
        
        position

        hTransparentOverlay
    end
    
    properties (GetAccess = public, Constant = true)
        Kind = 'Polygon';
    end
    
    properties (SetAccess = private, SetObservable = true)
        hROI  % Handles to imfreehand ROIs
    end
    
    methods (Access = private)
        function initializeInteractivePolygonView(obj)
            
            warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
            polygonSymbol = imuitoolsgate('FunctionHandle','polygonSymbol');
            
            obj.hGroup = hggroup('Parent',obj.hTransparentOverlay);
            obj.polygonSymbolAPI = polygonSymbol();
            warning(warnstate);
            
            obj.polygonSymbolAPI.initialize(obj.hGroup);
            obj.polygonSymbolAPI.setVisible(true);
            colorChoices = iptui.getColorChoices();
            obj.polygonSymbolAPI.setColor(colorChoices(1).Color);
            
        end
        
        function removeInteractivePolygonView(obj)
            
            delete(obj.hGroup);
            obj.position = [];
            obj.hFirstVertex = iptui.impolyVertex.empty();
            
        end
        
        function addVertex(obj,evt)
            
            if ~isequal(ancestor(evt.HitObject,'axes'),obj.hTransparentOverlay)
                % If ButtonDown happened outside bounds of parent axes,
                % ignore click gesture
                return
            end
                            
            doubleClick = strcmp(get(obj.hFig,'SelectionType'),'open');
            rightClick = strcmp(get(obj.hFig,'SelectionType'),'alt');
            clickedOnFirstVertex = ~isempty(obj.hFirstVertex) &&...
                isequal(evt.HitObject,findobj(obj.hFirstVertex,'type','hggroup'));
            
            if (rightClick || doubleClick) && isempty(obj.position)
                % Don't allow right or double termination until at least
                % one vertex has been selected.
                return
            end
            
            
            if rightClick || doubleClick || clickedOnFirstVertex
                                
                % Store position before removing the polygon graphics.
                pos = obj.position;
                
                % Remove the graphics objects used to interactively draw
                % the polygon.
                obj.removeInteractivePolygonView();

                % Reinitialize the polygon view for
                % drawing the next polygon interactively.
                obj.initializeInteractivePolygonView();
                
                % Add the completed impoly instance to the hROI container.
                obj.hROI(end+1) = impoly(obj.hParent,pos);

                return
            end


            currentPoint = get(obj.hParent,'CurrentPoint');
            currentX = currentPoint(1,1);
            currentY = currentPoint(1,2);
            
            obj.position = [obj.position; currentX currentY];
            hVertex = iptui.impolyVertex(obj.hGroup,currentX,currentY);

            firstVertexPlaced = size(obj.position,1) == 1;
            if firstVertexPlaced
                obj.hFirstVertex = hVertex;
                iptSetPointerBehavior(hVertex,@(hFig,evt) set(hFig,'Pointer','circle'));
            end
                        
            obj.polygonSymbolAPI.updateView(obj.position);
            
        end
        
        function animateConnectionLine(obj)
            
            % Draw a line that connects the last placed vertex with the
            % current position of the mouse in the axes coordinate system.
            currentPoint = get(obj.hParent,'CurrentPoint');
            obj.polygonSymbolAPI.updateView([obj.position; currentPoint(1,1:2)]);
                        
        end
    end
    
    methods
        function obj = ImpolyModeContainer(hParent)
                    
            obj.hFig = ancestor(hParent,'figure');
            obj.hParent = hParent;
            obj.hROI = impoly.empty();
            obj.position = [];
                                 
        end
        
        function disableInteractivePlacement(obj)

            delete(obj.ButtonDownEvt);
            iptremovecallback(obj.hFig,'WindowButtonMotionFcn',obj.MouseMotionCB);

            delete(obj.hTransparentOverlay);


        end
        
        function enableInteractivePlacement(obj)
           
            % Create a transparent layer that sits on top of the HG stack
            % that grabs button down. This prevents interaction with other
            % HG objects that have button down behavior as we are placing
            % polygon instances. 
            obj.hTransparentOverlay = axes('Parent',get(obj.hParent,'Parent'),...
                'Units',get(obj.hParent,'Units'),'Position',get(obj.hParent,'Position'),...
                'Visible','off','HitTest','on',...
                'XLim',get(obj.hParent,'XLim'),'YLim',get(obj.hParent,'YLim'),...
                'YDir',get(obj.hParent,'YDir'));
            
            % Update the Position of the transparent overlay to follow the
            % scroll panel axes (hParent). The scroll panel axes moves when
            % there is a zoom/pan event during interactive placement,
            % causing a misalignment of the overlay and the scroll panel
            % axes. The following ensures that whenever the position of the
            % hParent changes, the position of hTransparentOverlay gets
            % updated.
            funcUpdatePosition = @(hobj,evt)set(obj.hTransparentOverlay,'Position',get(obj.hParent,'Position'));
            
            positionChangedListener = event.proplistener(obj.hParent,...
                obj.hParent.findprop('Position'),'PostSet',funcUpdatePosition);
            
            % Associate the listener with the transparent overlay, so that
            % its life time coincides with that of the transparent overlay.
            setappdata(obj.hTransparentOverlay,'PostSetListener',positionChangedListener);
            
            obj.ButtonDownEvt = event.listener(obj.hFig,'WindowMousePress',@(hobj,evt) obj.addVertex(evt));
            
            uistack(obj.hTransparentOverlay,'top');
            
            obj.hTransparentOverlay.PickableParts = 'all';
            
            iptPointerManager(obj.hFig);
            iptSetPointerBehavior(obj.hTransparentOverlay,@(~,~) set(obj.hFig,'Pointer','crosshair'));
            obj.MouseMotionCB = iptaddcallback(obj.hFig,'WindowButtonMotionFcn',@(hobj,evt) obj.animateConnectionLine());
            obj.initializeInteractivePolygonView();
            
        end
        
        function[X, Y] = getPolygonPoints(obj)
            vertices = obj.hROI.getPosition();
            X = vertices(:,1);
            Y = vertices(:,2);
        end
    end
end
