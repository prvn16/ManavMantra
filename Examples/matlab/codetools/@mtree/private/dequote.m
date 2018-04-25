function s = dequote( s )

% Copyright 2006-2016 The MathWorks, Inc.

    % return the string resulting from removing the quotes from s
    k = 0;
    i = 1;
    n = length(s);
    % determine which quotes we are looking for
    ch = '''';
    if n ~= 0 && s(1) == '"'
      ch = '"';
    end
    while i <= n
        if s(i)==ch
            if i+1<=n && s(i+1)==ch
              % escape single or double quotes
                k = k + 1;
                s(k) = ch;
                i = i + 1;
            end
            i = i + 1;
            continue
        else
            k = k + 1;
            s(k) = s(i);
            i = i + 1;
        end
    end
    s = s(1:k);
end

