function this = hdftree(fileFrame, treeHandle, filename)
%HDFTREE Construct an HDFTREE that displays an HDF file.
%
%   Function arguments
%   ------------------
%   FILEFRAME: the fileFrame container.
%   TREEHANDLE: the handle of the UITree.
%   FILENAME: the name of the file to open.

%   Copyright 2005-2017 The MathWorks, Inc.


    this = hdftool.hdftree;
    this.fileFrame  = fileFrame;
    this.treeHandle = treeHandle;
    this.filename   = filename;

    % Store the complete path to the file.
    fid = fopen(filename);
    this.fullpath = fopen(fid);
    fclose(fid);

    this.iconPath = fullfile(matlabroot,'toolbox','matlab','icons');
    this.bHDFEOS = addFile(this, filename);

end


function bHDFEOS = addFile(this, filename)
% Add a file by populating the HDF tree with nodes.

    % THe field IDs are:
    %   Vgroup              1
    %   SDS                 2
    %   Vdata               3
    %   Raster8             4
    %   Raster24            5
    %   Point               6
    %   Grid                7
    %   Swath               8
    %   DataField           9
    %   Geolocation         10

    % Get the data from the file
    info = hdfinfo(filename);
    eosInfo = hdfinfo(filename, 'eos');
    eosCheck = [isfield(eosInfo,'Grid'),...
        isfield(eosInfo,'Point'),...
        isfield(eosInfo,'Swath')];
    if any(eosCheck,2)
        bHDFEOS = true;
    else
        bHDFEOS = false;
    end

    % create the tree
    virtualRootNode = get(this.treeHandle,'Root');
    rootNode = createFileNode(this, info, this.treeHandle, virtualRootNode);

    if bHDFEOS
        viewNode = createViewNode(this, info, this.treeHandle, rootNode, 'HDF');
        [~, hasAnon] = buildtree(this, '/', info, viewNode, this.treeHandle);
        viewNode = createViewNode(this, info, this.treeHandle, rootNode, 'EOS');
        buildtree(this, '/', eosInfo, viewNode, this.treeHandle);
    else
        [~, hasAnon] = buildtree(this, '/', info, rootNode, this.treeHandle);
    end
    this.treeHandle.expand(rootNode);

    if (hasAnon)
        warndlg(...
            getString(message('MATLAB:imagesci:hdftool:zeroLengthVdataNames',filename)), ...
            getString(message('MATLAB:imagesci:hdftool:warningTitle')));
    end

end

%======================================================================
function [rootNode, treeHasAnon] = buildtree(this, nodePath, info, rootNode, hdfTree)

    treeHasAnon = false;

    fieldNames = fieldnames(info);
    for i = 1:length(fieldNames)
        switch fieldNames{i}
            case 'Vgroup'
                [newNode, nodeHasAnon] = createVgroupNode(this, ...
                                             nodePath, hdfTree, info.Vgroup);
                treeHasAnon = treeHasAnon || nodeHasAnon;
            case 'SDS'
                newNode = createSDSNode(this, nodePath, info.SDS);
            case 'Vdata'
                [newNode, nodeHasAnon] = createVdataNode(this, ...
                                             nodePath, info.Vdata);
                treeHasAnon = treeHasAnon || nodeHasAnon;
            case 'Raster8'
                newNode = createRaster8Node(this, nodePath, info.Raster8);
            case 'Raster24'
                newNode = createRaster24Node(this, nodePath, info.Raster24);
            case 'Point'
                newNode = createPointNode(this, nodePath, hdfTree, info.Point);
            case 'Grid'
                newNode = createGridNode(this, nodePath, hdfTree, info.Grid);
            case 'Swath'
                newNode = createSwathNode(this, nodePath, hdfTree, info.Swath);
            otherwise
                newNode = [];
        end

        if ~isempty(newNode)
            addToTree(hdfTree, rootNode, newNode);
        end
    end
end

