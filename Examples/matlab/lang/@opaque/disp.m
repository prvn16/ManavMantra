function disp(opaque_array)
%DISP DISP for a Java object.

%   Copyright 1984-2016 The MathWorks, Inc.

    if ~isjava(opaque_array),
        builtin('disp', opaque_array);
        return;
    end
    
    loose = strcmp(matlab.internal.display.formatSpacing, 'loose');
    if loose
        linefeed = char(10);
    else
        linefeed = '';
    end
    
    try
        cls = class(opaque_array);
        if cls(end) ~= ']'
            desc = [char(toString(opaque_array)), linefeed];
            disp(desc);
        else
            header = ['  ',cls, ':', linefeed];
            disp(header);
            desc = cell(opaque_array);
            if isscalar(desc) && isempty(desc(1)) 
                desc = '    []';
            else            
                isColumn = size(desc, 2)==1;
                desc = evalc('disp(desc)');
                if isempty(desc),
                    desc = ['    [0 element array]' char(10) linefeed];
                else
                    desc = regexprep(desc, '^(\s*)\{(.*)\}(\s*)$', '$1[$2]$3');
                    if isColumn
                        desc = strrep(desc, ['[1' matlab.internal.display.getDimensionSpecifier '1 '], '[');
                    else
                        desc = strrep(desc, ['[1' matlab.internal.display.getDimensionSpecifier '1 '], '    [');
                    end
                end
            end
            
           fprintf('%s',desc);
        end
    catch exc %#ok<NASGU>
      builtin('disp', opaque_array);
    end
end
