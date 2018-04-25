
%   Copyright 2013-2015 The MathWorks, Inc.

classdef PlotYYListenerManager < handle
    properties (SetAccess = private, GetAccess = private)
        Axes1
        Axes2
    end
    
    properties (SetAccess = private, GetAccess = private, Transient)
        LinkProp
        PositionListener
    end
    
    properties (SetAccess = private, GetAccess = private)
        % When this property is set during deserialization, it will trigger the creation of the listeners
        % It is important that this property be declared last in the classdef to make sure
        % that the rest of the class has been properly restored before creating the listeners
        ListenersAdded = false;
    end
    
    methods
        function this = PlotYYListenerManager(a1, a2)
            this = this@handle;
            this.Axes1 = a1;
            this.Axes2 = a2;
            
            % setting ListenersAdded to true will trigger the creation of the listeners
            this.ListenersAdded = true;
            setappdata(a1, 'PlotYYListenerManager', this);
        end
        
        function set.ListenersAdded(this, val)
            if ~this.ListenersAdded && val
                this.ListenersAdded = true;
                addListeners(this);
            end
        end
    end
    
    methods (Access = private)
        function addListeners(this)
            ax(1) = handle(this.Axes1);
            ax(2) = handle(this.Axes2);
            this.LinkProp = linkprop(ax,'View');
            p1 = findprop(ax(1),'Position');
            p2 = findprop(ax(1),'OuterPosition');
            this.PositionListener = event.proplistener(handle(ax),{p1,p2},...
                                                        'PostSet',@(obj,evd)(matlab.graphics.internal.PlotYYListenerManager.UpdatePosition(obj, evd, ax)));
        end
    end
    
    methods (Static, Access = private)
        function UpdatePosition(~,evd,axList)
            axSource = evd.AffectedObject;
            axDest = axList(axList~=axSource);
            if (all(ishghandle(axList)))
                hFig = ancestor(axSource,'Figure');
                newPos = get(axSource,'Position');
                newDestPos = hgconvertunits(hFig,newPos,get(axSource,'Units'),get(axDest,'Units'),get(axSource,'Parent'));
                set(axDest,'Position',newDestPos);
                set(axSource,'ActivePositionProperty','position');
            end
        end
    end
end

