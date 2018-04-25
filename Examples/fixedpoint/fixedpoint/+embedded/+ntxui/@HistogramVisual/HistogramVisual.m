classdef HistogramVisual < matlabshared.scopes.visual.Visual
% HISTOGRAMVISUAL Classdef for Histogram visualization
    
% Copyright 2017 The MathWorks, Inc.
    
    properties (Access = protected)
        NewDataListener
        SourceListeners
        ViewMenuOpeningListener
    end
    
    properties (Hidden)
        NTExplorerObj
        ConnectedSourceName
        ConnectedSourcePort
        InputNeedsValidation = true;
    end
    
    methods
        function this = HistogramVisual(varargin)
            % HISTOGRAMVISUAL Construct a HistogramVisual object
            
            % Copyright 2009-2010 The MathWorks, Inc.
            
            this@matlabshared.scopes.visual.Visual(varargin{:});
            hApp = this.Application;
            this.SourceListeners = [ ...
                addlistener(hApp, 'SourceRun', @(h, ev) resetVisual(this)) ...
                addlistener(hApp, 'DataSourceChanged', @(h,ev) onDataSourceChanged(this)) ...
                addlistener(hApp, 'DataLoadedEvent', @(h, ev)enableGUI(this,ev));
                ];
        end
        
        function ax = getAxesContainers(this)
            
            ax = {struct('Axes',this.NTExplorerObj.hHistAxis)};
            %ax = [];
        end
    end
    
    methods (Access = protected)
        gui = createGUI(this)
    end
    
    methods (Static)
        setPosition(hparent);
    end
end
