function b = hasConflictingDesignAndDerivedRangeIntersection(this)
% HASCONFLICTINGDESIGNANDDERIVEDRANGEINTERSECTION Returns true of the intersection of the design and derived ranges are empty

% Copyright 2013 MathWorks, Inc

    b = this.hasFullDesignAndDerivedRange && ...
        (this.DerivedMin > this.DesignMax || ...
        this.DesignMin > this.DerivedMax || ...
        this.DerivedMin > this.CompiledDesignMax || ...
        this.CompiledDesignMin > this.DerivedMax);
end
