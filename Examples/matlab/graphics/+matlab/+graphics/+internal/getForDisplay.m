function getForDisplay(varname, varargin)

    
    %Copyright  2014 The MathWorks, Inc.
    if nargin == 1
         s = getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureMissingVariable',varname));
         disp(s)
    else
        obj = varargin{1};
        classname = varargin{2};
        if ~isa(obj,classname)
            dots = strfind(classname,'.');
            if ~isempty(dots)
                classname = classname(dots(end)+1:end);
            end
            s = getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureClassMismatch',varname, classname));
            disp(s)
        elseif ~isvalid(obj)
            s = getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureDeleted',varname));
            disp(s)
        else
            try
                get(obj)
            catch 
                s = getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureUnknown',varname));
                disp(s)
            end
        end
    end
end