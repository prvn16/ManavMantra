function [table, api] = createDirectIndexGroup(this, parentFigure, columnNames)
%CREATEDIRECTINDEXGROUP Create a UITABLE to display data.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   PARENTFIGURE: The parent figure.
%   COLUMNNAMES: The names with which to label the columns.

%   Copyright 2007-2013 The MathWorks, Inc.

    % Create the GUI components.
    table = uitable( parentFigure, ...
         'Data', uint32(zeros(1,3)), ...
         'ColumnName', columnNames,...
         'ColumnEditable', true );

    
    set(table, 'Tag', 'directIndex');
    
    set(table, 'CellEditCallback', @dataChanged );

    border = javax.swing.border.EmptyBorder(4,4,4,4);
    
    % Create the API
    api.initializeData = @initializeData;
    api.getTableData = @getTableData;
    api.setTableData = @setTableData;

    % ========================================================
    function dataChanged(table, ev)
        data = getTableData();
        this.buildImportCommand(false);
    end
    
    % ========================================================
    function initializeData(dims)
        nRows = length(dims);
        data = cell(max(2,nRows),3);
        for n = 1:nRows
            data{n,1} = num2str(1);
            data{n,2} = num2str(1);
            data{n,3} = num2str(dims(n));
        end
        if(nRows==1) % Workaround for geck 265454: uitable requires a 2-D matrix
            data{2,3} = [];
        end
        
        set(table,'Data',data);
    end

    % ========================================================
    function data = getTableData
    % Call drawnow to ensure that the table data is up-to-date.
        drawnow;
        
        dat = get(table,'Data');
        
        nRows = size(dat, 1);
        for n = 1:nRows

            % If a row is visible but has empty set data, then we need to
            % skip.
            if isempty(dat{n,1})
                continue;
            end

            start  = str2num(dat{n,1});
            inc    = str2num(dat{n,2});
            len    = str2num(dat{n,3});
            data(n,:) = {start inc len};
        end
    end

    % ========================================================
    function setTableData(data)
        nRows = size(data,1);
        if nRows==1
            data{2,3} = [];
        end
        for i=1:numel(data)
            data{i} = num2str(data{i});
        end
        
        set(table, 'Data', data);
    
    end

end
