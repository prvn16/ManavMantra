classdef (Sealed) FiguresDropTargetHandler < handle
    % FIGURESDROPTARGETHANDLER  Manages DropTarget registration and event
    % notification for Figures (except UI figures).
    %
    %   FIGURESDROPTARGETHANDLER holds information about figures that are
    %   designated as DropTarget(s). Additionally, it generates events
    %   with information about the variables names, workspace, and figure
    %   being affected and having 'VariablesBeingDropped' event.
    %
    %   FIGURESDROPTARGETHANDLER Methods:
    %      registerInterest        - register interest
    %      unregisterInterest      - unregister interest
    %
    %   Register interest in drop events for the figure
    %     hdlr = matlab.ui.internal.desktop.FiguresDropTargetHandler;
    %     hdlr.registerInterest(hFig);
    %
    %   Listen to the event 'VariablesBeingDropped' on the handler object hdlr
    %     lsnr = addlistener(hdlr, 'VariablesBeingDropped', @dropTargetCallback );
    %
    %   where dropTargetCallback is something you provide. An example for
    %   dropTargetCallback is the following one:
    %
    %     function dropTargetCallback(src,data)
    %       ws = data.Workspace;
    %       varnames = data.Variables;
    %       hfig = data.FigureHandle;
    %       ax = hfig.CurrentAxes;
    %       hold(ax,'on');
    %       bode(ax, ws.evalin(varnames{1}));
    %     end
    %
    %   See also FIGURESDROPTARGETEVENTDATA.
    
    %   Author(s): Rong Chen
    %   Copyright 2016 The MathWorks, Inc.
    
    %% ------ PROPERTIES
    properties (Access = public)
        % List of listeners to DropTarget events
        DropListeners
        
        % List of listeners to figure close events
        CloseListeners
    end
    
    %% ------ EVENTS
    events
        % Event broadcasted when dropping to a figure is recognized
        VariablesBeingDropped
    end
    
    %% ------ CONSTRUCTION
    methods (Access = public)
        
        % Constructor
        function this = FiguresDropTargetHandler(varargin)
            % FIGURESDROPTARGETHANDLER  Constructor of the handler object.
        end
        
    end
    
    %% ------ User Facing
    methods (Access = public)
        
        function registerInterest(this, hFig)
            % REGISTERINTEREST  Register interest in drop target events.
            %
            %   REGISTERINTEREST(obj,HFIG) register interest in drop events
            %   on the figure handle HFIG.
            %
            %   See also UNREGISTERINTEREST.

            % Get Figure's Java Frame
            jf = javaGetFigureFrame(hFig);

            % Get FigureCanvas
            fCanvas = jf.getAxisComponent;

            % Create a Drop listener
            javaListener = javaObjectEDT('com.mathworks.mlwidgets.toolgroup.FigureDropTargetListener');
            java.awt.dnd.DropTarget(fCanvas,javaListener);
            cb = javaListener.getEventsToMATLAB;
            droplsnr = handle.listener(handle(cb),'delayed', {@this.dropCallback, hFig} );
            this.DropListeners = [this.DropListeners; droplsnr];

            % Create a listener to figure close events
            addCloseListener(this, hFig)
        end
        
        function unregisterInterest(this,hFig)
            % UNREGISTERINTEREST  Unregister interest in drop target events.
            %
            %   UNREGISTERINTEREST(obj,HFIG) performs cleanup operations by
            %   removing the figure handle and its drop listener.
            %
            %   See also REGISTERINTEREST.
            tmp = [];
            for i=1:numel(this.CloseListeners)
                tmp = [tmp; this.CloseListeners(i).Source{1}]; %#ok<AGROW>
            end
            equals = eq(hFig,tmp);
            this.CloseListeners(equals) = [];
            this.DropListeners(equals) = [];
        end
    end
    
    methods (Access = private)
        
        function addCloseListener(this, hFig)
            % Do not modify. Use as is to prevent Java memory leaks.
            closelsnr = event.listener(hFig, 'ObjectBeingDestroyed', ...
                @this.closeCallback);
            this.CloseListeners = [this.CloseListeners; closelsnr];
        end
        
        function dropCallback(this,eventSource,eventData,hFig) %#ok<INUSL>
            % DROPCALLBACK  Notifies listeners with drop data.
            %
            %   DROPCALLBACK(OBJ,SRC,DATA,HFIG) notifies listeners of the
            %   figure handle, workspace, and variables names associated
            %   with a particular drop operation.
            %
            %   See also CLOSECALLBACK.
            sourceGC = handle(eventData.JavaEvent.graphicalcomponent);

            if ~isempty(sourceGC)
                % Variables dropped from Data Browser workspaces
                ws = sourceGC.getModel;
                varnames = cell(eventData.JavaEvent.selected_variables);
            else
                % Simple variables dropped from base MATLAB workspace
                svd = eventData.JavaEvent.simplevariabledefinitions;
                ws = 'base';
                varnames = cell(length(svd),1);
                for i = 1:length(svd)
                    varnames{i} = char(svd(i).getVariable);
                end
            end

            % Notify listeners to this object of a Portchanged event
            notify(this,'VariablesBeingDropped', matlab.ui.internal.desktop.FiguresDropTargetEventData(varnames,ws,hFig));
        end
        
        function closeCallback(this,hFig,eventData) %#ok<INUSD>
            % CLOSECALLBACK  performs cleanup following a figure closure.
            %
            %   CLOSECALLBACK(OBJ,HFIG,DATA) removes the figure and its
            %   listeners from being tracked by this object.
            %
            %   See also DROPCALLBACK.
            this.unregisterInterest(hFig);
        end
        
    end
    
end

%% Local helper functions
function javaFrame = javaGetFigureFrame(f)
    % Make sure the figure is valid.
    if isempty(f) || ~ishandle(f)
        javaFrame = [];
        return
    end

    hWarn = ctrlMsgUtils.SuspendWarnings('MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); %#ok<NASGU>
    javaFrame = get(f,'JavaFrame');
end
