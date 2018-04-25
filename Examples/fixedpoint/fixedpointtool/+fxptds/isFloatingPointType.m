function isFltptTypeStr = isFloatingPointType(dataTypeStr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isFltptTypeStr = any(strcmpi(dataTypeStr, {'double', 'single', ...
                    'float(''single'')', 'float(''double'')'}));
                
% if floating point type str takes 'fixdt('double/single' or
% numerictype('double/single' patterns.
if ~isFltptTypeStr
    b = (strncmp(dataTypeStr, 'fixdt(',6) || strncmp(dataTypeStr, 'numerictype(',length('numerictype(')));
    if (b) 
        % handle all cases of fixdt('double/single'... &
        % numerictype('double/single'... specifications
        % evaluate the data type and use the isdouble / issingle call to decide
        % if its a fixed point type or not instead of strcmp usage. 
        try
            nt = eval(dataTypeStr); 
        catch
            % for errorneous type strings like fixdt('double', 'InvalidProp', 'InvalidVal')
            isFltptTypeStr=false;
            return;
        end
        if nt.isdouble || nt.issingle 
            isFltptTypeStr = true;
        end
    end
end