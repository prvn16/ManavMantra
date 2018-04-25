function dataSourceTableData = createLinkedVariablesTableData(varContents, ls) 
% This internal helper function may be removed in a future release.

% Copyright 2016 The MathWorks, Inc.

% Creates a java.util.Vector of rows to represents the table model of the
% Linked Plot Data Source Dialog

% varContents is the struct returned by "whos" that represents the
% workspace

% ls is an array of graphical objects 

import com.mathworks.page.datamgr.linkedplots.*;

datasrcPropNames = {'XDataSource','YDataSource','ZDataSource'};
datasrcLimitNames = {'XLim','YLim','ZLim'};

varList1D = {};
varList2D = {};
% Class variables below are used to filter varList1D and varList2D
varList1DClasses = {};
varList2DClasses = {};
count = 1;
for k=1:length(varContents)
    varclass = varContents(k).class;
        
    if any(strcmp(varclass,{'double','datetime','calendarduration','duration','categorical'}))...
            && prod(varContents(k).size)>1 && length(varContents(k).size)==2
        if min(varContents(k).size)==1
            varList1D = [varList1D;{varContents(k).name}]; %#ok<AGROW>
            varList1DClasses = [varList1DClasses;{varclass}]; %#ok<AGROW>
            count = count+1;
        else
            % For arrays only include array(:,1), array(:,end),
            % array(1,:), and array(end,:) in XDataSource and
            % YDataSource combo boxes to avoid the popup list from
            % becoming excessively long
            varList1D = [varList1D;...
                {sprintf('%s(:,1)',varContents(k).name)};...
                {sprintf('%s(:,end)',varContents(k).name)};...
                {sprintf('%s(1,:)',varContents(k).name)};...
                {sprintf('%s(end,:)',varContents(k).name)};]; %#ok<AGROW>
            varList1DClasses = [varList1DClasses;repmat({varclass},[4 1])]; %#ok<AGROW>
            varList2D = [varList2D;{varContents(k).name}]; %#ok<AGROW>
            varList2DClasses = [varList2DClasses;{varclass}]; %#ok<AGROW>
            count = count+5;
        end
    end
    % Avoid the size of the combo box popup from becoming
    % excessive
    if count>100
        break
    end
end
dataSourceTableData = DataSourceDialog.createSourceDialogTableEntryArray(length(ls),length(datasrcPropNames),' ');
for k=1:length(ls)
    ax = ancestor(ls(k),'matlab.graphics.axis.AbstractAxes');
    if ~isempty(hggetbehavior(ls(k),'linked','-peek'))
        linkBehavior = hggetbehavior(ls(k),'linked');
        if linkBehavior.UsesXDataSource      
            I = strcmp(getLimitClass(ax, 'XLim'),varList1DClasses);
            if any(I)
                dataSourceTableData(k,1).addContent(varList1D(I));
            end
            dataSourceTableData(k,1).setCurrentValue(linkBehavior.XDataSource);
        else
            dataSourceTableData(k,1) = [];
        end
        if linkBehavior.UsesYDataSource
            I = strcmp(getLimitClass(ax, 'YLim'),varList1DClasses);
            if any(I)
                dataSourceTableData(k,2).addContent(varList1D(I));
            end
            dataSourceTableData(k,2).setCurrentValue(linkBehavior.YDataSource);
        else
            dataSourceTableData(k,2) = [];
        end
        if linkBehavior.UsesZDataSource
            I = strcmp(getLimitClass(ax, 'ZLim'),varList1DClasses);
            if any(I)
                dataSourceTableData(k,3).addContent(varList1D(I));
            end
            dataSourceTableData(k,3).setCurrentValue(linkBehavior.ZDataSource);
        else
            dataSourceTableData(k,3) = [];
        end
    else
        for j=1:length(datasrcPropNames)
            if ishghandle(ls(k),'surface') || ishghandle(ls(k),'contour')
                % If this row is a surface or contour and the column is ZData,
                % then replace the vectors in the data source combo
                % box by matrices. For XDataSource and YDataSource
                % add the matrix values to the combo box entries.
                
                % Only add variables where the class matches the
                % call of the ruler limits. This ensure that for
                % datetime/duration/caregorical/... only matching
                % variable types are listed     
                I = strcmp(getLimitClass(ax, datasrcLimitNames{j}),varList2DClasses);
                if any(I)
                    dataSourceTableData(k,j).addContent(varList2D(I));
                end
                if ~strcmp(datasrcPropNames{j},'ZDataSource')
                    I = strcmp(getLimitClass(ax, datasrcLimitNames{j}),varList1DClasses);
                    if any(I)
                        dataSourceTableData(k,j).addContent(varList1D(I));
                    end
                end
            else
                % Only add variables where the class matches the
                % class of the ruler limits. This ensure that for
                % datetime/duration/caregorical/... only matching
                % variable types are listed
                I = strcmp(getLimitClass(ax, datasrcLimitNames{j}),varList1DClasses);
                if any(I)
                    dataSourceTableData(k,j).addContent(varList1D(I));
                end
            end
            if ~isempty(ls(k).findprop(datasrcPropNames{j}))
                dataSourceTableData(k,j).setCurrentValue(get(ls(k),datasrcPropNames{j}));
            else
                dataSourceTableData(k,j) = [];
            end
        end
    end
end

function className = getLimitClass(ax, limitProp)

% Find the class name of the specified limit. Used to detect the ruler type
if isprop(ax,limitProp)
    className = class(ax.(limitProp));
else
    className = class(ax.DataSpace.(limitProp));
end