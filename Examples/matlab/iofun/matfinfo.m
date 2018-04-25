function [m,d] = matfinfo(filename)
%MATFINFO Text description of MAT-file contents.
%
%   See also FINFO.

% Copyright 1984-2012 The MathWorks, Inc.

    try
        d = whos('-file', filename);
    catch exception %#ok
        m = '';
        d = getString(message('MATLAB:matfinfo:NotAMatFile'));
        return;
    end
    
    m = getString(message('MATLAB:matfinfo:IsAMatFile')); 
    if nargout==2
        if isempty(d)
            d = getString(message('MATLAB:matfinfo:EmptyMatFile'));
        elseif length(d) > 1024
            % 1024 is somewhat arbitrary but mat files with gobs
            % of variables take a LONG time to process using matfinfosub
            d = [getString(message('MATLAB:matfinfo:MatFileContents')), ' ',  sprintf('%d variables', length(d))];
        else
            d = [getString(message('MATLAB:matfinfo:MatFileContents')), ':', sprintf('\n\n') matfinfosub(d)];
        end
    end
end
    
function result = matfinfosub(s)
    result = '';
    if ~isempty(s)
        maxw = 12;
        for i = 1:length(s)
            if length(s(i).name) > maxw
                maxw = length(s(i).name) + 1;
            end
        end
        maxw = num2str(maxw);
        result = sprintf(['%-' maxw 's     Size         Bytes  Class\n'], '  Name');
        for i = 1:length(s)
            sLength = length(s(i).size);
            if sLength < 4 && sLength > 0
                sizestr = sprintf('%4dx', s(i).size(1));
                for j = 2:sLength
                    sizestr = sprintf('%s%dx', sizestr, s(i).size(j));
                end
                sizestr = sizestr(1:end-1);
            elseif sLength == 0
                sizestr = sprintf('%5s','-');
            else
                sizestr = sprintf('%4dD', sLength);
            end
            classstr = s(i).class;
            switch classstr
            case {
                    'double', ...
                    'sparse', ...
                    'struct', ...
                    'cell', ...
                    'char', ...
                    'int8', ...
                    'uint8', ...
                    'int16', ...
                    'uint16', ...
                    'int32', ...
                    'uint32', ...
                    }
                classstr = [classstr ' array']; %#ok<AGROW>
            otherwise
                classstr = [classstr ' object']; %#ok<AGROW>
            end
            thisLine = sprintf(['  %-' maxw 's%-10s %10s  %s'], s(i).name, sizestr, ...
                mat2str(s(i).bytes),  classstr);
            result = sprintf('%s\n%s',result,thisLine);
        end
        deblank(result);
    end
end
