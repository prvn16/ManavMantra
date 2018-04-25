function [j,flag,pth] = collect_qualifiers( pth, ipath, dots, j )
% helper function for pathit -- it collects qualifiers and returns
% them in flag

% Copyright 2006-2014 The MathWorks, Inc.

    flag = 0;
    if isempty( pth )
        return;
    end
    
    pend = pth(end);
    if pend=='+' || pend=='*' || pend=='&' || pend== '|'
        % old-style qualifiers.  Collect and return
        while ~isempty( pth )
            pend = pth(end);
            if pend=='+'
                add_list();
            elseif pend=='*'
                add_tree();
            elseif pend=='&'
                add_all();
            elseif pend=='|'
                add_any();
            else
                % we are done
                return
            end
            pth(end) = '';   % delete last character
        end
        return    % nothing but qualifiers
    end
    
    % this is the new style, with later qualifiers separated by dots
    if is_qual( pth )
        % sets flag if true
        % in this case, we return a pth of ''
        pth = '';
        % but we still look for further qualifiers
    end
    % j is set to look for the next link
    while( j < length(dots) )
        if is_qual( ipath( dots(j)+1:dots(j+1)-1 ) )
            j = j + 1;
            continue
        end
        break
    end
    return
    
    function b = is_qual( str )
        b = true;
        switch( str )
            case 'List'
                add_list();
                return;
            case 'Tree'
                add_tree();
                return;
            case 'Full'
                add_full();
                return;
            case 'All'
                add_all();    
                return;
            case 'Any'
                add_any();
                return;
            otherwise
                b = false;
                return
        end
    end
    
    function add_all
        if bitand(flag,12)
            error(message('MATLAB:mtree:andor'));
        end
        flag = flag + 4;
    end
    function add_any
        if bitand(flag,12)
            error(message('MATLAB:mtree:andor'));
        end
        flag = flag + 8;
    end
    function add_list
        if bitand(flag,1)
            error(message('MATLAB:mtree:plus'));
        end
        flag = flag + 1;
    end
    function add_tree
        if bitand(flag,2)
            error(message('MATLAB:mtree:star'));
        end
        flag = flag + 2;
    end
    function add_full
        if bitand(flag,3)
            error(message('MATLAB:mtree:full'));
        end
        flag = flag + 3;
    end
end
