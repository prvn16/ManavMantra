classdef (Abstract) PanAndZoomBehaviorBase < matlab.graphics.internal.HGBehavior
    % This undocumented class may be removed in a future release.
    
    properties
        %ENABLE Property is of type 'bool'
        Enable@logical scalar = true
        %STYLE Property is of type 'StyleChoice enumeration: {'horizontal','vertical','both'}'
        Style = 'both'
        %VERSION3D Property is of type Version3D enumeration: {'camera','limits'}'
        Version3D = 'limits'
        %CONSTRAINT Property is of type Constraint enumeration:
        %{'X','Y','Z','XY','YZ','XZ','unconstrained'}'
        Constraint3D = 'unconstrained'
    end
    
    properties (Transient)
        %SERIALIZE Property is of type 'MATLAB array'
        Serialize = true;
    end
    
    methods
        function set.Style(obj,value)
            % Enumerated DataType = 'StyleChoice enumeration: {'horizontal','vertical','both'}'
            value = validatestring(value,{'horizontal','vertical','both'},'','Style');
            obj.Style = value;
        end
        
        function set.Version3D(obj,value)
            value = validatestring(value,{'camera','limits'},'','Version3D');
            obj.Version3D = value;
        end
        
        function set.Constraint3D(obj,value)
            value = validatestring(value,{'x','y','z','xy','yz','xz','unconstrained'},'','Constraint3D');
            obj.Constraint3D = value;
        end
    end   % set function
    
    methods (Hidden)
        function [ret] = dosupport(~,hTarget)
            % axes
            ret = isgraphics(hTarget,'axes') | isgraphics(hTarget,'polaraxes');
        end
    end
    
    methods (Access={?tmatlab_graphics_internal_PanAndZoomBehavior,...
                     ?matlab.graphics.internal.PanBehavior,...
                     ?matlab.graphics.internal.ZoomBehavior})
        function hObj = saveobj(hObj)
            hObj.Style = matlab.graphics.interaction.internal.constraintConvert3DTo2D(hObj.Constraint3D);
        end
    end
    
    methods (Static = true, Access={?tmatlab_graphics_internal_PanAndZoomBehavior, ...
                                    ?matlab.graphics.internal.PanBehavior,...
                                    ?matlab.graphics.internal.ZoomBehavior})
        function hObj = loadobj(hObj)
            % If we get into a situation where Constraint3D is unconstrained
            % and Style is not both, we must be coming from a previous release
            % of MATLAB where Constraint3D didn't exist.  Therefore, set it to
            % the (converted) value of Style.
            if strcmp(hObj.Constraint3D,'unconstrained') && ...
                    ~strcmp(hObj.Style,'both')
                hObj.Constraint3D = matlab.graphics.interaction.internal.constraintConvert2DTo3D(hObj.Style);
            end
        end
    end
    
end
