function varargout = modifyColorsForPrint(invertRevertFlag, varargin)
% MODIFYCOLORSFORPRINT Modify a figure's colors for printing based on
% preference settings for figure copy options.  This undocumented helper
% function is for internal use.

% This function is called during the print path.  See usage in
% alternatePrintPath.m
    
% MODIFYCOLORSFORPRINT('invert', h, honorColorPrefs,
% outputRendererIsPainters, outputBitmap, figbkcolorpref) can be used to
% invert the colors based on the arguments.  The return will be:
% [modified, invertedFlag, originalColor].  The invertedFlag and
% originalColor can be used when calling this function to 'revert'.

% MODIFYCOLORSFORPRINT('revert', h, invertedFlag, origColor) reverts the
% colors to their original values, before 'invert' was called.
    
%   Copyright 2013 The MathWorks, Inc.

    if strcmp(invertRevertFlag, 'invert') && length(varargin) == 5
        h = varargin{1};
        honorColorPrefs = varargin{2};
        outputRendererIsPainters = varargin{3};
        outputBitmap = varargin{4};
        figbkcolorpref = varargin{5};
        
        modified = false;
        inverted = 0;
        origColor = [];
        
        if honorColorPrefs
            % if called from Edit->Copy Figure, check what figure
            % background setting is in place from Edit->Copy Options.  The
            % result of the copy is also dependent on the renderer and the
            % format selected.
            
            % figbkcolor will be one of the following:
            %    0 == 'none' (transparent)
            %    1 == white
            %    2 == use figure background
            
            switch figbkcolorpref
                case 0  % none/transparent background
                    if outputRendererIsPainters && ~outputBitmap
                        % Can produce transparent background
                        inverted = 2;
                        origColor = LocalColorNone(h);
                    else
                        % The user has selected transparent background, but
                        % we can't produce it either because of the
                        % renderer or the output format.  Either way,
                        % instead of creating output with black background,
                        % set it to white
                        inverted = 1;
                        adjustbackground('save', h);
                    end
                    modified = true;
                    
                case 1  % white background
                    inverted = 1;
                    adjustbackground('save', h);
                    modified = true;
                    
                case 2  % figure background
                    % Nothing to do in this case
            end
        else
            if strcmp('on', get(h,'InvertHardcopy'))
                inverted = 1;
                adjustbackground('save', h);
                modified = true;
            end
        end
        
        varargout = {modified, inverted, origColor};
    elseif strcmp(invertRevertFlag, 'revert')
        h = varargin{1};
        inverted = varargin{2};
        origColor = varargin{3};
        
        % Invert back the toner saving/colornone color changes
        switch inverted
            case 1
                % inverthardcopy == true
                adjustbackground('restore', h);
            case 2
                % print w/transparent background == true (edit->CopyOptions)
                LocalColorNone(h, origColor);
        end
    end
end

function origColors = LocalColorNone(fig, restoreColors)
    % modify the figure to have a transparent background (1 arg)
    %   returns color value to pass in when restoring
    % restore the figure's original color (2 args)
    
    if nargin == 1
        % save original colors and set to transparent
        origFigColor = get(fig,'color');
        if isequal( get(fig,'color'), 'none')
            origFigColor = [NaN NaN NaN];
        end
        set(fig,'color', 'none');
    else
        % restore colors
        origFigColor = restoreColors;
        if (sum(isnan(origFigColor)) == 3)
            origFigColor = 'none';
        end
        set(fig, 'color', origFigColor);
    end
    
    if nargout == 1
        origColors = origFigColor;
    end
end
