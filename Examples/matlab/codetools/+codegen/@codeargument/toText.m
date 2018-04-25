function [err] = toText(hArg,hVariableTable)
% Determines text representation

% Copyright 2006-2013 The MathWorks, Inc.

err = false;

% If this is an output argument, then create a variable representation
if get(hArg,'IsOutputArgument')
    addVariable(hVariableTable,hArg);

% If parameter, then create variable representation
elseif get(hArg,'IsParameter')
   addVariable(hVariableTable,hArg);

% otherwise, generate text value representation
else
   val = get(hArg,'Value');
   datatype_descriptor = get(hArg,'DataTypeDescriptor');
   [str, err]= local_type2text(val,datatype_descriptor);
   if ~err
     set(hArg,'String',str);
   end
end

%----------------------------------------------------------%
function [str, err] = local_type2text(val,datatype_descriptor)
% Converts arbitrary input type to suitable input string
% If the type cannot be converted to a string, an error is thrown.

err = false;
str = ''; %#ok: flag to remove mlint warning
ERRSTR = 'error, unable to convert type to text';

% character array
if ischar(val)  
    [str] = local_char2text(val,datatype_descriptor);
    
% cell array of strings
elseif iscellstr(val) 
    [str] = local_cellstr2text(val,datatype_descriptor);
    
% logical
elseif isscalar(val) && islogical(val)
    if val 
        str = 'true'; 
    else
        str = 'false'; 
    end
     
% number    
elseif isnumeric(val)
    [str,err] = local_numeric2text(val);
    
% otherwise
else
    str = ERRSTR;
    err = true;
end

%----------------------------------------------------------%
function [str,err] = local_numeric2text(val)
% Coverts a numeric type into a valid m-code string
err = false;
ERRSTR = 'error, unable to convert type to text';
% ToDo: support multi-dim arrays
if ndims(val) > 2 
    str = ERRSTR;
    err = true;
else
    str = mat2str(val);
end
    
%----------------------------------------------------------%
function [str] = local_cellstr2text(val,datatype_descriptor)
% Coverts cell string type into a valid m-code string

str = '{';
len = length(val);
for n = 1:len
    newstr = local_char2text(val{n},datatype_descriptor);
    str = [str,newstr];
    if n < len
        str = [str,','];
    end
end
str = [str,'}'];
    
%----------------------------------------------------------%
function [str] = local_char2text(val,datatype_descriptor)
% Converts a char type into valid code

m = size(val,1);
isCharNoNewLine = strncmp(datatype_descriptor,'CharNoNewLine',13);
isNoDeblank = strcmp(datatype_descriptor,'CharNoNewLineNoDeblank');

% If string is multi-line text, then add a 'sprintf(''\n'')' between
% each new line to preserve the original format.
if(m>1)
    final_str = '';
    for j =1:m
        % Replace ' with ''
        newval = strrep(val(j,:),'''','''''');
        % Remove trailing white space 
        if ~isNoDeblank
            newval = deblank(newval);
        end
        if (j==1)
            if isCharNoNewLine
                newval = ['[''',newval,''';'];
            else
                newval = ['[''',newval,''',sprintf(''\n''),'];
            end
        elseif (j==m)   
            if isCharNoNewLine
                newval = ['''',newval,''']'];          
            else
                newval = ['''',newval,''']'];
            end
        else
            if isCharNoNewLine
                newval = ['''',newval,''';'];
            else
                newval = ['''',newval,''',sprintf(''\n''),'];
            end
        end
        final_str = strcat(final_str,newval);
    end
    % Convert cell string into char array
    str = final_str;

% Single line text
else
    % Replace ' with ''
    val = strrep(val,'''','''''');
    % Remove trailing white space
    if ~isNoDeblank
        val = deblank(val);
    end
    % Replace new line with a 'sprintf(''\n'')'
    n_newline = find(val==char(10)); %#ok<CHARTEN>
    if ~isempty(n_newline)
        val = strrep(val,char(10), (''',newline,''') ); %#ok<CHARTEN>
    end

    % Wrap text with quotes and a bracket if necessary
    str = ['''',val,''''];
    if ~isempty(n_newline)
        str = ['[',str,']'];
    end
end
