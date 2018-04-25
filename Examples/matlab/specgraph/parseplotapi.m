function [v6, cax, args] = parseplotapi(varargin)
    % This undocumented function may be removed in a future release
    
    %USEHGPLOTAPI determine plotting version
    %  Checks to see which HG plotting API should be used.
    
    %   Copyright 2010-2014 The MathWorks, Inc.
   
    
    % Is the v6 flag passed? 
    [v6,args] = usev6plotapi(varargin{:});

    % Parse args for axes parent
    try
        [cax, args] = axescheck(args{:});
    catch e
        ids = {'MATLAB:graphics:axescheck:DeletedAxes',...
            'MATLAB:graphics:axescheck:DeletedObject',...
            'MATLAB:graphics:axescheck:NonScalarHandle'};
        if any(strcmp(e.identifier,ids))
            throwAsCaller(e);
        else
            rethrow(e);
        end
    end
end
