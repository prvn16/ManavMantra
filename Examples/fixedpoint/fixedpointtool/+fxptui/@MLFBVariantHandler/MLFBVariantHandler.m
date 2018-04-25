classdef MLFBVariantHandler < handle
    %MLFBVARIANTHANDLER Class that helps update the Fixed-Point Tool with the
    %variants created while applying data types to MLFB code.
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties(SetAccess = private, GetAccess = private)
        MLFBVariantCreationListener
        VariantSubsystems
    end
    
    methods (Hidden)
        attachMLFBVariantCreationListener(this, sudModel);
        removeMLFBVariantCreationListener(this);
        captureVariantSubsystems(this, eventData);
        variants = getVariantSubsystems(this);
    end
end