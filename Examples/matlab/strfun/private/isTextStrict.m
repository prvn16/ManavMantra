function tf = isTextStrict(value)
    tf = (ischar(value) && ((isempty(value) && isequal(size(value),[0 0])) || isrow(value))) || isstring(value) || iscellstr(value);
end

