function cmd = buildImportCommand(this, bImport)
%BUILDIMPORTCOMMAND Create the command that will be used to import the data.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   BIMPORT: THis indicates if the string will be used for import.
%       If this is the case, we will do some extra error checking.

%   Copyright 2005-2013 The MathWorks, Inc.

    infoStruct = this.currentNode.nodeinfostruct;
    selBtn = this.subsetSelectionApi.getSelected();
    varName = get(this.filetree,'wsvarname');

    fileName = this.filetree.filename;
    gridName = this.currentNode.displayname;
    baseCmd = sprintf('%s = hdfread(''%s'', ''%s'', ''Fields'', ''%%s''%%s);', ...
        varName, fileName, gridName);
    baseCmd = strrep(baseCmd, '\', '\\');
    errorStr = '';
	errWindowTitleStr = getString(message('MATLAB:imagesci:hdftool:invalidSubsetSelection'));

    switch (selBtn)
        case getString(message('MATLAB:imagesci:hdftool:noSubsetting'))
            cmd = buildNoSubsettingCmd(baseCmd);
        case getString(message('MATLAB:imagesci:hdftool:directIndex'))
            cmd = buildDirectIndexCmd(baseCmd, this.subsetApi{2});
        case getString(message('MATLAB:imagesci:hdftool:geographicBox'))
            cmd = buildGeographicBoxCmd(baseCmd, this.subsetApi{3});
        case getString(message('MATLAB:imagesci:hdftool:interpolate'))
            cmd = buildInterpolateCmd(baseCmd, this.subsetApi{4});
        case getString(message('MATLAB:imagesci:hdftool:pixels'))
            cmd = buildPixelsCmd(baseCmd, this.subsetApi{5});
        case getString(message('MATLAB:imagesci:hdftool:tile'))
            cmd = buildTileCmd(baseCmd, this.subsetApi{6});
        case getString(message('MATLAB:imagesci:hdftool:time'))
            cmd = buildTimeCmd(baseCmd, this.subsetApi{7});
        case getString(message('MATLAB:imagesci:hdftool:userdefined'))
            cmd = buildUserDefinedCmd(baseCmd, this.subsetApi{8});
        otherwise
            cmd='';
    end

    set(this.filetree,'matlabCmd',cmd);

    %=======================================================
    function outCmd = buildNoSubsettingCmd(baseCmd, ~)
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,'');
    end
    %=======================================================
    function outCmd = buildDirectIndexCmd(baseCmd, h)
        data = h.getTableData();
        str = sprintf(',''Index'',{[%s],[%s],[%s]}',...
            num2str([data{:,1}]), ...
            num2str([data{:,2}]), ...
            num2str([data{:,3}]) );
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            str);
    end
    %=======================================================
    function outCmd = buildGeographicBoxCmd(baseCmd, h)
        outCmd       = '';
        boxVals      = h.getBoxCornerValues();
        timeVals     = h.getTime();
        userdefVals  = h.getUserDefined();
        userdefParam = buildUserDefParam(userdefVals);
        timeParam    = buildTimeParam(timeVals);
        boxParam     = buildBoxParam('Box',boxVals);
        % errorStr is initialized to empty and is only populated if
        % an error occurs in the build-Param nested functions.
        if ~isempty(errorStr)
            errordlg(errorStr,errWindowTitleStr);
            return
        end
        str = [boxParam,userdefParam,timeParam];
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            str);
    end
    %=======================================================
    function outCmd = buildInterpolateCmd(baseCmd, h)
        outCmd = '';
        errorStr = '';
        boxVals = h.getBoxCornerValues();
        interpParam = buildBoxParam('Interpolate',boxVals);
        if ~isempty(errorStr)
            errordlg(errorStr,errWindowTitleStr);
            return;
        end
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            interpParam);
    end
    %=======================================================
    function outCmd = buildPixelsCmd(baseCmd, h)
        outCmd = '';
        errorStr = '';
        boxVals = h.getBoxCornerValues();
        pixelsParam = buildBoxParam('Pixels',boxVals);
        if ~isempty(errorStr)
            errordlg(errorStr,errWindowTitleStr);
            return;
        end
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            pixelsParam);
    end
    %=======================================================
    function outCmd = buildTileCmd(baseCmd, h)
        outCmd = '';
        tileCoords = h.getSelectedString();
        tileCoords = str2double(tileCoords);
        if bImport && isempty(tileCoords)
		    errMsg = getString(message('MATLAB:imagesci:hdftool:numericTileValues'));
            errordlg(errMsg,errWindowTitleStr);
            return
        end
        str = [', ''Tile'', [' num2str(tileCoords) ']'];
        outCmd = sprintf(baseCmd, infoStruct.Name, str);
    end
    %=======================================================
    function outCmd = buildTimeCmd(baseCmd, h)
        outCmd = '';
        errorStr = '';
        timeVals     = h.getTime();
        userdefVals  = h.getUserDefined();
        timeParam    = buildTimeParam(timeVals);
        userdefParam = buildUserDefParam(userdefVals);
        if ~isempty(errorStr)
            errordlg(errorStr,errWindowTitleStr);
            return
        end
        if isempty(timeParam)
		    errMsg = getString(message('MATLAB:imagesci:hdftool:numericTimeValues'));
            errordlg(errMsg, errWindowTitleStr);
            return
        end
        str = [timeParam,userdefParam];
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            str);
    end
    %=======================================================
    function outCmd = buildUserDefinedCmd(baseCmd, h)
        outCmd = '';
        errorStr = '';
        userdefVals = h.getUserDefined();
        userdefParam = buildUserDefParam(userdefVals);
        if ~isempty(errorStr)
            errordlg(errorStr,errWindowTitleStr);
            return
        end
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            userdefParam);
    end
    %======================================================
    function userdefParam = buildUserDefParam(userdefVals)
        userdefParam = '';
        if size(userdefVals,2) <3
            return
        end
        tmp = userdefVals(:,2:3)';
        vals = sprintf('%s ',tmp{:});
        vals = str2num(vals); %#ok<ST2NM>
        if ~isempty(vals)
            if bImport && mod(length(vals),2)
                % if both min and max values are entered
                errorStr = getString(message('MATLAB:imagesci:hdftool:minAndMaxRequired'));
                return
            else
                len = length(vals)/2;
                for m = 1:len
                    userdefParam = ...
                        sprintf([userdefParam,',''Vertical'',{''%s'',[%s]}'],...
                        userdefVals{m,1},...
                        num2str(vals(m*2-1:m*2)));
                end
            end
        end
    end
    %=====================================================
    function timeParam = buildTimeParam(timeVals)
        timeParam = '';
        timeLen = length(find(isnan(timeVals)));
        if timeLen < 2
            % if either start and stop values are entered
            if bImport && timeLen ~= 0
                % if both are not entered.  i.e. start or stop is NaN
                errorStr = getString(message('MATLAB:imagesci:hdftool:startAndStopTimesRequired'));
            else
                timeParam = sprintf(',''Time'',{%s}',num2str(timeVals));
            end
        end
    end
    %=====================================================
    function boxParam = buildBoxParam(type, boxVals)
        if any(isnan(boxVals(:)),1)
            errorStr = getString(message('MATLAB:imagesci:hdftool:latAndLonRequired'));
        end
        boxParam = sprintf(',''%s'',{[%s], [%s]}',...
            type,...
            num2str(boxVals(:,1)'),...
            num2str(boxVals(:,2)'));
    end
end

