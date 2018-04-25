function b = isReadonlyProperty(this, propName)
%ISREADONLYPROPERTY returns true if for uneditable list view properties
    
% Copyright 2012 MathWorks, Inc.

    b = true;
    
    if this.IsViewOnlyEntry
        return;
    end
    
    if(this.hasProposedDT && (strcmpi('ProposedDT',propName) ...
       ||strcmpi('Accept',propName))) || strcmpi('Run',propName)
        b = false;
    end
end
