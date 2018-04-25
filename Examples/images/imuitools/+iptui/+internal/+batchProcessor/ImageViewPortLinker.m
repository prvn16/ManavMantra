classdef ImageViewPortLinker < handle
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties(SetAccess=private)
        hAllAxes = [];
        Busy     = false;
    end
    
    properties
        Enable = true;
    end
    
    % API
    methods
        function this = ImageViewPortLinker()
            this.hAllAxes = [];
        end
        
        function addAxes(this,haxes)
            if(~ismember(haxes,this.hAllAxes))
                if(isempty(this.hAllAxes))
                    this.hAllAxes        = haxes;
                else
                    this.hAllAxes(end+1) = haxes;
                end
            end
            
            
            hxl = addlistener(haxes, 'YLim','PostSet',@this.syncViewPorts);
            hyl = addlistener(haxes, 'XLim','PostSet',@this.syncViewPorts);
            
            addlistener(haxes,'ObjectBeingDestroyed', @(varargin)delete(hxl));
            addlistener(haxes,'ObjectBeingDestroyed', @(varargin)delete(hyl));
        end
        
    end
    
    % Helpers
    methods
        
        function syncViewPorts(this, varargin)
            if(~this.Enable)
                return;
            end
            
            if(this.Busy)
                return;
            end
            
            this.Busy= true;
            
            
            % Get view port of axes being manipulated
            hThisaxes  = varargin{2}.AffectedObject;
            hThisImage = hThisaxes.findobj('Type','Image');
            imageSize = size(hThisImage.CData);
            xlims = hThisaxes.XLim;
            ylims = hThisaxes.YLim;
            
            xlimPercentage = xlims./[imageSize(2) imageSize(2)];
            ylimPercentage = ylims./[imageSize(1) imageSize(1)];
            
            
            for hOtherAxes=this.hAllAxes
                if isvalid(hOtherAxes) && hOtherAxes~=hThisaxes
                    % Apply viewport percent to all other axes
                    hOtherImage = hOtherAxes.findobj('Type','Image');
                    imageSize = size(hOtherImage.CData);
                    hOtherAxes.XLim = xlimPercentage*imageSize(2);
                    hOtherAxes.YLim = ylimPercentage*imageSize(1);
                    drawnow;
                end
            end
            
            this.Busy= false;
        end
        
    end
end