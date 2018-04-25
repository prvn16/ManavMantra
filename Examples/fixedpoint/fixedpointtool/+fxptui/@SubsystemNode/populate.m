function populate(this)
% Populates the nodes under the subsystem

% Copyright 2013 MathWorks, Inc
    
    if ~isUnderMaskedSubsystem(this)
        children = this.getFilteredHierarchicalChildren;
        if (isempty(children))
            return;
        end
        n = length(children);
        for ci = 1:n
            subsys  = children(ci);
            child = this.addChild(subsys);
            if(~subsys.isMasked)
                populate(child);
            end
        end
    end
end

%-------------------------------------------
