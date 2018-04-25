function b = hasFullDesignAndDerivedRange(this)
% HASFULLDESIGNANDDERIVEDRANGE Returns true if the result has non-empty design ranges and derived ranges

% Copyright 2013 MathWorks, Inc

    b = checkIsNonEmptyVal(this.DesignMin) ...
        && checkIsNonEmptyVal(this.DesignMax) ...
        && checkIsNonEmptyVal(this.CompiledDesignMin) ...
        && checkIsNonEmptyVal(this.CompiledDesignMax) ...
        && checkIsNonEmptyVal(this.DerivedMin) ...
        && checkIsNonEmptyVal(this.DerivedMax);
end

%------------------------------------------------------
function isNonEmptyVal = checkIsNonEmptyVal(val)
    isNonEmptyVal = false;
    if ~isempty(val) && ~strcmp(val, 'E')
        isNonEmptyVal = true;
    end
end


