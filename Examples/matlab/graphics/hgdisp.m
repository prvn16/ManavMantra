function hgdisp( h )
% HGDISP displays HG handle object information

%  Copyright 2012-2017 The MathWorks, Inc.

    % Options to change output display
    showProperties = false; % Set true to display property list
    showModifiedProperties = false; % Set true to display modified properties also
    showDoubleHandleID = false; % Set true to show double handle as ID.
    showMatrices = false; % Set true to show mxn arrays of handles
    
    if length(h) > 1
        localMatrixDisplayFunc(h)
    else
        if showProperties && isprop(h,'Type')            
            disp(['  ' upper(localScalarDispFunc(h)) ' with properties:'])
            disp(' ')
            if showModifiedProperties              
                disp('    Properties with modified values:')
                disp(' ')
                disp( localModifiedProps(h) )
                disp('    All properties:')
                disp(' ')
            end
            hggetdisp(h)
        else
            disp(['    ' localScalarDispFunc(h)])
        end
    end
    
    disp(' ')
    
    function localMatrixDisplayFunc(h)
        s = size(h);
        if showMatrices
            for m = 1:s(1)
                col = '';
                for n = 1:s(2)
                    col = strcat(col, ['    ' localScalarDispFunc(h(m,n))]);
                end
                disp(col)
            end  
        else
            if s(2) > 1
%                 disp(['[' num2str(s(1)) ' x ' num2str(s(2)) ' ] array of ' class(h)])
                disp(['[' num2str(s(1)) ' x ' num2str(s(2)) ' ] array of graphics objects'])
            else
                for m = 1:s(1)
                    disp(['    ' localScalarDispFunc(h(m,s(2)))]);
                end
            end
        end
    end

    function localVectorDispFunc(h)
        for m = 1:s(1)
            col = '';
            for n = 1:s(2)
                col = strcat(col, ['    ' localScalarDispFunc(h(m,n))]);
            end
            disp(col)
        end  
    end

    function str = getShortName(h)
        meta = metaclass(h);
        pos = strfind(meta.Name,'.');
        str = meta.Name(pos(end)+1:end);
    end

    function out = localScalarDispFunc(h)
        try
            if isempty(h)
                out = ['0x0 array of ' lower(getShortName(h)) ' objects.'];               
            else
                out = get(h,'type');
                if showDoubleHandleID
                    % Examples of adding double handle identifiers to output
                    out = [out ': (' num2str(double(h)) ')'];           
                end
            end
        catch ex
            if strcmp(ex.identifier, 'MATLAB:class:InvalidHandle')
                out = ex.message;
            else
                out = class(h);
            end
        end
    end

    function out = localModifiedProps(h)
        modpi = {};
        p = properties(h);
        for i=1:length(p)
            pi = findprop(h,p{i});
            if pi.Dependent
                mpi = findprop(h,[pi.Name 'Mode']);
                if ~isempty(mpi)
                    mode = get(h,mpi.Name);
                    if strcmpi( mode, 'Manual')
                        modpi{end+1} = pi.Name;
                    end
                end
            end
        end
        vals = get(h,modpi);
        o = cell2struct(vals,modpi,2);
        out = o;
    end
    
end
