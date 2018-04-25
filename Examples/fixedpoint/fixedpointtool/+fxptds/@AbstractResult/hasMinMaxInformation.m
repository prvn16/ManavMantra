function b = hasMinMaxInformation(this)
% HASMINMAXINFORMATION returns true if any of the min/max properties is non-empty.

% Copyright 2012-2014 The MathWorks, Inc.

    b = this.HasSimMinMax || this.HasDerivedMinMax || this.HasDesignMinMax || ...
        ~isempty(this.CompiledDesignMin) ||  ~isempty(this.CompiledDesignMax);

end
