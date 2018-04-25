function b = hasInsufficientRange(this)
%HASINSUFFICIENTRANGE Returns true if the results has underspecified design range or insufficient derived range

%   Copyright 2012 MathWorks, Inc.
    
    derivedInf = false;
    b = false;
    
    if (~isempty(this.DerivedMin) && isinf(this.DerivedMin)) || (~isempty(this.DerivedMax) && isinf(this.DerivedMax))
        derivedInf = true;
    end
    
    if ~isempty(this.DesignMin) || ~isempty(this.DesignMax) || ~isempty(this.DerivedMin) || ...
            ~isempty(this.DerivedMax) || ~isempty(this.CompiledDesignMin) || ~isempty(this.CompiledDesignMax)
        %check the inf cases
        if derivedInf && (isempty(this.DesignMin) || isempty(this.DesignMax) ||...
                          isempty(this.CompiledDesignMin) || isempty(this.CompiledDesignMax))
            b = true;
        elseif (isempty(this.DesignMin) && ~isempty(this.DesignMax)) ||...
                (~isempty(this.DesignMin) && isempty(this.DesignMax)) || ...
                (isempty(this.CompiledDesignMin) && ~isempty(this.CompiledDesignMax)) || ...
                (~isempty(this.CompiledDesignMin) && isempty(this.CompiledDesignMax))
            b = true;
        end
    end
end


