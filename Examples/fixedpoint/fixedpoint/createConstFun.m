function createConstFun(function_name, varargin)
%createConstFun Create a function that contains constants.
%
%   createConstFun('CONSTX',X) creates function CONSTX.m containing the
%   constant representation of variable X, where X is a builtin
%   numeric type, string, logical, or a fi object.
%
%   createConstFun('XYZ',X,Y,Z,...) creates function XYZ.m
%   containing the constant representations of variables 
%   X, Y, Z, .... 
%
%   This function is useful for creating constants to be used in code
%   generation.  Use the generated function as if it were a constant.
%    
%   Example:
%
%   % Create a function that contains a fixed-point lookup-table containing the
%   % values of sin(x) where 0 <= x < pi/2.
%   x = linspace(0,pi/2,128);
%   y = fi(sin(x));
%   createConstFun('SINE_LOOKUP_TABLE',y)
%
%   % In your code, use SINE_LOOKUP_TABLE as a constant.
%   sine_table = SINE_LOOKUP_TABLE();
%   x = linspace(0,pi/2,128);
%   plot(x,sine_table)
%
%   See also CAST, ONES, ZEROS. 

%   Copyright 2012-2013 The MathWorks, Inc.

    % Get variable names
    var_names = cell(size(varargin));
    nvars = length(varargin);
    for nvar=1:nvars
        var_names{nvar} = inputname(nvar+1);
        if isempty(var_names{nvar})
            var_names{nvar} = sprintf('variable_%d',nvar);
        end
    end
    
    fun = fopen([function_name,'.m'],'W');
    % Function definition
    fprintf(fun,'function ');
    if nvars > 1
        fprintf(fun,'[');
    end
    for nvar=1:nvars - 1
        fprintf(fun,'%s, ',var_names{nvar});
    end
    fprintf(fun,'%s',var_names{end});
    if nvars > 1
        fprintf(fun,']');
    end
    fprintf(fun,' = %s() %%#codegen\n',function_name);
    
    % Each variable
    for nvar=1:length(varargin)
        v = varargin{nvar};
        var_name = var_names{nvar};
        if isfi(v)
            print_fi(fun,var_name,v);
        elseif isnumeric(v)
            print_numeric(fun,var_name,v);
        elseif ischar(v)
            print_char(fun,var_name,v);
        elseif islogical(v)
            print_logical(fun,var_name,v);
        else
            assert(0,'Not done yet');
        end
    end
    
    fprintf(fun,'end\n');
    fclose(fun);
    
    % REHASH with no inputs performs the same refresh operations that are done
    % each time the MATLAB prompt is displayed--namely, for any non-toolbox
    % directories on the path, the list of known files is updated, the list of
    % known classes is revised, and the timestamps of loaded functions are
    % checked against the files on disk.  The only time one should need to use
    % this form is when writing out files programmatically and expecting MATLAB
    % to find them before reaching the next MATLAB prompt.
    rehash
end

function print_fi(fun,var_name,v)
    if isfixed(v)
        print_fixed_fi(fun,var_name,v);
    else
        print_float_fi(fun,var_name,v);
    end
end

function print_fixed_fi(fun,var_name,v)
    fprintf(fun,'%4shexvar_%s = [\n','',var_name);
    for i=1:numel(v)
        fprintf(fun,'%8s''%s''\n','',hex(v(i)));
    end
    fprintf(fun,'%8s];\n','');
    T = tostring(numerictype(v));
    if isfimathlocal(v)
        F = tostring(fimath(v));
    else
        F = '[]';
    end
    if isempty(v)
        fprintf(fun,'%4s%s = fi(''numerictype'',%s,''fimath'',%s);\n',...
                '',var_name,T, F);
    else
        fprintf(fun,'%4s%s = fi(''numerictype'',%s,''fimath'',%s,''hex'',hexvar_%s);\n',...
                '',var_name,T, F, var_name);
        s = size(v);
        siz = '[';
        for i=1:length(s)-1
            siz = [siz,int2str(s(i)),','];
        end
        siz = [siz,int2str(s(end)),']'];
        fprintf(fun,'%4s%s = reshape(%s,%s);\n','',var_name,var_name,siz);
    end
