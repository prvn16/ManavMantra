function varargout = queryPrintServices(action, varargin )
%QUERYPRINTERSERVICES is an internal helper function that should not be called directly. 

%Queries info about available printers: 
%  if action is 'validate', returns true if varargin{1} string is a 
%     valid printer name; false otherwise
%  if action is 'getdefaultandlist', it returns the name of the default printer 
%     and a list of the names of the installed printer names 

%   Copyright 2011 The MathWorks, Inc.
varargout = {};
action = lower(action);
switch action
    case 'validate'
        if length(varargin) == 1 
            pname = varargin{1};
            % validate name 
            varargout{1} = isValidPrinter(pname); 
        else
            varargout{1} = false; 
        end
        
    case 'getdefaultandlist'
         varargout{1} = getDefaultPrinter();
         varargout{2} = getPrinterList();
    case 'supportscolor'
        varargout{1} = printerSupportsColor(varargin{:});
        
end

end

% check if printer name is valid
function valid = isValidPrinter(printerName) 
    import com.mathworks.hg.util.PrinterUtils;
    valid = PrinterUtils.isPrinterValid(printerName);
end

% get system default printer
function  def = getDefaultPrinter()
    import com.mathworks.hg.util.PrinterUtils;
    def = PrinterUtils.getDefaultPrinterName;
    if ~isempty(def)
        % got a valid java string back
        def = (def.toCharArray())';
    end
    
    % it's possible the java string was itself empty
    % in which case we want to return an empty 0x0 blank string ('')
    % not a 1x0 empty string
    if isempty(def)
        def = '';
    end
end

% get list of installed printers 
function plist = getPrinterList() 
    import com.mathworks.hg.util.PrinterUtils;
    svcList = PrinterUtils.getAvailablePrinterNames();
    if ~isempty(svcList) 
        for idx = 1:length(svcList) 
            plist{idx} = (svcList(idx).toCharArray())'; %#ok<AGROW>
        end
    else
        plist = {};
    end
end

% find out if printer supports color
function doesColor = printerSupportsColor(printername)
    import com.mathworks.hg.util.PrinterUtils;
    % minor performance optimization: keep track of last printer and its
    % setting
    persistent LastPrinter;
    persistent LastPrinterDoesColor; 

    if isempty(printername) 
       printername = getDefaultPrinter();
    end
    
    % optimization - remember last printer 
    if ~isempty(LastPrinter) && strcmpi(LastPrinter, printername) 
       doesColor = LastPrinterDoesColor; 
    else
        doesColor = PrinterUtils.supportsColor(printername); 
        LastPrinter = printername;
        LastPrinterDoesColor = doesColor; 
    end
    
end