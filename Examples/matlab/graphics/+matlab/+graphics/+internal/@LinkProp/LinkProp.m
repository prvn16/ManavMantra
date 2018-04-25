classdef LinkProp < hgsetget
% Copyright 2014 The MathWorks, Inc.

% This class implements linkprop

    properties(Dependent)
        Enabled;
    end
    
    properties(Access = private)
        Enabled_ = 'on';
    end
    
    properties (SetAccess=private)
        PropertyNames
    end
    
    properties (Transient,Hidden)
        Listeners
    end
    
    properties (Hidden)
        LinkAutoChanges = 'on'
    end
    properties(SetAccess = private)
        Targets
    end
    
    properties (Transient,Hidden)
        CleanedTargets
        HasPostUpdateListeners
        SharedValues
        TargetDeletionListeners
        ValidProperties
        UpdateFcn = @localUpdateListeners
    end
    
    methods
        function set.Enabled(h,val)
            %   Copyright 2014 The MathWorks, Inc.
            
            val = CheckOnOff( val );
            h.Enabled_ = val;
            localSetAllEnableState( h.Listeners, val );
            if strcmp( val, 'on' )
                % Call to pseudo-private method
                feval( h.UpdateFcn, h );
            end
        end

        function val = get.Enabled(h)
            val = h.Enabled_;
        end

        
        function set.LinkAutoChanges(h,val)
            %   Copyright 2014 The MathWorks, Inc.
            
            val = CheckOnOff( val );
            h.LinkAutoChanges = val;
        end
        
        function set.HasPostUpdateListeners(h,val)
            %   Copyright 2014 The MathWorks, Inc.
            
            val = CheckOnOff( val );
            h.HasPostUpdateListeners = val;
        end
        
        function set.Targets(h, targets)
            h.Targets = targets;
            localUpdateListeners(h);
        end
    end
    
    methods
        function hThis = LinkProp(hlist, propnames, varargin)
            if ~isempty(varargin) && strcmp(varargin{1},'LinkAutoChanges')
                hThis.LinkAutoChanges = varargin{2};
            end

            % Cast first input argument into handle array
            hlist = handle( hlist );

            % Cast second input argument into cell array
            if ischar( propnames )
                propnames = { propnames };
            end
            if all( isobject( hlist ) )
                if ~all( isvalid( hlist ) )
                    error( message( 'MATLAB:graphics:proplink' ) );
                end
            else
                if ~all( ishandle( hlist ) )
                    error( message( 'MATLAB:graphics:proplink' ) );
                end
            end
            % Convert mx1 vector to 1xm vector for consistency
            if size( hlist, 1 )>1
                hlist = hlist';
            end
            % Save state to object
            propnames = normalizePropertyNames(hlist, propnames);
            hThis.PropertyNames = propnames;
            hThis.CleanedTargets = {};
            hThis.Targets = hlist;

        end
    end

    methods (Access=private)
        processPostUpdate(hLink,~,~)
        
        processUpdate(hLink,hProp,hEvent)
        
        processMarkedClean(hLink,obj,~)
        
        processReset(hLink,obj,~)
        
        processRemoveHandle(hLink,hTarget,~)
    end
end