end

function print_float_fi(fun,var_name,v)
    fprintf(fun,'%4svar_%s = [\n','',var_name);
    for i=1:numel(v)
        if isreal(v)
            fprintf(fun,'%8s%.17g\n','',double(v(i)));
        else
            fprintf(fun,'%8s%.17g+%.17gi\n','',real(double(v(i))),imag(double(v(i))));
        end
    end
    fprintf(fun,'%8s];\n','');
    T = tostring(numerictype(v));
    if isfimathlocal(v)
        F = tostring(fimath(v));
    else
        F = '[]';
    end
    if isempty(v)
        fprintf(fun,'%4s%s = fi(''numerictype'',%s,''fimath'',%s);\n',...
                '',var_name,T, F);
    else
        fprintf(fun,'%4s%s = fi(''numerictype'',%s,''fimath'',%s,''data'',var_%s);\n',...
                '',var_name,T, F, var_name);
        s = size(v);
        siz = '[';
        for i=1:length(s)-1
            siz = [siz,int2str(s(i)),','];
        end
        siz = [siz,int2str(s(end)),']'];
        fprintf(fun,'%4s%s = reshape(%s,%s);\n','',var_name,var_name,siz);
    end
end

function print_numeric(fun,var_name,v)
    if isa(v,'double')
        % If v is a double, then don't wrap it in double([1 2 3]), just leave
        % it [1 2 3].  Explicitly casting to double fools some float-to-fixed
        % conversion tools, when it could make these variables constant integers.
        class_v = '';
    else
        % If v is not a double, then wrap it in the class constructor.  For
        % example, int8([1 2 3]).
        class_v = class(v);
    end
    if isscalar(v)
        fprintf(fun,'%4s%s = ','',var_name);
        if ~isempty(class_v)
            fprintf(fun,'%s(',class_v);
        end
        if isreal(v)
            fprintf(fun,'%8s%.17g','',v);
        else
            fprintf(fun,'%8s%.17g+%.17gi','',real(v),imag(v));
        end
        if ~isempty(class_v)
            fprintf(fun,')');
        end
        fprintf(fun,';\n');
    else
        fprintf(fun,'%4s%s = %s([\n','',var_name,class_v);
        if isreal(v)
            for i=1:numel(v)
                fprintf(fun,'%8s%.17g\n','',v(i));
            end
        else
            for i=1:numel(v)
                fprintf(fun,'%8s%.17g+%.17gi\n','',real(v(i)),imag(v(i)));
            end
        end
        fprintf(fun,'%4s]);\n','');
        s = size(v);
        siz = '[';
        for i=1:length(s)-1
            siz = [siz,int2str(s(i)),','];
        end
        siz = [siz,int2str(s(end)),']'];
        fprintf(fun,'%4s%s = reshape(%s,%s);\n','',var_name,var_name,siz);
    end
end

function print_char(fun,var_name,v)
    if size(v,1)==1
        fprintf(fun,'%4s%s = ''%s'';\n','',var_name,v);
    else
        % Why the third %s here?
        fprintf(fun,'%4s%s = %s([\n','',var_name);
        fprintf(fun,'%4s[\n','');
        for i=1:size(v,1)
            fprintf(fun,'%8s''%s''\n','',v(i,:));
        end
        fprintf(fun,'%4s];\n','');
    end
end

function print_logical(fun,var_name,v)
    fprintf(fun,'%4s%s = [\n','',var_name);
    ft = {'false','true'};
    for i=1:numel(v)
        fprintf(fun,'%8s%s\n','',ft{double(v(i))+1});
    end
    fprintf(fun,'%4s];\n','');
    s = size(v);
    siz = '[';
    for i=1:length(s)-1
        siz = [siz,int2str(s(i)),','];
    end
    siz = [siz,int2str(s(end)),']'];
    fprintf(fun,'%4s%s = reshape(%s,%s);\n','',var_name,var_name,siz);
end
