function treenode = createTreeNode(dispName, infoStruct, tree, description, icon, leaf)
%CREATETREENODE Construct an UITREENODE, storing associated data.
%   The data can be retrieved from the uitreenode after it is
%   returned from the uitree.
%
%   Function arguments
%   ------------------
%     DISPLAYNAME: the name that will be displayed in the tree.
%     NODEINFOSTRUCT: the structrue that contains the HDF node info..
%     TREE: the fileTree which contains this node.
%     DESCRIPTION: The name of the node in the tree.
%     ICON: the path of the icon that is to be used for this node.
%     LEAF: a boolean value that indicates it this node is a leaf.

%   Copyright 2005-2013 The MathWorks, Inc.

% Node Types:
%     "File Tree" - has empty infoStruct, we never see it.  File
%                   information is not in scope here. 
%     
%     "File"      - infoStruct is the full output of HDFINFO.  This is
%                   visually represented by the name of the file in the
%                   left-hand side UITREE.
%
%     "View"      - infoStruct will have the global attributes.  "value"
%                   will be wither "View as HDF" or "View as HDF-EOS"
%
%     Datatypes   - "Scientific Data Set", "Vdata set', 
%                   "8-Bit Raster Image", "Vgroup", "24-Bit Raster Image", 
%                   'HDF-EOS Grid', 'HDF-EOS Point', 'HDF-EOS', 
%                   'HDF-EOS Grid Data Fields', 'HDF-EOS Point Data Fields',
%                   'HDF-EOS Swath Data Fields', 
%                   'HDF-EOS Swath Geolocation Fields'

    

    if strcmp(class(tree),'hdftool.fileframe')
        
        % Ok, this is the very first time through.  
        theFrame = tree;
		% Special key for this objMap.  All other times, this key would be
		% a filename. 
        fullfilepath = 'File Tree';
        
        % Create the map for the file objects, plus the top-level fileTree.
        fileMap = containers.Map('KeyType','char','ValueType','any');
        
    else
        theFrame = get(tree,'fileFrame');
        fullfilepath = get(tree,'fullpath');
        fileMap = get(theFrame,'fileMap');
    end

    % Create a key by which we can retrieve needed data for this node via a
    % hash table.
    theKey = create_unique_key(dispName,fullfilepath,infoStruct);
        
    % Does this file have an entry in the overall file map?  There are two
    % ways this could happen.  Either this is the first time through and we
    % have an hdftool.fileframe, in which case the fileMap is empty, or we
    % are hitting this file for the first time.
    if isa(tree,'hdftool.fileframe') || ...
            (isfield(infoStruct,'NodeType') && strcmp(infoStruct.NodeType,'File'))
        % First time through or we have a new file.  Either way, we construct
        % a new map.
        fileMap(theKey) = containers.Map;
    	set(theFrame,'fileMap',fileMap);   %%% ???
        objMap = fileMap(theKey);
    else
        % The file must already be accounted for.  Retrieve the 
        % corresponding map.
        objMap = fileMap(fullfilepath);
    end



    % Store the node information necessary for closeFile and
    % nodeCallBack.
    s.displayname = dispName;
    s.nodeinfostruct = infoStruct;
    s.tree = tree;
    objMap(theKey) = s;


    %set(theFrame,'fileMap',fileMap);
    

    % Create a UITREENODE, and store associated data.
    treenode = uitreenode('v0', theKey, description, icon, leaf);

end

function theKey = create_unique_key(displayname,filefullpath,infoStruct)
    
    if strcmp(displayname,'File Tree')
        theKey = [displayname '::'];
    elseif isfield(infoStruct,'NodeType')
        
        % Must create a key that uniquely identifies the associated
        % treenode.
        switch(infoStruct.NodeType)
            case 'File'
                theKey = sprintf('%s', filefullpath);
            case {'8-Bit Raster Image', '24-Bit Raster Image', 'Scientific Data Set', 'Vdata set'}
                theKey = sprintf('%s::%s::%s', filefullpath, infoStruct.NodeType, infoStruct.NodePath);
            case 'Vgroup'
                theKey = sprintf('%s::%d::%d', filefullpath, infoStruct.Tag, infoStruct.Ref);
            case 'View'
                theKey = sprintf('%s::%s::%s', filefullpath, infoStruct.NodeType, infoStruct.NodeViewType);
            case {'HDF-EOS Grid', 'HDF-EOS Point', 'HDF-EOS Swath'}
                theKey = sprintf('%s::%s::%s', filefullpath, infoStruct.NodeType, infoStruct.Name);
            case {'HDF-EOS Grid Data Fields', 'HDF-EOS Point Data Fields', ...
                    'HDF-EOS Swath Data Fields', 'HDF-EOS Swath Geolocation Fields'}
                theKey = sprintf('%s::%s::%s::%s', filefullpath, infoStruct.NodeType, displayname, infoStruct.NodePath);
            otherwise
                error(message('MATLAB:imagesci:hdftool:unrecognizedNodeType', infoStruct.NodeType));
        end
    else
        error(message('MATLAB:imagesci:hdftool:unrecognizedTreeNodeConfiguration', displayname));

    end
        

end
