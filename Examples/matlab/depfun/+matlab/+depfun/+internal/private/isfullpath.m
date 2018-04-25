function tf = isfullpath(file)
    % Ugly, but faster than regexp.
    % File is a full path already if:
    %   * It starts with / on any platform.
    %   * On the PC, it starts with / or \
    %   * On the PC, it starts with X:\ or X:/ (where X is any drive)
    fs = filesep;
    tf = (~isempty(file) && ...
          (file(1) == fs || file(1) == '/' || ...
           (ispc && numel(file) >= 3 && file(2) == ':' && ...
            (file(3) == fs || file(3) == '/'))));
end