function setMetadataText(this, metadataText)
%SETMETADATATEXT will display the metadata corresponding to a node.
%   The text is rendered using HTML.
%
%   Function arguments
%   ------------------
%   THIS: the object instance
%   METADATATEXT: the text to display

%   Copyright 2005-2013 The MathWorks, Inc.

    % Check for the default string
    if strcmp(metadataText, 'default')
        metadataText = sprintf('<b>%s</b>', getString(message('MATLAB:imagesci:hdftool:metadataPanel')));
    end

	% build the text color string, which has to be hex.
	colorPrefs = this.prefs.colorPrefs;
	metadataTextColor = sprintf('#%02s%02s%02s', dec2hex(colorPrefs.textColor(1)*255), ...
	                                             dec2hex(colorPrefs.textColor(2)*255), ...
	                                             dec2hex(colorPrefs.textColor(3)*255) );
    
    % Build the HTML String
    text = '<html>';
    text = [text '<head></head>'];
	text = sprintf('%s <body align="top" topmargin="0" text="%s">', ...
	               text, metadataTextColor);
    text = sprintf('%s%s',text, '<p valign="top">');
    text = sprintf('%s%s', text, metadataText);
    text = [text '</p></body>'];
    text = [text '</html>'];

    % Render the text
    awtinvoke(this.metadataDisplay, 'setText(Ljava.lang.String;)', text)
    awtinvoke(this.metadataScroll,  'setValue', 0);

end
