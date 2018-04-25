function success = helpPopup(topic)
    %HELPPOPUP Open HelpPopup Java component.
    % 
    %   This file is a helper function used by the HelpPopup Java component.  
    %   It is unsupported and may change at any time without notice.

    %   Copyright 2010 The MathWorks, Inc.

    if nargout
        success = true;
    end
    
    if ~nargin
        topic = '';
    end
    
    % 'parent' determines to what text component this popup will be parented.
    parent = com.mathworks.mde.cmdwin.XCmdWndView.getInstance;

    % Get the current location of the pointer
    loc = com.mathworks.mde.cmdwin.XCaret.getInstance.getLocation;

    % Doc works better with dots
    topic = strrep(char(topic), '/', '.');
    
    % Show the help
    awtinvoke('com.mathworks.mlwidgets.help.HelpPopup', ...
        'showHelp(Ljavax/swing/text/JTextComponent;Lcom/mathworks/mwswing/binding/KeyStrokeList;Ljava/awt/Point;Ljava/lang/String;)V', ...
        parent, [], loc, topic);
end
