function displayNodeInfo(this, selectedNode, parentNode)
%DISPLAYNODEINFORMATION Displays node information.
%   In particular, node information is displayed in the lower right panel
%   in response to selection of that node by the user.
%
%   Function arguments
%   ------------------
%   THIS: the fileTree object instance.
%   SELECTEDNODE: the selected fileTree node.
%   PARENTNODE: the parent of the selected fileTree node.
%   TREE: the UITree object.

%   Copyright 2005-2013 The MathWorks, Inc.

    % Get the STRUCTURE associated with the node
    infoStruct = selectedNode.nodeinfostruct;

    parentStruct = parentNode.nodeinfostruct;

    frame = this.fileFrame;
    lowerRightPanel = frame.lowerRightPanel;

    % Determine the type of node this is
    type = infoStruct.NodeType;

    switch (type)
        case 'File'
            displayFile
        case 'View'
            displayView
        case 'Vgroup'
            displayVgroup
        case 'Scientific Data Set'
            displaySDS
        case 'Vdata set'
            displayVdata
        case '8-Bit Raster Image'
            displayRaster8
        case '24-Bit Raster Image'
            displayRaster24
        case 'HDF-EOS Point'
            displayPoint
        case 'HDF-EOS Point Data Fields'
            displayPointDataFields
        case 'HDF-EOS Grid'
            displayGrid
        case 'HDF-EOS Grid Data Fields'
            displayGridDataField
        case 'HDF-EOS Swath'
            displaySwath
        case 'HDF-EOS Swath Data Fields'
            displaySwathDataField
        case 'HDF-EOS Swath Geolocation Fields'
            displayGeolocation
        otherwise
            displayDefault
    end

    %======================================================================
    function displayFile

        metadataText = getNameMetaData;
        metadataText = strrep(metadataText, sprintf('\n'), '<br>');
        metadataText = strrep(metadataText, sprintf('\t'), '&nbsp;');

        if isfield(selectedNode.nodeinfostruct, 'Attributes')
            moreText = getAttributesMetaData(selectedNode.nodeinfostruct);
            metadataText = [metadataText moreText];
        end
        
        frame.setMetadataText(metadataText);
        frame.setDatapanel('default', selectedNode);
    end

    %======================================================================
    function displayView
        metadataText = getNameMetaData;

        if isfield(infoStruct,'Attributes')
            attrLen = length(infoStruct.Attributes);
            for n = 1:attrLen
                metadataText = addMetadataField(metadataText,...
                    infoStruct.Attributes(n).Name,...
                    num2str(infoStruct.Attributes(n).Value));
            end
        end
        metadataText = strrep(metadataText, sprintf('\n'), '<br>');
        metadataText = strrep(metadataText, sprintf('\t'), '&nbsp;&nbsp;&nbsp;&nbsp;');

        frame.setMetadataText(metadataText);
        if strcmp(infoStruct.NodeViewType, 'EOS')
			viewStr = [getString(message('MATLAB:imagesci:hdftool:viewAs')) ' HDF-EOS'];
        else
			viewStr = [getString(message('MATLAB:imagesci:hdftool:viewAs')) ' HDF'];
        end
        frame.setDatapanel(viewStr, selectedNode);
    end

    %======================================================================
    function displayVgroup
        metadataText = getNameMetaData;
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:class')), infoStruct.Class);
        frame.setMetadataText(metadataText);
        frame.setDatapanel('HDF Vgroup', selectedNode);
    end

    %======================================================================
    function displayVdata
        metadataText = getNameMetaData;
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:class')), infoStruct.Class);
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:numberOfRecords')), num2str(infoStruct.NumRecords));
        frame.setMetadataText(metadataText);

        if isempty(this.staticVdataPanel)
            this.staticVdataPanel = hdftool.vdatapanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticVdataPanel, selectedNode);
    end

    %======================================================================
    function displaySDS
        % set the metadata
        metadataText = getNameMetaData;
        metadataText = sprintf('%s%s<br>',...,
            metadataText, getDimensionMetaData(infoStruct));
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:precision')), infoStruct.DataType);
        metadataText = sprintf('%s%s',...
            metadataText, getAttributesMetaData(infoStruct));
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticSdsPanel)
            this.staticSdsPanel = hdftool.sdspanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticSdsPanel, selectedNode);
    end

    %======================================================================
    function displayRaster8
        % set the metadata
        metadataText = getNameMetaData;
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:width')), num2str(infoStruct.Width));

        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:height')), num2str(infoStruct.Height));

        trueFalse = {'false','true'};
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:colormap')), trueFalse{infoStruct.HasPalette+1});
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticRasterPanel)
            this.staticRasterPanel = hdftool.rasterpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticRasterPanel, selectedNode);
    end

    %======================================================================
    function displayRaster24
        % set the metadata
        metadataText = getNameMetaData;
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:bitDepth')), '24');
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:width')), num2str(infoStruct.Width));
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:height')), num2str(infoStruct.Height));
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:interlace')), infoStruct.Interlace);
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticRasterPanel)
            this.staticRasterPanel = hdftool.rasterpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticRasterPanel, selectedNode);
    end

    %======================================================================
    function displayPoint
        % Set the metadata
        metadataText = getNameMetaData;
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticPointPanel)
            this.staticPointPanel = hdftool.pointpanel(this, lowerRightPanel);
        end
        frame.setDatapanel('HDF-EOS Point', selectedNode);
    end

    %======================================================================
    function displayPointDataFields
        % Set the metadata
        metadataText = getNameMetaData;
        % get Point Meta Data
        metadataText = addMetadataField(...
            metadataText, getString(message('MATLAB:imagesci:hdftool:numberOfRecords')), num2str(infoStruct.NumRecords));
        % get Attributes Meta Data
        pointInfo = getParentStruct;
        metadataText = sprintf('%s%s',...
            metadataText, getAttributesMetaData(pointInfo));
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticPointPanel)
            this.staticPointPanel = hdftool.pointpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticPointPanel, selectedNode);
    end

    %======================================================================
    function displayGrid
    
    	if ( isempty(infoStruct.Projection.ProjCode) ...
                && isempty(infoStruct.Projection.ZoneCode) ...
                && isempty(infoStruct.Projection.SphereCode) ...
                && isempty(infoStruct.Projection.ProjParam) )
        	frame.setMetadataText('');
            msg = getString(message('MATLAB:imagesci:hdftool:invalidProjection'));
            msgTitle = getString(message('MATLAB:imagesci:hdftool:invalidProjectionTitle'));
	    	errordlg(msg, msgTitle);
		else
        	% Set the metadata
	        metadataText = getNameMetaData;
			% get Attributes Meta Data
			metadataText = [metadataText, getAttributesMetaData(infoStruct)];
			% get Grid Meta Data
			metadataText = [metadataText, getGridMetaData(infoStruct)];
			frame.setMetadataText(metadataText);
	    end

        % set the panel
        if isempty(this.staticGridPanel)
            this.staticGridPanel = hdftool.gridpanel(this, lowerRightPanel);
        end
        frame.setDatapanel('HDF-EOS Grid', selectedNode);
    end

    %======================================================================
    function displayGridDataField
        % Set the metadata
        metadataText = getNameMetaData;
        % get Dimension Metadata
        metadataText = [metadataText, getDimensionMetaData(infoStruct) '<br>'];
        % get Tile Dimension Metadata
        metadataText = [metadataText, getTileDimMetaData(infoStruct)];
        % get Attributes Metadata
        gridInfo = getParentStruct;
        metadataText = [metadataText, getAttributesMetaData(gridInfo)];
        % get Grid Metadata
        metadataText = [metadataText, getGridMetaData(gridInfo)];
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticGridPanel)
            this.staticGridPanel = hdftool.gridpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticGridPanel, selectedNode);
    end

    %======================================================================
    function metadataText = getGridMetaData(tmpStruct)
        metadataText = addMetadataField('',...
            getString(message('MATLAB:imagesci:hdftool:upperLeftGridCorner')),  num2str(tmpStruct.UpperLeft));
        metadataText = addMetadataField(metadataText,...
            getString(message('MATLAB:imagesci:hdftool:lowerRightGridCorner')), num2str(tmpStruct.LowerRight));
        metadataText = addMetadataField(metadataText,...
            getString(message('MATLAB:imagesci:hdftool:rows')),                 num2str(tmpStruct.Rows));
        metadataText = addMetadataField(metadataText,...
            getString(message('MATLAB:imagesci:hdftool:columns')),              num2str(tmpStruct.Columns));
        metadataText = addMetadataField(metadataText,...
            getString(message('MATLAB:imagesci:hdftool:projection')),           num2str(tmpStruct.Projection.ProjCode));
        metadataText = addMetadataField(metadataText,...
            getString(message('MATLAB:imagesci:hdftool:zoneCode')),             num2str(tmpStruct.Projection.ZoneCode));
        metadataText = addMetadataField(metadataText,...
            getString(message('MATLAB:imagesci:hdftool:sphere')),               getSphereFromCode(tmpStruct.Projection.SphereCode));
        projStr = getProjectionParams(tmpStruct.Projection.ProjCode,...
            tmpStruct.Projection.ProjParam);
        metadataText = sprintf('%s%s', metadataText,projStr);
        metadataText = addMetadataField(metadataText,...
            getString(message('MATLAB:imagesci:hdftool:originCode')), tmpStruct.OriginCode);
        metadataText = addMetadataField(metadataText,...
            getString(message('MATLAB:imagesci:hdftool:pixelRegistrationCode')), tmpStruct.PixRegCode);
    end

    %======================================================================
    function metadataText = getTileDimMetaData(tmpStruct)
        tileDims = tmpStruct.TileDims;
        tileStr = getString(message('MATLAB:imagesci:hdftool:tileDimensions'));
        if isempty(tileDims)
            metadataText = addMetadataField('', tileStr, getString(message('MATLAB:imagesci:hdftool:noTiles')));
        else
            metadataText = addMetadataField('', tileStr, num2str(tileDims));
        end
    end

    %======================================================================
    function displaySwath
        % Set the metadata
        metadataText = getNameMetaData;
        % get the Map, Offset and Increment
        metadataText = [metadataText, getMapInfoMetaData(infoStruct)];
        % get the IdxMapInfo, Offset and Increment
        metadataText = [metadataText, getIdxMapInfoMetaData(infoStruct)];
        % get the attributes information
        metadataText = [metadataText, getAttributesMetaData(infoStruct)];
        frame.setMetadataText(metadataText);

        % set the panel
        frame.setDatapanel('HDF-EOS Swath', selectedNode);
    end

    %======================================================================
    function displaySwathDataField
        % Set the metadata
        metadataText = getNameMetaData;
        % get Dimension Meta Data
        metadataText = [metadataText getDimensionMetaData(infoStruct) '<br>'];
        % get MapInfo Meta Data
        swathInfo = getParentStruct;
        metadataText = [metadataText getMapInfoMetaData(swathInfo)];
        % get IdxMapInfo Meta Data
        metadataText = [metadataText getIdxMapInfoMetaData(swathInfo)];
        frame.setMetadataText(metadataText);

        % set the panel
        if isempty(this.staticSwathPanel)
            this.staticSwathPanel = hdftool.swathpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticSwathPanel, selectedNode);
    end

    %======================================================================
    function displayGeolocation
        % Set the metadata
        metadataText = getNameMetaData;
        % get Dimension Meta Data
        metadataText = [metadataText getDimensionMetaData(infoStruct) '<br>'];
        % get MapInfo Meta Data
        swathInfo = getParentStruct;
        metadataText = [metadataText getMapInfoMetaData(swathInfo)];
        % get IdxMapInfo Meta Data
        metadataText = [metadataText getIdxMapInfoMetaData(swathInfo)];
        frame.setMetadataText(metadataText);

        % Set the panel
        if isempty(this.staticSwathPanel)
            this.staticSwathPanel = hdftool.swathpanel(this, lowerRightPanel);
        end
        frame.setDatapanel(this.staticSwathPanel, selectedNode);
    end

    %======================================================================
    function displayDefault
        metadataText = getNameMetaData;
        frame.setMetadataText(metadataText);
        frame.setDatapanel('Unrecognized node type.', selectedNode);
    end

    %======================================================================
    function pStruct = getParentStruct
        pStruct = parentStruct;
    end

    %======================================================================
    function metadataText = getNameMetaData
        metadataText = addMetadataField('', 'Name', selectedNode.displayname);
    end

    %======================================================================
    function metadataText = getDimensionMetaData(tmpStruct)
        metadataText = sprintf('<b>%s: </b> <br>', getString(message('MATLAB:imagesci:hdftool:dimensions')));
        dimLen = length(tmpStruct.Dims);
        for n = 1:dimLen
            metadataText = addMetadataField(metadataText,...
                'Name',tmpStruct.Dims(n).Name);
            metadataText = addMetadataField(metadataText,...
                getString(message('MATLAB:imagesci:hdftool:size')), num2str(tmpStruct.Dims(n).Size));
        end
    end

    %======================================================================
    function metadataText = getMapInfoMetaData(tmpStruct)
        metadataText = '';
        mapLen = length(tmpStruct.MapInfo);
        for n = 1:mapLen
            metadataText = addMetadataField(metadataText,...
                getString(message('MATLAB:imagesci:hdftool:map')), tmpStruct.MapInfo(n).Map);
            metadataText = addMetadataField(metadataText,...
                getString(message('MATLAB:imagesci:hdftool:offset')), num2str(tmpStruct.MapInfo(n).Offset));
            metadataText = addMetadataField(metadataText,...
                getString(message('MATLAB:imagesci:hdftool:increment')), num2str(tmpStruct.MapInfo(n).Increment));
        end
    end

    %======================================================================
    function metadataText = getIdxMapInfoMetaData(tmpStruct)
        metadataText = '';
        idxLen = length(tmpStruct.IdxMapInfo);
        for n = 1:idxLen
            metadataText = addMetadataField(metadataText,...
                getString(message('MATLAB:imagesci:hdftool:indexMap')), tmpStruct.IdxMapInfo(n).Map);
            metadataText = addMetadataField(metadataText,...
                getString(message('MATLAB:imagesci:hdftool:indexSize')), num2str(tmpStruct.IdxMapInfo(n).Size));
        end
    end

    %======================================================================
    function metadataText = getAttributesMetaData(tmp)
        metadataText = '';
        attrLen = length(tmp.Attributes);
        for n = 1:attrLen
            metadataText = addMetadataField(metadataText,...
                tmp.Attributes(n).Name, num2str(tmp.Attributes(n).Value));
        end

    end

