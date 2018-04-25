classdef (ConstructOnLoad) FiguresDropTargetEventData < event.EventData
    %FIGURESDROPTARGETEVENTDATA  Manages variable editor of the databrowser.
    %
    %   FIGURESDROPTARGETEVENTDATA tracks the number of open dialogs, and
    %   prevents openning multiple instances of a variable if it is aleady
    %   available.    
    %
    %   FIGURESDROPTARGETEVENTDATA Properties:
    %      Variables               - a cell array
    %      Workspace               - workspace of origin
    %      FigureHandle            - handle of the drop target
    %
    %   Example: 
    %       obj = matlab.ui.internal.desktop.FiguresDropTargetEventData({'a','b'},ws,hFig)
    %
    %   See also FIGURESDROPTARGETHANDLER.
    
    %   Author(s): Rong Chen
    %   Copyright 2016 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, GetAccess = public, SetAccess = public)
        % A cell array containing the variables dropped
        Variables
        
        % The workspace which is the source of the variables
        Workspace
        
        % The handle of the figure onto which the variables are dropped
        FigureHandle
    end
    
    properties (Access = private)
        Variables_
        
        Workspace_
        
        FigureHandle_
    end
    
    % ----------------------------------------------------------------------------
    methods
        function this = FiguresDropTargetEventData(varargin)
            % Creates an event data object describing figure drop target events.
            %
            % Example: obj = matlab.ui.internal.desktop.FiguresDropTargetEventData({'a','b'},ws,hFig)
            
            this.Variables = varargin{1};
            this.Workspace = varargin{2};
            this.FigureHandle = varargin{3};
        end
    end
    
    % ----------------------------------------------------------------------------
    methods
        function value = get.Variables(this)
            % GET function for Variables property.
            value = this.Variables_;
        end
        
        function set.Variables(this, value)
            % SET function for Variables property.
            this.Variables_ = value;            
        end
        
        function value = get.Workspace(this)
            % GET function for Workspace property.
            value = this.Workspace_;
        end
        
        function set.Workspace(this, value)
            % SET function for Workspace property.
            this.Workspace_ = value;
        end
        
        function value = get.FigureHandle(this)
            % GET function for FigureHandle property.
            value = this.FigureHandle_;
        end
        
        function set.FigureHandle(this, value)
            % SET function for FigureHandle property.
            this.FigureHandle_ = value;
        end
        
    end
    
end