%======================================================================
function rootNode = createFileNode(this, infoStruct, hdfTree, virtualRootNode)
    %Create node for an HDF File
    [~,fileName,ext] = fileparts(this.filename);
    fn = [fileName,ext];
    istruct.NodeType = 'File';
    icon = fullfile(this.iconPath, 'HDF_filenew.gif');
    if isfield(infoStruct, 'Attributes')
        istruct.Attributes = infoStruct.Attributes;
    end
    rootNode = hdftool.createTreeNode(fn,...
        istruct,...
        this,...
        fn, icon, false);
    addToTree(hdfTree, virtualRootNode, rootNode);
end

%======================================================================
function rootNode = createViewNode(this, infoStruct, hdfTree, virtualRootNode, type)
    % Create a View node for an HDFEOS File
    [~,fileName,ext] = fileparts(this.filename);
    fn = [fileName,ext];
    istruct.NodeType = 'View';
    istruct.NodeViewType = type;
    istruct.Attributes = infoStruct.Attributes;
    if strcmp(type, 'HDF')
        icon = fullfile(this.iconPath, 'HDF_object01.gif');
		title = [getString(message('MATLAB:imagesci:hdftool:viewAs')) ' HDF'];
    else
        icon = fullfile(this.iconPath, 'HDF_object02.gif');
		title = [getString(message('MATLAB:imagesci:hdftool:viewAs')) ' EOS'];
    end
    rootNode = hdftool.createTreeNode(fn,...
        istruct,...
        this,...
        title, icon, false);
    addToTree(hdfTree, virtualRootNode, rootNode);
end

%======================================================================
function sdsNode = createSDSNode(this, nodePath, sdsStruct)
    %Create node for a Scientific Data Set

    len = length(sdsStruct);
    if len == 0
        sdsNode = [];
        return
    end

    nodeIcon = fullfile(this.iconPath,'HDF_SDS.gif');
    for n = 1:len
        sdsStruct(n).NodeType = 'Scientific Data Set';
        sdsStruct(n).NodePath = [nodePath sdsStruct(n).Name];
        sdsNode(n) = hdftool.createTreeNode(sdsStruct(n).Name,...
            sdsStruct(n),...
            this,...
            sdsStruct(n).Name, nodeIcon, true); %#ok<AGROW>
    end
end

%======================================================================
function [vdataNode, hasAnon] = createVdataNode(this, nodePath, vdataStruct)

    % By default assume Vdata is named.
    hasAnon = false;

    len = length(vdataStruct);
    if len == 0
        vdataNode = [];
        return
    end

    nodeIcon = fullfile(this.iconPath,'HDF_VData.gif');
    for n = 1:len
        vdataStruct(n).NodeType = 'Vdata set';
        vdataStruct(n).NodePath = [nodePath vdataStruct(n).Name];
        if (numel(vdataStruct(n).Name) == 0)
            % Unnamed Vdata.
            hasAnon = true;
			anon_name = getString(message('MATLAB:imagesci:hdftool:anonVdataRefNum',num2str(vdataStruct(n).Ref)));
            vdataNode(n) = hdftool.createTreeNode( vdataStruct(n).Name, ...
                                                   vdataStruct(n),...
                                                   this,...
                                                   anon_name, nodeIcon, true); %#ok<AGROW>
        else
            % Named Vdata.
            vdataNode(n) = hdftool.createTreeNode(vdataStruct(n).Name,...
                                                  vdataStruct(n),...
                                                  this,...
                                                  vdataStruct(n).Name, nodeIcon, true); %#ok<AGROW>
        end
    end

end

%======================================================================
function [vgroupNode, hasAnon] = createVgroupNode(this, nodePath, hdfTree, vgroupStruct)

    hasAnon = false;

    len = length(vgroupStruct);
    if len == 0
        vgroupNode = [];
        return
    end

    nodeIcon = fullfile(this.iconPath,'HDF_VGroup.gif');
    for n = 1:len
        istruct = vgroupStruct(n);
        istruct.Vgroup = [];
        istruct.NodeType = 'Vgroup';
        vgroupNode(n) = hdftool.createTreeNode(vgroupStruct(n).Name,...
            istruct,...
            this,...
            vgroupStruct(n).Name, nodeIcon, false); %#ok<AGROW>

        newNodePath = [nodePath vgroupStruct(n).Name '/'];
        [~, hasAnon] = buildtree(this, newNodePath, ...
                                    vgroupStruct(n), vgroupNode(n), hdfTree);
        if (get(vgroupNode(n),'ChildCount') == 0)
            set(vgroupNode(n),'LeafNode',true);
        end
    end