end

%======================================================================
function s = getSphereFromCode(sphereCode)

    codes = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21];

    i = find(codes==sphereCode);
    if ~isempty(i)
        s = matlab.io.hdfeos.gd.sphereCodeToName(codes(i));
    else
        s = getString(message('MATLAB:imagesci:hdftool:unknownSphere'));
    end

end

%======================================================================
function mdText = getProjectionParams(proj,param)

    mdText = addMetadataField('', getString(message('MATLAB:imagesci:hdftool:projectionParameters')),'');

    centralMeridian = getString(message('MATLAB:imagesci:hdftool:centralMeridian'));
    eccentricity = getString(message('MATLAB:imagesci:hdftool:eccentricity'));
    eccentricitySquared = getString(message('MATLAB:imagesci:hdftool:eccentricitySquared'));
    falseEasting = getString(message('MATLAB:imagesci:hdftool:falseEasting'));
    falseNorthing = getString(message('MATLAB:imagesci:hdftool:falseNorthing'));
    projectionOriginLat = getString(message('MATLAB:imagesci:hdftool:projectionOriginLat'));
    scaleFactor = getString(message('MATLAB:imagesci:hdftool:scaleFactor'));
    semiMajorAxis = getString(message('MATLAB:imagesci:hdftool:semiMajorAxis'));
    semiMinorAxis = getString(message('MATLAB:imagesci:hdftool:semiMinorAxis'));
    sphereRadius = getString(message('MATLAB:imagesci:hdftool:sphereRadius'));
    latOfTrueScale = getString(message('MATLAB:imagesci:hdftool:latOfTrueScale'));

    switch(proj)
      case 'geo'
        
      case 'utm'
        mdText = addMetadataField(mdText, getString(message('MATLAB:imagesci:hdftool:lonZ')), num2str(param(1)));
        mdText = addMetadataField(mdText, getString(message('MATLAB:imagesci:hdftool:latZ')), num2str(param(2)));
      
      case 'lamcc'
        mdText = addMetadataField(mdText, semiMajorAxis, num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, semiMinorAxis, num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, eccentricitySquared, num2str(-param(2)));        
        end

        firstStandardParallelLat = getString(message('MATLAB:imagesci:hdftool:firstStandardParallelLat'));
        mdText = addMetadataField(mdText, firstStandardParallelLat, num2str(param(3)));
        secondStandardParallelLat = getString(message('MATLAB:imagesci:hdftool:secondStandardParallelLat'));
        mdText = addMetadataField(mdText, secondStandardParallelLat, num2str(param(4)));

        mdText = addMetadataField(mdText, centralMeridian, num2str(param(5)));
        mdText = addMetadataField(mdText, projectionOriginLat, num2str(param(6)));
        mdText = addMetadataField(mdText, falseEasting, num2str(param(7)));
        mdText = addMetadataField(mdText, falseNorthing, num2str(param(8)));

      case 'ps'
        mdText = addMetadataField(mdText, semiMajorAxis, num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, semiMinorAxis, num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, eccentricitySquared, num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, getString(message('MATLAB:imagesci:hdftool:lonBelowPole')), num2str(param(5)));
        mdText = addMetadataField(mdText, latOfTrueScale, num2str(param(6)));
        mdText = addMetadataField(mdText, falseEasting, num2str(param(7)));
        mdText = addMetadataField(mdText, falseNorthing, num2str(param(8)));

      case 'polyc'
        mdText = addMetadataField(mdText, semiMajorAxis, num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, semiMinorAxis, num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, eccentricity, num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, centralMeridian, num2str(param(5)));
        mdText = addMetadataField(mdText, projectionOriginLat, num2str(param(6)));
        mdText = addMetadataField(mdText, falseEasting, num2str(param(7)));
        mdText = addMetadataField(mdText, falseNorthing, num2str(param(8)));

      case 'tm'
        mdText = addMetadataField(mdText, semiMajorAxis, num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, semiMinorAxis, num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, eccentricitySquared, num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, scaleFactor, num2str(param(3)));
        mdText = addMetadataField(mdText, centralMeridian, num2str(param(4)));
        mdText = addMetadataField(mdText, projectionOriginLat, num2str(param(5)));
        mdText = addMetadataField(mdText, falseEasting, num2str(param(6)));
        mdText = addMetadataField(mdText, falseNorthing, num2str(param(7)));

    case 'lamaz'
        projCenterLat = getString(message('MATLAB:imagesci:hdftool:projCenterLat'));
        projCenterLon = getString(message('MATLAB:imagesci:hdftool:projCenterLon'));
        mdText = addMetadataField(mdText, sphereRadius, num2str(param(1)));
        mdText = addMetadataField(mdText, projCenterLat, num2str(param(5)));
        mdText = addMetadataField(mdText, projCenterLon, num2str(param(6)));
        mdText = addMetadataField(mdText, falseEasting, num2str(param(7)));
        mdText = addMetadataField(mdText, falseNorthin', num2str(param(8)));
   
    case 'hom'
        centerOfProjection = getString(message('MATLAB:imagesci:hdftool:centerOfProjection'));
        mdText = addMetadataField(mdText, semiMajorAxis, num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, semiMinorAxis, num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, eccentricity, num2str(-param(2)));        
        end
        mdText = addMetadataField(mdText, centerOfProjection, num2str(param(3)));
        
        if param(13) == 1 % hom B        
            title = getString(message('MATLAB:imagesci:hdftool:azimuthAngle'));
            mdText = addMetadataField(mdText, title, num2str(param(4)));
            title = getString(message('MATLAB:imagesci:hdftool:hotineAzimuthPoint'));
            mdText = addMetadataField(mdText, title, num2str(param(5)));
        end
        mdText = addMetadataField(mdText, projectionOriginLat, num2str(param(6)));
        mdText = addMetadataField(mdText, falseEasting, num2str(param(7)));
        mdText = addMetadataField(mdText, falseNorthing, num2str(param(8)));

        if param(13) == 0 % hom A
            lat1 = getString(message('MATLAB:imagesci:hdftool:hotineLat1'));
            lat2 = getString(message('MATLAB:imagesci:hdftool:hotineLat2'));
            lon1 = getString(message('MATLAB:imagesci:hdftool:hotineLon1'));
            lon2 = getString(message('MATLAB:imagesci:hdftool:hotineLon2'));
            mdText = addMetadataField(mdText, hotineLon1, num2str(param(9)));
            mdText = addMetadataField(mdText, hotineLat1, num2str(param(10)));
            mdText = addMetadataField(mdText, hotineLon2, num2str(param(11)));
            mdText = addMetadataField(mdText, hotineLon2, num2str(param(12)));
        end
        
    case 'som'
        mdText = addMetadataField(mdText, semiMajorAxis, num2str(param(1)));  
        if param(2) > 0
            mdText = addMetadataField(mdText, semiMinorAxis, num2str(param(2)));        
        else
            mdText = addMetadataField(mdText, eccentricitySquared, num2str(-param(2)));        
        end
        
        if param(13) == 1 % som B
            mdText = addMetadataField(mdText, ...
			    getString(message('MATLAB:imagesci:hdftool:satelliteNumber')), num2str(param(3)));        
            mdText = addMetadataField(mdText, ...
			    getString(message('MATLAB:imagesci:hdftool:landsatPathNumber')), num2str(param(4)));        
        end
        if param(13) == 0 % som A
            mdText = addMetadataField(...
                mdText, getString(message('MATLAB:imagesci:hdftool:inclination')), num2str(param(4)));
            mdText = addMetadataField(...
                mdText, getString(message('MATLAB:imagesci:hdftool:lonOfAscendingOrbit')), num2str(param(5)));        
        end
        
        mdText = addMetadataField(mdText, falseEasting, num2str(param(7)));
        mdText = addMetadataField(mdText, falseNorthing, num2str(param(8)));        
        
        if param(13) == 0 % som A
            periodOfSatelliteInMinutes = getString(message('MATLAB:imagesci:hdftool:periodOfSatelliteInMinutes'));
            satelliteRadio = getString(message('MATLAB:imagesci:hdftool:satelliteRadio'));
            mdText = addMetadataField(mdText, periodOfSatelliteInMinutes, num2str(param(9)));        
            mdText = addMetadataField(mdText, satelliteRadio,             num2str(param(10)));        
            
            fld = getString(message('MATLAB:imagesci:hdftool:pathStartEnd'));
            if param(11) == 0
                value = etString(message('MATLAB:imagesci:hdftool:pathStart'));
            else
                value = etString(message('MATLAB:imagesci:hdftool:pathEnd'));
            end
            mdText = addMetadataField(mdText, fld, value);
        end
    
      case 'good'
        mdText = addMetadataField(mdText, sphereRadius, num2str(param(1)));
        
      case 'isinus'
        numberOfLatitudinalZones = getString(message('MATLAB:imagesci:hdftool:numberOfLatitudinalZones'));
        rightJustifyColumns = getString(message('MATLAB:imagesci:hdftool:rightJustifyColumns'));

        mdText = addMetadataField(mdText, sphereRadius,             num2str(param(1)));
        mdText = addMetadataField(mdText, centralMeridian,          num2str(param(5)));
        mdText = addMetadataField(mdText, falseEasting,             num2str(param(7)));
        mdText = addMetadataField(mdText, falseNorthing,            num2str(param(8)));
        mdText = addMetadataField(mdText, numberOfLatitudinalZones, num2str(param(9)));
        mdText = addMetadataField(mdText, rightJustifyColumns,      num2str(param(11)));

     case {'bcea','cea'}
        mdText = addMetadataField(mdText, semiMajorAxis,   num2str(param(1)));  
        mdText = addMetadataField(mdText, semiMinorAxis,   num2str(param(2)));        
        mdText = addMetadataField(mdText, centralMeridian, num2str(param(5)));
        mdText = addMetadataField(mdText, latOfTrueScale,  num2str(param(6)));
        mdText = addMetadataField(mdText, falseEasting,    num2str(param(7)));
        mdText = addMetadataField(mdText, falseNorthing,   num2str(param(8)));
        
    end
end

%======================================================================
function metadataText = addMetadataField(metadataText, name, value)
    metadataText = sprintf('%s<b>%s: </b>%s<br>',...
        metadataText, name, value);
end

