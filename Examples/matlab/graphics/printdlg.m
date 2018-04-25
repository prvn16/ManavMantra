function varargout = printdlg(varargin)
%PRINTDLG  Print dialog box.
%  PRINTDLG prints the current figure.
%
%  PRINTDLG(FIG) creates a modal dialog box from which the figure
%  window, FIG, can be printed.  Note that uimenus do not print.
%
%  See Also PRINTOPT, PRINTPREVIEW.

%  Copyright 1984-2012 The MathWorks, Inc.

idx = cellfun(@(X) any(ishghandle(X,'figure')), varargin);
useOriginal = useOriginalHGPrinting(varargin{idx});

if (~useOriginal)
    nargoutchk(0, 0);
    InputArgs=varargin;
    NumInputArgs=nargin;
    if NumInputArgs == 0
        Fig = gcbf;
        if isempty(Fig)
            Fig = gcf;
        end
    else
        % Warn on legacy flags.
        if ischar(varargin{1})
            if (strcmp(varargin{1},'-crossplatform') || (strcmp(varargin{1},'-setup')))
                % warn and no-op for now; error in future release.
                warning(message('MATLAB:printdlg:invalidFlags'))
                InputArgs(1)=[];
                NumInputArgs=NumInputArgs-1; %#ok<NASGU>
            else
                error(message('MATLAB:printdlg:invalidFigure'))
            end 
        end
        
        if ~isempty(InputArgs)
            if ~(ishghandle(InputArgs{1}))
                error(message('MATLAB:printdlg:invalidFigure'))
            end 
            Fig=InputArgs{1};
            InputArgs(1)=[];
        else
            Fig = gcbf;
            if isempty(Fig)
                Fig = gcf;
            end
        end
        
        if ~isempty(InputArgs)
            error(message('MATLAB:printdlg:tooManyArgs'));
        end
    end
    
    % Generate a warning in -nodisplay and -noFigureWindows mode.
    warnfiguredialog('printdlg');
    
    matlab.ui.internal.UnsupportedInUifigure(Fig);
    
    % Print the figure.   
    s = warning('off','MATLAB:print:FigureTooLargeForPage');
    c = onCleanup(@()warning(s));
    print(Fig, '-v');
else
    [warnDeprecated, returnArg]  = printdlg_deprecated(varargin{:});
    if (nargout == 1)
        varargout{1} = returnArg;
    end
    if (warnDeprecated)
        urlHelpPrintdlg = 'matlab:help(''printdlg'')';
        urlDocPrintdlg = 'matlab:doc(''printdlg'')';
        urlHelpPrintpreview = 'matlab:help(''printpreview'')';
        urlDocPrintpreview = 'matlab:doc(''printpreview'')';
        warning(message('MATLAB:printdlg:oldPrintdlgUsage', urlHelpPrintdlg, urlDocPrintdlg, urlHelpPrintpreview, urlDocPrintpreview));     
    end  
end

% LocalWords:  uimenus crossplatform nodisplay
