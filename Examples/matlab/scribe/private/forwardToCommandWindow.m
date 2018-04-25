function forwardToCommandWindow(fig,evd)
%FORWARDTOCOMMANDWINDOW Forward keypress to command window and switch focus
%to the command window.

%   Copyright 2005-2012 The MathWorks, Inc.

%First check for a printable character
if isempty(evd.Character)
    return;
end

%Check for "ctrl" and "alt" modifiers
modifiersSize = size(evd.Modifier);
for i = 1 : modifiersSize(2)
    currentModifier = evd.Modifier{i};
    if (strcmp(currentModifier,'control') || ...
        strcmp(currentModifier,'alt')     || ...
        strcmp(currentModifier,'command'))
        return;
    end
end

isNoCmdWindow = isdeployed;
isDesktop = usejava('desktop');
isModal = strcmpi(get(fig,'WindowStyle'),'modal');
isJavaFigure = usejava('awt');

%Check for absence of a command window and modal figures:
if isNoCmdWindow || isModal
    return;
end

%In the absence of Java, simply bring the command window forward
if ~isJavaFigure
    commandwindow;
    return;
end

%Forward the character
%Disable the JavaFrame warning:
[ lastWarnMsg, lastWarnId ] = lastwarn; 
oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 

jf = get(fig, 'javaframe'); 

% Restore the warning state:
warning(oldstate);
lastwarn(lastWarnMsg,lastWarnId);

ac = jf.getAxisComponent;
%Check for empty AxisComponent
if isempty(ac)
    return;
end

%Check if the desktop is active, if it's not, bring the command window to
%the front
if isDesktop
    %Construct a key-press event
    %Deal with newlines:
    if uint32(evd.Character) == 13
        k = java.awt.event.KeyEvent(ac, java.awt.event.KeyEvent.KEY_PRESSED, 0, 0, java.awt.event.KeyEvent.VK_ENTER, evd.Character);
    %Deal with backspace
    elseif uint32(evd.Character) == 8
        k = java.awt.event.KeyEvent(ac, java.awt.event.KeyEvent.KEY_PRESSED, 0, 0, java.awt.event.KeyEvent.VK_BACK_SPACE, evd.Character);
    else
        k = java.awt.event.KeyEvent(ac, java.awt.event.KeyEvent.KEY_PRESSED, 0, 0, java.awt.event.KeyEvent.VK_UNDEFINED, evd.Character);
    end
    com.mathworks.mde.cmdwin.CmdWinMLIF.processKeyFromC(k);
else
    commandwindow;
end