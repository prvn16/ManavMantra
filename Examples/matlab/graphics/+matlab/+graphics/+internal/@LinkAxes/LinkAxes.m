classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) LinkAxes < handle
% This class is undocumented and will change in a future release
   
% Container class for a linkprop object used for linkaxes operations 
% where de-serialization restores the linkaxes  
    
%   Copyright 2010-2013 The MathWorks, Inc.
    
    properties 
        LinkProp;
    end     
   
    methods 
        function this = LinkAxes(lp)
            this = this@handle;
            if nargin==1
                this.LinkProp = lp;
            end
        end
        
        function removetarget(h,target)
            if ~isempty(this.LinkProp)
                removetarget(this.LinkProp,target)
            end
        end                   
    end
    
    methods (Static = true) 
        % Restore the linkaxes on de-serialization.
        function la = loadobj(s)
            if isstruct(s) && isfield(s, 'Targets') && ...
              isfield(s, 'PropertyNames') && ...
              ~isempty(s.Targets) && ~isempty(s.PropertyNames) && ...
              all(ishghandle(s.Targets,'axes'))
                firstTarget = s.Targets(1);
                propname = 'internal_linkaxes_loaded';
                if ~isprop(firstTarget, propname)
                    pp = addprop(firstTarget, propname);
                    pp.Transient = true;
                    pp.Hidden = true;
                    la = matlab.graphics.internal.LinkAxes(...
                        linkprop(s.Targets,s.PropertyNames));
                    firstTarget.internal_linkaxes_loaded.Num = 1;
                    firstTarget.internal_linkaxes_loaded.LinkProp = la.LinkProp;
                else
                    la = matlab.graphics.internal.LinkAxes(...
                        firstTarget.internal_linkaxes_loaded.LinkProp);
                    firstTarget.internal_linkaxes_loaded.Num = ...
                        firstTarget.internal_linkaxes_loaded.Num + 1;
                    if firstTarget.internal_linkaxes_loaded.Num == length(s.Targets)
                        delete(findprop(firstTarget, propname));
                    end
                end
            else
                la = s;
            end
        end
    end
end