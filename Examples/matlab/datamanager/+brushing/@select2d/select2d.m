% This internal helper class may change in a future release.

%  Copyright 2008 The MathWorks, Inc.

% Class to for drawing a selection rectangle for brushing data. An object
% should be created on a mouse down event, and the prism drawn by calling
% draw on mouse motion. The reset method should be called on the object on
% a mouse up to clear the selection graphic.

classdef (CaseInsensitiveProperties = true) select2d < brushing.select
    properties
        Text = [];
    end
    methods
        function this = select2d(hostAxes)
            this = this@brushing.select(hostAxes);
        end
        
        function reset(this)
                reset@brushing.select(this);
                t = this.Text;
                % When using MCOS graphics classes, t is a primitive text 
                % object which cannot be detected with ishghandle.
                if ~isempty(t) && (ishghandle(t) || (isobject(t) && isvalid(t)))
                   delete(t);
                end
                this.Text = [];
        end
    end
end