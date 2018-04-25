classdef impolyVertex < impoint
    % This undocumented class may be removed in a future release.
    
    %   Copyright 2007 The MathWorks, Inc.

    methods

        %------------------------------------------------------------------
        function obj = impolyVertex(h_parent,x,y)

            obj = obj@impoint(h_parent,x,y);

            % Remove default pointer behavior established by impoint
            iptSetPointerBehavior(obj,[]);

            % Remove default context menu created by impoint
            delete(get(obj.h_group,'UIContextMenu'));
            set(obj.h_group,'UIContextMenu',[]);

            % Re-tag impoint vertices to allow for workaround for g392299
            set(obj.h_group,'tag','impoly vertex');
            
        end

        %-------------------------------------------
        function iptSetPointerBehavior(obj,behavior)

            iptSetPointerBehavior(obj.h_group,behavior);

        end

    end

end

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function impoint