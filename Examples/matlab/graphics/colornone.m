function colornone( state, fig )
%COLORNONE Modify figure to have transparent background
%   COLORNONE(STATE,FIG) modifies the color of graphics objects to print
%   or export them with a transparent background STATE is
%   either 'save' to set up colors for a transparent background or 'restore'.
%
%   COLORNONE(STATE) uses the current figure.

%   Copyright 1984-2009 The MathWorks, Inc.

persistent SaveTonerOriginalColors;

if nargin == 0 ...
        || ~ischar( state ) ...
        || ~(strcmp(state, 'save') || strcmp(state, 'restore'))
    error(message('MATLAB:colornone:NeedsInformation'))
elseif nargin ==1
    fig = gcf;
end

if strcmp( state, 'save' )
    origFigColor = get(fig,'color');
	if isequal( get(fig,'color'), 'none')
    	origFigColor = [NaN NaN NaN];
	end
    set(fig,'color', 'none');
    storage.figure = {fig origFigColor};
    SaveTonerOriginalColors = [storage SaveTonerOriginalColors];
    
    
else % Restore colors
    
    orig = SaveTonerOriginalColors(1);
    SaveTonerOriginalColors = SaveTonerOriginalColors(2:end);
    
    origFig = orig.figure{1};
    origFigColor = orig.figure{2};

	if (sum(isnan(origFigColor)) == 3)
		origFigColor = 'none';
	end
    set(origFig,'color',origFigColor);
    
end