end

%======================================================================
function raster8Node = createRaster8Node(this, nodePath, raster8Struct)

    len = length(raster8Struct);
    if len == 0
        raster8Node = [];
        return
    end

    nodeIcon = fullfile(this.iconPath,'HDF_rasterimage.gif');
    for n = 1:len
        raster8Struct(n).NodeType = '8-Bit Raster Image';
        raster8Struct(n).NodePath = [nodePath raster8Struct(n).Name];
        raster8Node(n) = hdftool.createTreeNode(raster8Struct(n).Name,...
            raster8Struct(n),...
            this,...
            raster8Struct(n).Name, nodeIcon, true); %#ok<AGROW>
    end
end

%======================================================================
function raster24Node = createRaster24Node(this, nodePath, raster24Struct)

    len = length(raster24Struct);
    if len == 0
        raster24Node = [];
    end

    nodeIcon = fullfile(this.iconPath,'HDF_rasterimage.gif');
    for n = 1:len
        raster24Struct(n).NodeType = '24-Bit Raster Image';
        raster24Struct(n).NodePath = [nodePath raster24Struct(n).Name];
        raster24Node(n) = hdftool.createTreeNode(raster24Struct(n).Name,...
            raster24Struct(n),...
            this,...
            raster24Struct(n).Name, nodeIcon, true); %#ok<AGROW>
    end
end

%======================================================================
function gridNode = createGridNode(this, nodePath, hdfTree, gridStruct)

    len = length(gridStruct);
    if len == 0
        gridNode = [];
        return
    end

    nodeIcon     = fullfile(this.iconPath,'HDF_grid.gif');
    nodeIconSub  = fullfile(this.iconPath,'HDF_gridfieldset.gif');
    for n = 1:len
        istruct = gridStruct(n);
        istruct.DataFields = [];
        istruct.NodeType = 'HDF-EOS Grid';
        gridNode(n) = hdftool.createTreeNode(gridStruct(n).Name,...
            istruct,...
            this,...
            gridStruct(n).Name,nodeIcon,isempty(gridStruct(n).DataFields)); %#ok<AGROW>

        numberOfFields = length(gridStruct(n).DataFields);
        verticalSubsets = findVerticalSubsets(istruct);
        for k=1:numberOfFields
            gridStruct(n).DataFields(k).NodeType = 'HDF-EOS Grid Data Fields';
            gridStruct(n).DataFields(k).NodePath = [nodePath gridStruct(n).DataFields(k).Name];
            if ~isempty(verticalSubsets)
                gridStruct(n).DataFields(k).vertical = verticalSubsets{k,2};
            end
            dataFieldNode{n}(k) = hdftool.createTreeNode(gridStruct(n).Name,...
                gridStruct(n).DataFields(k),...
                this,...
                gridStruct(n).DataFields(k).Name,nodeIconSub,true); %#ok<AGROW>
        end

        if numberOfFields > 0
            addToTree(hdfTree, gridNode(n), dataFieldNode{n});
        end
    end
end

