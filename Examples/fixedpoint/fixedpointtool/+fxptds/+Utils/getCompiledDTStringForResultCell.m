function val = getCompiledDTStringForResultCell(result)
% getCompiledDTStringForResultCell if necessary prepend 'Scaled Double of' to CompiledDT
% 

% Copyright 2016 The MathWorks, Inc.

    val = result.getPropertyValue('CompiledDT');
    if result.getPropertyValue('IsScaledDouble')
        val = ['Scaled Double of ',val];
    end
end
