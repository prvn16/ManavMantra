function out = getNewlineCharacter(inp)
% getNewlineCharacter determines the mode in which MATLAB is operating to
% determine how the newline or carriage return characters must be displayed
% in a display context which does permit vertical scrolling
desktopMode = false;
out = '';

try
    desktopMode = desktop('-inuse');
catch
end

if desktopMode
    % MATLAB uses the desktop, so
    % char(10) becomes char(8629)
    % char(13) becomes char(8592)
    if (abs(inp) == 10)
        out = char(8629);
    elseif (abs(inp) == 13)
        out = char(8592);    
    end
else
    % MATLAB is in nodesktop, nojvm or deployed modes, so both the newline
    % and carriage return characters get replaced with 3 dots
     if (abs(inp) == 10) || (abs(inp) == 13)
        out = '...';
     end
end
end