%======================================================================
function pointNodes = createPointNode(this, nodePath, hdfTree, pointStruct)

    len = length(pointStruct);
    if len == 0
        pointNodes = [];
        return
    end

    nodeIcon     = fullfile(this.iconPath,'HDF_point.gif');
    nodeIconSub = fullfile(this.iconPath,'HDF_pointfieldset.gif');
    levelNodes = cell(1,len);
    for n = 1:len
        pointStruct(n).NodeType = 'HDF-EOS Point';
        pointNodes(n) = hdftool.createTreeNode(pointStruct(n).Name,...
            pointStruct(n),...
            this,...
            pointStruct(n).Name, nodeIcon, isempty(pointStruct(n).Level)); %#ok<AGROW>

        numOfLevels = length(pointStruct(n).Level);
        for k = 1:numOfLevels
            pointStruct(n).Level(k).NodeType = 'HDF-EOS Point Data Fields';
            pointStruct(n).Level(k).NodePath = [nodePath pointStruct(n).Level(k).Name];
            levelNodes{n}(k) = hdftool.createTreeNode(pointStruct(n).Name,...
                pointStruct(n).Level(k),...
                this,...
                pointStruct(n).Level(k).Name, nodeIconSub,true);
        end

        if (numOfLevels > 0)
            addToTree(hdfTree, pointNodes(n), levelNodes{n});
        end
    end
end

%======================================================================
function swathNode = createSwathNode(this, nodePath, hdfTree, swathStruct)

    len = length(swathStruct);
    if len == 0
        swathNode = [];
        return
    end

    nodeIcon = fullfile(this.iconPath,'HDF_swath.gif');

    for n = 1:len
        istruct = swathStruct(n);
        istruct.DataFields = [];
        istruct.NodeType = 'HDF-EOS Swath';
        swathNode(n) = hdftool.createTreeNode(swathStruct(n).Name,...
            istruct,...
            this,...
            swathStruct(n).Name, nodeIcon, false); %#ok<AGROW>

        dataFieldsNode = createDataFieldsNode(this, nodePath, hdfTree, swathStruct(n));
        geolocationNode = createGeolocationNode(this, nodePath, hdfTree, swathStruct(n));

        addToTree(hdfTree, swathNode(n), dataFieldsNode);
        addToTree(hdfTree, swathNode(n), geolocationNode);
    end
end

%==========================================================================
function dfNode = createDataFieldsNode(this, nodePath, hdfTree, swathStructElem)

    nodeIconGroup = fullfile(this.iconPath,'HDF_VGroup.gif');
    nodeIconSub = fullfile(this.iconPath,'HDF_swathfieldset.gif');

    swathStructElem.NodeType = 'HDF-EOS Swath';
    dfNode = hdftool.createTreeNode('Data Fields',...
        swathStructElem, ...
        this,...
        'Data Fields', nodeIconGroup,isempty(swathStructElem.DataFields));

    dfLen = length(swathStructElem.DataFields);
    if dfLen == 0
        return
    end
    
    verticalSubsets =  findVerticalSubsets(swathStructElem);
    for k=1:dfLen
        swathStructElem.DataFields(k).NodeType = 'HDF-EOS Swath Data Fields';
        swathStructElem.DataFields(k).NodePath = [nodePath swathStructElem.DataFields(k).Name];
        if ~isempty(verticalSubsets)
            swathStructElem.DataFields(k).vertical = verticalSubsets{k,2};
        end
        dfSubNode(k) = hdftool.createTreeNode(swathStructElem.Name,...
            swathStructElem.DataFields(k),...
            this,...
            swathStructElem.DataFields(k).Name, nodeIconSub,true); %#ok<AGROW>
    end
    addToTree(hdfTree, dfNode, dfSubNode);
end

%==========================================================================
function glNode = createGeolocationNode(this, nodePath, hdfTree, swathStructElem)

    nodeIcon = fullfile(this.iconPath,'HDF_VGroup.gif');
    nodeIconSub = fullfile(this.iconPath,'HDF_swathfieldset.gif');

    swathStructElem.NodeType = 'HDF-EOS Swath';
    glNode = hdftool.createTreeNode('Geolocation Fields',...
        swathStructElem,...
        this,...
        'Geolocation Fields', nodeIcon, isempty(swathStructElem.GeolocationFields));

    glLen = length(swathStructElem.GeolocationFields);

    if glLen == 0
        return
    end

    for k=1:glLen
        swathStructElem.GeolocationFields(k).NodeType = 'HDF-EOS Swath Geolocation Fields';
        swathStructElem.GeolocationFields(k).NodePath = [nodePath swathStructElem.GeolocationFields(k).Name];
        glSubNode(k) = hdftool.createTreeNode(swathStructElem.Name,...
            swathStructElem.GeolocationFields(k),...
            this,...
            swathStructElem.GeolocationFields(k).Name, nodeIconSub,true); %#ok<AGROW>

    end
    addToTree(hdfTree, glNode, glSubNode);
