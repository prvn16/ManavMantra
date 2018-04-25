function msg = getErrorMessageForTypedProperty(propcls)
    % Default message
    msg = message('MATLAB:type:PropSetClsMismatch',propcls).getString();
    mc = meta.class.fromName(propcls);
    
    if ~isempty(mc) && mc.Enumerable % If enumeration
        enum_names = {mc.EnumerationMemberList.Name};
        max_no_enums_in_msg = 6;
        
        if numel(enum_names) > max_no_enums_in_msg            
            if matlab.internal.display.isHot
                msg = message('MATLAB:type:PropLongEnumSetClsMismatchWithHyperlink',...
                    propcls).getString;
            else
                msg = message('MATLAB:type:PropLongEnumSetClsMismatchWithoutHyperlink', ...
                 propcls).getString;
            end
        else   
            msg = message('MATLAB:type:PropShortEnumSetClsMismatch', ...
                 getFormattedPossibleValues(enum_names)).getString; 
        end
    end
end

function out = getFormattedPossibleValues(in)
    out = cell2mat(arrayfun(@(x)sprintf('    %s\n', x{:}), in, 'UniformOutput', false));    
end