end

%==========================================================================
function match = findVerticalSubsets(info)
% Returns a cell array.  The cell array has as many rows as the number of
% fields in the Swath or Grid.  The first column is the field name.  The
% Rest of the columns are other fields that have the following
% characteristics:
%   1.  Field has 1 dimension
%   2.  Field is int16, int32, float, or double
%   3.  A common dimension name
% In addition, to qualify as a possible vertical subset, the field must
% be monotonic, but this function does not check for this.

    if ~isempty(info.DataFields)
        datafieldsRank1   = info.DataFields([info.DataFields.Rank]==1);
    else
        datafieldsRank1 = [];
    end
    if isfield(info,'GeolocationFields') && ~isempty(info.GeolocationFields)
        if ~isempty(datafieldsRank1)
            dataVrtFields = datafieldsRank1(strcmp({datafieldsRank1.NumberType},'int16') |...
                strcmp({datafieldsRank1.NumberType},'int32') |...
                strcmp({datafieldsRank1.NumberType},'float') |...
                strcmp({datafieldsRank1.NumberType},'double'));
        else
            dataVrtFields = [];
        end
        geolocfieldsRank1 = info.GeolocationFields([info.GeolocationFields.Rank]==1);
        if ~isempty(geolocfieldsRank1)
            geoVrtFields = geolocfieldsRank1(strcmp({geolocfieldsRank1.NumberType},'int16') |...
                strcmp({geolocfieldsRank1.NumberType},'int32') |...
                strcmp({geolocfieldsRank1.NumberType},'float') |...
                strcmp({geolocfieldsRank1.NumberType},'double'));
        else
            geoVrtFields = [];
        end
        possibleVrtFields = [dataVrtFields ; geoVrtFields];
    else
        if ~isempty(datafieldsRank1)
            dataVrtFields = datafieldsRank1(strcmp({datafieldsRank1.NumberType},'int16') |...
                strcmp({datafieldsRank1.NumberType},'int32') |...
                strcmp({datafieldsRank1.NumberType},'float') |...
                strcmp({datafieldsRank1.NumberType},'double'));
        else
            dataVrtFields = [];
        end
        possibleVrtFields = dataVrtFields;
    end

    match = cell(numel(info.DataFields),2);
    for i=1:length(info.DataFields)
        match{i,1} = info.DataFields(i).Name;
        match{i,2} = '';
        count=2;
        for j=1:length(possibleVrtFields)
            if ((any(strcmp(possibleVrtFields(j).Dims.Name, ...
                    {info.DataFields(i).Dims.Name}))) && ...
                    (~strcmp(possibleVrtFields(j).Name, ...
                    info.DataFields(i).Name)))
                match{i,count} = possibleVrtFields(j).Name;
                count = count+1;
            end
        end
    end

    if isfield(info,'GeolocationFields')
        for i=1:length(info.GeolocationFields)
            match{i+length(info.DataFields),1} = info.GeolocationFields(i).Name;
            count=2;
            for j=1:length(possibleVrtFields)
                if ((any(strcmp(possibleVrtFields(j).Dims.Name, ...
                        {info.GeolocationFields(i).Dims.Name}))) && ...
                        (~strcmp(possibleVrtFields(j).Name, ...
                        info.GeolocationFields(i).Name)))
                    match{i+length(info.DataFields),count} = possibleVrtFields(j).Name;
                    count = count+1;
                end
            end
        end
    end
end

%==========================================================================
function addToTree(tree, root, child)
    if numel(child) > 1
        tree.add(root, child);
    else
        ja = javaArray('com.mathworks.hg.peer.UITreeNode',1);
        ja(1) = java(child);
        tree.add(root, ja);
    end
end



