classdef Icon < handle
    % Image Icon
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Icon.Icon">Icon</a>
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Icon.Description">Description</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Icon.showStandardIcons">showStandardIcons</a>
    %
    % See also matlab.ui.internal.toolstrip.Button, matlab.ui.internal.toolstrip.ListItem

    % Author(s): Rong Chen
    % Copyright 2015-2016 The MathWorks, Inc.

    % ----------------------------------------------------------------------------
    properties (Dependent)
        % Property "Description":
        %
        %   The description of the icon.
        %   It is a string and the default value is the full path.
        %   It is writable.
        Description
    end

    properties (Access = private)
        ImageSource
        ImageClass
        Description_
    end
    %               |   Image File   |   ImageIcon   |   Built-In   |   CSS Class   |
    % ImageSource     PNG path (S+J)  SwingIcon (S+J)   PNG path (S)       ''
    % ImageClass           ''               ''         CSS class (J)   CSS class (J)
    %
    % PeerNode         icon=base64     icon=base64     icon=class      icon=class
    % PeerNode        iconpath=path    iconpath=''     iconpath=path   iconpath=''
    % #1 When a control does not have an icon, both "icon" and "iconpath" are ''
    % #2 only icon property set event is used to update widgets (Java, JS)
    % #3 However, iconPath is only used by swing rendering (must set first)

    % ----------------------------------------------------------------------------
    methods
        %% Constructor
        function this = Icon(source, imagefile)
            % Constructor "Icon":
            %
            %   (1) Construct a standard icon
            %
            %   Example:
            %       icon = matlab.ui.internal.toolstrip.Icon.ADD_24;
            %       icon = matlab.ui.internal.toolstrip.Icon.NEW_16;
            %
            %   Use matlab.ui.internal.toolstrip.Icon.showStandardIcons()
            %   to browse the list of available standard icons.
            %
            %   (2) Construct a custom icon from an image file
            %
            %   Example:
            %       source = fullfile(matlabroot, 'toolbox', 'shared', 'controllib', 'general', 'resources', 'run.png');
            %       icon = matlab.ui.internal.toolstrip.Icon(source)
            %
            %   (3) Construct a custom icon from a javax.swing.ImageIcon object
            %
            %   Example:
            %       ei = com.mathworks.common.icons.ApplicationIcon.EDITOR.getIcon();
            %       icon = matlab.ui.internal.toolstrip.Icon(ei)
            %
            %   (4) Construct a custom icon from a CSS class
            %
            %   Example:
            %       cssClassName = 'activeStar';
            %       icon = matlab.ui.internal.toolstrip.Icon(cssClassName)

            narginchk(1,2)
            if nargin == 1
                source = matlab.ui.internal.toolstrip.base.Utility.hString2Char(source);
                if ischar(source)
                    [~, ~, ext] = fileparts(source);
                    if isempty(ext)
                        % Icon(css)
                        this.ImageSource = '';
                        this.ImageClass = source;
                        this.Description_ = getString(message('MATLAB:toolstrip:general:customCSS', source));
                    else
                        if strcmpi(ext,'.jpg') || strcmpi(ext,'.png')
                            % Icon(imagefile)
                            if ~contains(source,'jar!')
                                % Icon(imagefile located in a folder)
                                if exist(source, 'file')
                                    this.ImageClass = '';
                                    this.ImageSource = source;
                                    this.Description_ = source;
                                else
                                    error(message('MATLAB:toolstrip:general:wrongImageFileFormat'));
                                end
                            else
                                % Icon(imagefile located in a jar file)
                                icon = javaObjectEDT('javax.swing.ImageIcon',java.net.URL(source));
                                if icon.getIconWidth()==-1 || icon.getIconHeight()==-1
                                    error(message('MATLAB:toolstrip:general:wrongImageFileFormat'));
                                else
                                    this.ImageClass = '';
                                    this.ImageSource = source;
                                    this.Description_ = source;
                                end
                            end
                        else
                            error(message('MATLAB:toolstrip:general:wrongImageFileFormat'));
                        end
                    end
                elseif isa(source, 'javax.swing.ImageIcon')
                    % java ImageIcon object
                    this.ImageSource = source;
                    this.ImageClass = '';
                    this.Description_  = char(source.getDescription());
                else
                    error(message('MATLAB:toolstrip:general:wrongIconFirstInput'));
                end
            else
                % Standard icon (internal use only)
                this.ImageSource = fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons',[imagefile '.png']);
                this.ImageClass = lower(source);
                this.Description_ = getString(message('MATLAB:toolstrip:general:standardIcon',source));
            end
        end

        %% Public API: Get/Set
        % Description
        function value = get.Description(this)
            % GET function for Description property.
            value = this.Description_;
        end
        function set.Description(this, value)
            % SET function for Description property.
            if ~matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string')
                error(message('MATLAB:toolstrip:general:invalidIconDescription'))
            end
            this.Description_ = value;
        end

    end

    % ----------------------------------------------------------------------------
    % Standard icons from toolstrip icon library
    methods (Sealed, Static)
        function icon = ADD_16
            icon = matlab.ui.internal.toolstrip.Icon('ADD_16', 'Add_16');
        end
        function icon = ADD_24
            icon = matlab.ui.internal.toolstrip.Icon('ADD_24', 'Add_24');
        end
        function icon = BACK_16
            icon = matlab.ui.internal.toolstrip.Icon('BACK_16', 'Back_16');
        end
        function icon = BACK_24
            icon = matlab.ui.internal.toolstrip.Icon('BACK_24', 'Back_24');
        end
        function icon = BROWSE_16
            icon = matlab.ui.internal.toolstrip.Icon('BROWSE_16', 'Browse_16');
        end
        function icon = BROWSE_24
            icon = matlab.ui.internal.toolstrip.Icon('BROWSE_24', 'Browse_24');
        end
        function icon = CLEAR_16
            icon = matlab.ui.internal.toolstrip.Icon('CLEAR_16', 'Clear_16');
        end
        function icon = CLEAR_24
            icon = matlab.ui.internal.toolstrip.Icon('CLEAR_24', 'Clear_24');
        end
        function icon = CLOSE_16
            icon = matlab.ui.internal.toolstrip.Icon('CLOSE_16', 'Close_16');
        end
        function icon = CLOSE_24
            icon = matlab.ui.internal.toolstrip.Icon('CLOSE_24', 'Close_24');
        end
        function icon = COMPARE_16
            icon = matlab.ui.internal.toolstrip.Icon('COMPARE_16', 'Compare_16');
        end
        function icon = COMPARE_24
            icon = matlab.ui.internal.toolstrip.Icon('COMPARE_24', 'Compare_24');
        end
        function icon = CONFIRM_16
            icon = matlab.ui.internal.toolstrip.Icon('CONFIRM_16', 'Confirm_16');
        end
        function icon = CONFIRM_24
            icon = matlab.ui.internal.toolstrip.Icon('CONFIRM_24', 'Confirm_24');
        end
        function icon = CONTINUE_16
            icon = matlab.ui.internal.toolstrip.Icon('CONTINUE_16', 'Continue_16');
        end
        function icon = CONTINUE_24
            icon = matlab.ui.internal.toolstrip.Icon('CONTINUE_24', 'Continue_24');
        end
        function icon = CONTINUE_MATLAB_16
            icon = matlab.ui.internal.toolstrip.Icon('CONTINUE_MATLAB_16', 'Continue_MATLAB_16');
        end
        function icon = CONTINUE_MATLAB_24
            icon = matlab.ui.internal.toolstrip.Icon('CONTINUE_MATLAB_24', 'Continue_MATLAB_24');
        end
        function icon = COPY_16
            icon = matlab.ui.internal.toolstrip.Icon('COPY_16', 'Copy_16');
        end
        function icon = COPY_24
            icon = matlab.ui.internal.toolstrip.Icon('COPY_24', 'Copy_24');
        end
        function icon = CUT_16
            icon = matlab.ui.internal.toolstrip.Icon('CUT_16', 'Cut_16');
        end
        function icon = CUT_24
            icon = matlab.ui.internal.toolstrip.Icon('CUT_24', 'Cut_24');
        end
        function icon = DELETE_16
            icon = matlab.ui.internal.toolstrip.Icon('DELETE_16', 'Delete_16');
        end
        function icon = DELETE_24
            icon = matlab.ui.internal.toolstrip.Icon('DELETE_24', 'Delete_24');
        end
        function icon = DOWN_16
            icon = matlab.ui.internal.toolstrip.Icon('DOWN_16', 'Down_16');
        end
        function icon = DOWN_24
            icon = matlab.ui.internal.toolstrip.Icon('DOWN_24', 'Down_24');
        end
        function icon = END_16
            icon = matlab.ui.internal.toolstrip.Icon('END_16', 'End_16');
        end
        function icon = END_24
            icon = matlab.ui.internal.toolstrip.Icon('END_24', 'End_24');
        end
        function icon = EXPORT_16
            icon = matlab.ui.internal.toolstrip.Icon('EXPORT_16', 'Export_16');
        end
        function icon = EXPORT_24
            icon = matlab.ui.internal.toolstrip.Icon('EXPORT_24', 'Export_24');
        end
        function icon = FIND_FILES_16
            icon = matlab.ui.internal.toolstrip.Icon('FIND_FILES_16', 'Find_Files_16');
        end
        function icon = FIND_FILES_24
            icon = matlab.ui.internal.toolstrip.Icon('FIND_FILES_24', 'Find_Files_24');
        end
        function icon = FORWARD_16
            icon = matlab.ui.internal.toolstrip.Icon('FORWARD_16', 'Forward_16');
        end
        function icon = FORWARD_24
            icon = matlab.ui.internal.toolstrip.Icon('FORWARD_24', 'Forward_24');
        end
        function icon = GOTO_16
            icon = matlab.ui.internal.toolstrip.Icon('GOTO_16', 'Goto_16');
        end
        function icon = GOTO_24
            icon = matlab.ui.internal.toolstrip.Icon('GOTO_24', 'Goto_24');
        end
        function icon = HELP_16
            icon = matlab.ui.internal.toolstrip.Icon('HELP_16', 'Help_16');
        end
        function icon = HELP_24
            icon = matlab.ui.internal.toolstrip.Icon('HELP_24', 'Help_24');
        end
        function icon = IMPORT_16
            icon = matlab.ui.internal.toolstrip.Icon('IMPORT_16', 'Import_16');
        end
        function icon = IMPORT_24
            icon = matlab.ui.internal.toolstrip.Icon('IMPORT_24', 'Import_24');
        end
        function icon = LAYOUT_16
            icon = matlab.ui.internal.toolstrip.Icon('LAYOUT_16', 'Layout_16');
        end
        function icon = LAYOUT_24
            icon = matlab.ui.internal.toolstrip.Icon('LAYOUT_24', 'Layout_24');
        end
        function icon = LEGEND_16
            icon = matlab.ui.internal.toolstrip.Icon('LEGEND_16', 'Legend_16');
        end
        function icon = LEGEND_24
            icon = matlab.ui.internal.toolstrip.Icon('LEGEND_24', 'Legend_24');
        end
        function icon = LOCK_16
            icon = matlab.ui.internal.toolstrip.Icon('LOCK_16', 'Lock_16');
        end
        function icon = LOCK_24
            icon = matlab.ui.internal.toolstrip.Icon('LOCK_24', 'Lock_24');
        end
        function icon = MATLAB_16
            icon = matlab.ui.internal.toolstrip.Icon('MATLAB_16', 'MATLAB_16');
        end
        function icon = MATLAB_24
            icon = matlab.ui.internal.toolstrip.Icon('MATLAB_24', 'MATLAB_24');
        end
        function icon = NEW_16
            icon = matlab.ui.internal.toolstrip.Icon('NEW_16', 'New_16');
        end
        function icon = NEW_24
            icon = matlab.ui.internal.toolstrip.Icon('NEW_24', 'New_24');
        end
        function icon = OPEN_16
            icon = matlab.ui.internal.toolstrip.Icon('OPEN_16', 'Open_16');
        end
        function icon = OPEN_24
            icon = matlab.ui.internal.toolstrip.Icon('OPEN_24', 'Open_24');
        end
        function icon = PAN_16
            icon = matlab.ui.internal.toolstrip.Icon('PAN_16', 'Pan_16');
        end
        function icon = PAN_24
            icon = matlab.ui.internal.toolstrip.Icon('PAN_24', 'Pan_24');
        end
        function icon = PARALLEL_16
            icon = matlab.ui.internal.toolstrip.Icon('PARALLEL_16', 'Parallel_16');
        end
        function icon = PARALLEL_24
            icon = matlab.ui.internal.toolstrip.Icon('PARALLEL_24', 'Parallel_24');
        end
        function icon = PASTE_16
            icon = matlab.ui.internal.toolstrip.Icon('PASTE_16', 'Paste_16');
        end
        function icon = PASTE_24
            icon = matlab.ui.internal.toolstrip.Icon('PASTE_24', 'Paste_24');
        end
        function icon = PAUSE_16
            icon = matlab.ui.internal.toolstrip.Icon('PAUSE_16', 'Pause_16');
        end
        function icon = PAUSE_24
            icon = matlab.ui.internal.toolstrip.Icon('PAUSE_24', 'Pause_24');
        end
        function icon = PAUSE_MATLAB_16
            icon = matlab.ui.internal.toolstrip.Icon('PAUSE_MATLAB_16', 'Pause_MATLAB_16');
        end
        function icon = PAUSE_MATLAB_24
            icon = matlab.ui.internal.toolstrip.Icon('PAUSE_MATLAB_24', 'Pause_MATLAB_24');
        end
        function icon = PLAY_16
            icon = matlab.ui.internal.toolstrip.Icon('PLAY_16', 'Play_16');
        end
        function icon = PLAY_24
            icon = matlab.ui.internal.toolstrip.Icon('PLAY_24', 'Play_24');
        end
        function icon = PLOT_16
            icon = matlab.ui.internal.toolstrip.Icon('PLOT_16', 'Plot_16');
        end
        function icon = PLOT_24
            icon = matlab.ui.internal.toolstrip.Icon('PLOT_24', 'Plot_24');
        end
        function icon = PRINT_16
            icon = matlab.ui.internal.toolstrip.Icon('PRINT_16', 'Print_16');
        end
        function icon = PRINT_24
            icon = matlab.ui.internal.toolstrip.Icon('PRINT_24', 'Print_24');
        end
        function icon = PROPERTIES_16
            icon = matlab.ui.internal.toolstrip.Icon('PROPERTIES_16', 'Properties_16');
        end
        function icon = PROPERTIES_24
            icon = matlab.ui.internal.toolstrip.Icon('PROPERTIES_24', 'Properties_24');
        end
        function icon = PUBLISH_16
            icon = matlab.ui.internal.toolstrip.Icon('PUBLISH_16', 'Publish_16');
        end
        function icon = PUBLISH_24
            icon = matlab.ui.internal.toolstrip.Icon('PUBLISH_24', 'Publish_24');
        end
        function icon = REDO_16
            icon = matlab.ui.internal.toolstrip.Icon('REDO_16', 'Redo_16');
        end
        function icon = REDO_24
            icon = matlab.ui.internal.toolstrip.Icon('REDO_24', 'Redo_24');
        end
        function icon = REFRESH_16
            icon = matlab.ui.internal.toolstrip.Icon('REFRESH_16', 'Refresh_16');
        end
        function icon = REFRESH_24
            icon = matlab.ui.internal.toolstrip.Icon('REFRESH_24', 'Refresh_24');
        end
        function icon = RESTORE_16
            icon = matlab.ui.internal.toolstrip.Icon('RESTORE_16', 'Restore_16');
        end
        function icon = RESTORE_24
            icon = matlab.ui.internal.toolstrip.Icon('RESTORE_24', 'Restore_24');
        end
        function icon = RUN_16
            icon = matlab.ui.internal.toolstrip.Icon('RUN_16', 'Run_16');
        end
        function icon = RUN_24
            icon = matlab.ui.internal.toolstrip.Icon('RUN_24', 'Run_24');
        end
        function icon = SAVE_16
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_16', 'Save_16');
        end
        function icon = SAVE_24
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_24', 'Save_24');
        end
        function icon = SAVE_ALL_16
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_ALL_16', 'Save_All_16');
        end
        function icon = SAVE_ALL_24
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_ALL_24', 'Save_All_24');
        end
        function icon = SAVE_AS_16
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_AS_16', 'Save_As_16');
        end
        function icon = SAVE_AS_24
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_AS_24', 'Save_As_24');
        end
        function icon = SAVE_COPY_AS_16
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_COPY_AS_16', 'Save_Copy_As_16');
        end
        function icon = SAVE_COPY_AS_24
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_COPY_AS_24', 'Save_Copy_As_24');
        end
        function icon = SAVE_DIRTY_16
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_DIRTY_16', 'Save_Dirty_16');
        end
        function icon = SAVE_DIRTY_24
            icon = matlab.ui.internal.toolstrip.Icon('SAVE_DIRTY_24', 'Save_Dirty_24');
        end
        function icon = SEARCH_16
            icon = matlab.ui.internal.toolstrip.Icon('SEARCH_16', 'Search_16');
        end
        function icon = SEARCH_24
            icon = matlab.ui.internal.toolstrip.Icon('SEARCH_24', 'Search_24');
        end
        function icon = SELECT_16
            icon = matlab.ui.internal.toolstrip.Icon('SELECT_16', 'Select_16');
        end
        function icon = SELECT_24
            icon = matlab.ui.internal.toolstrip.Icon('SELECT_24', 'Select_24');
        end
        function icon = SETTINGS_16
            icon = matlab.ui.internal.toolstrip.Icon('SETTINGS_16', 'Settings_16');
        end
        function icon = SETTINGS_24
            icon = matlab.ui.internal.toolstrip.Icon('SETTINGS_24', 'Settings_24');
        end
        function icon = SET_PATH_16
            icon = matlab.ui.internal.toolstrip.Icon('SET_PATH_16', 'Set_Path_16');
        end
        function icon = SET_PATH_24
            icon = matlab.ui.internal.toolstrip.Icon('SET_PATH_24', 'Set_Path_24');
        end
        function icon = SIMULINK_16
            icon = matlab.ui.internal.toolstrip.Icon('SIMULINK_16', 'Simulink_16');
        end
        function icon = SIMULINK_24
            icon = matlab.ui.internal.toolstrip.Icon('SIMULINK_24', 'Simulink_24');
        end
        function icon = STOP_16
            icon = matlab.ui.internal.toolstrip.Icon('STOP_16', 'Stop_16');
        end
        function icon = STOP_24
            icon = matlab.ui.internal.toolstrip.Icon('STOP_24', 'Stop_24');
        end
        function icon = TOOLS_16
            icon = matlab.ui.internal.toolstrip.Icon('TOOLS_16', 'Tools_16');
        end
        function icon = TOOLS_24
            icon = matlab.ui.internal.toolstrip.Icon('TOOLS_24', 'Tools_24');
        end
        function icon = UNDO_16
            icon = matlab.ui.internal.toolstrip.Icon('UNDO_16', 'Undo_16');
        end
        function icon = UNDO_24
            icon = matlab.ui.internal.toolstrip.Icon('UNDO_24', 'Undo_24');
        end
        function icon = UNLOCK_16
            icon = matlab.ui.internal.toolstrip.Icon('UNLOCK_16', 'Unlock_16');
        end
        function icon = UNLOCK_24
            icon = matlab.ui.internal.toolstrip.Icon('UNLOCK_24', 'Unlock_24');
        end
        function icon = UP_16
            icon = matlab.ui.internal.toolstrip.Icon('UP_16', 'Up_16');
        end
        function icon = UP_24
            icon = matlab.ui.internal.toolstrip.Icon('UP_24', 'Up_24');
        end
        function icon = UP_ONE_LEVEL_16
            icon = matlab.ui.internal.toolstrip.Icon('UP_ONE_LEVEL_16', 'Up_One_Level_16');
        end
        function icon = UP_ONE_LEVEL_24
            icon = matlab.ui.internal.toolstrip.Icon('UP_ONE_LEVEL_24', 'Up_One_Level_24');
        end
        function icon = ZOOM_IN_16
            icon = matlab.ui.internal.toolstrip.Icon('ZOOM_IN_16', 'Zoom_In_16');
        end
        function icon = ZOOM_IN_24
            icon = matlab.ui.internal.toolstrip.Icon('ZOOM_IN_24', 'Zoom_In_24');
        end
        function icon = ZOOM_OUT_16
            icon = matlab.ui.internal.toolstrip.Icon('ZOOM_OUT_16', 'Zoom_Out_16');
        end
        function icon = ZOOM_OUT_24
            icon = matlab.ui.internal.toolstrip.Icon('ZOOM_OUT_24', 'Zoom_Out_24');
        end
    end
    
    methods (Hidden)
        
        function url = getBase64URL(this)
            if isa(this.ImageSource,'javax.swing.ImageIcon')
                % from an ImageIcon
                imagefile = char(this.ImageSource.getDescription());
                if isempty(imagefile)
                    % direct from CData
                    img = this.ImageSource.getImage();
                    bImage = java.awt.image.BufferedImage(img.getWidth(), img.getHeight(), java.awt.image.BufferedImage.TYPE_INT_RGB);
                    bGr = bImage.createGraphics();
                    bGr.drawImage(img, 0, 0, []);
                    bGr.dispose();
                    baos = java.io.ByteArrayOutputStream;
                    javax.imageio.ImageIO.write(bImage, 'png', baos);
                    bytes = baos.toByteArray();
                    baos.flush();
                    baos.close()                
                    encoder = org.apache.commons.codec.binary.Base64;
                    str = transpose(char(encoder.encode(bytes)));
                    url = ['data:image/' 'png' ';base64,' str];
                else
                    % wrap a file
                    if ~contains(imagefile,'jar!')
                        % image is a file 
                        info = imfinfo(imagefile);
                        type = info.Format;
                        fid = fopen(imagefile,'rb');
                        bytes = fread(fid);
                        fclose(fid);
                        encoder = org.apache.commons.codec.binary.Base64;
                        str = transpose(char(encoder.encode(bytes)));
                        url = ['data:image/' type ';base64,' str];
                    else
                        % image is inside a jar file
                        type = imagefile(end-2:end);
                        img = getImage(javaObjectEDT('javax.swing.ImageIcon',java.net.URL(imagefile)));
                        bImage = java.awt.image.BufferedImage(img.getWidth(), img.getHeight(), java.awt.image.BufferedImage.TYPE_INT_RGB);
                        bGr = bImage.createGraphics();
                        bGr.drawImage(img, 0, 0, []);
                        bGr.dispose();
                        baos = java.io.ByteArrayOutputStream;
                        javax.imageio.ImageIO.write(bImage, 'png', baos);
                        bytes = baos.toByteArray();
                        baos.flush();
                        baos.close()                
                        encoder = org.apache.commons.codec.binary.Base64;
                        str = transpose(char(encoder.encode(bytes)));
                        url = ['data:image/' type ';base64,' str];
                    end        
                end                    
            else
                % from a file
                imagefile = this.ImageSource;
                if ~contains(imagefile,'jar!')
                    % image is a file 
                    info = imfinfo(imagefile);
                    type = info.Format;
                    fid = fopen(imagefile,'rb');
                    bytes = fread(fid);
                    fclose(fid);
                    encoder = org.apache.commons.codec.binary.Base64;
                    str = transpose(char(encoder.encode(bytes)));
                    url = ['data:image/' type ';base64,' str];
                else
                    % image is inside a jar file
                    type = imagefile(end-2:end);
                    img = getImage(javaObjectEDT('javax.swing.ImageIcon',java.net.URL(imagefile)));
                    bImage = java.awt.image.BufferedImage(img.getWidth(), img.getHeight(), java.awt.image.BufferedImage.TYPE_INT_RGB);
                    bGr = bImage.createGraphics();
                    bGr.drawImage(img, 0, 0, []);
                    bGr.dispose();
                    baos = java.io.ByteArrayOutputStream;
                    javax.imageio.ImageIO.write(bImage, 'png', baos);
                    bytes = baos.toByteArray();
                    baos.flush();
                    baos.close()                
                    encoder = org.apache.commons.codec.binary.Base64;
                    str = transpose(char(encoder.encode(bytes)));
                    url = ['data:image/' type ';base64,' str];
                end                
            end
        end
        
        function iconclass = getIconClass(this)
            % return CSS class (built-in or custom) or ''
            iconclass = this.ImageClass;
        end
        
        function source = getIconFile(this)
            % return icon file (file or built-in) or ''
            if ischar(this.ImageSource)
                source = this.ImageSource;
            else
                source = '';
            end
        end
        
        function value = isCSS(this)
            value = ~isempty(this.ImageClass);
        end

    end
    
    % ----------------------------------------------------------------------------
    methods (Static)
        
        function showStandardIcons()
            % Method "showStandardIcons"
            %
            %   Display all the available standard icons with their names.
            
            % Find all static methods returning an icon.
            clsName = 'matlab.ui.internal.toolstrip.Icon';
            info = meta.class.fromName(clsName);
            list = info.MethodList;
            [~, I] = sort({list.Name});
            list = list(I);
            
            mthd = {};
            for k = 1:length(list)
                m = list(k);
                if m.Static && isempty(m.InputNames) && ...
                        ~isempty(m.OutputNames) && strcmp(m.OutputNames, 'icon')
                    % Static methods returning icons have no inputs and have "icon"
                    % as the output argument.
                    mthd{end+1} = m.Name; %#ok<AGROW>
                end
            end
            
            % Add icons to a panel
            len = ceil(length(mthd)/5); % 5 columns and as many rows as needed.
            f = '';
            for k = 1:len
                f = sprintf('%sf:d:g,',f);
            end
            f(end) = ''; % Remove last ','.
            
            layout = com.jgoodies.forms.layout.FormLayout( 'f:d:g,f:d:g,f:d:g,f:d:g,f:d:g', f);
            jpanel = javaObjectEDT('javax.swing.JPanel', layout);
            
            for k = 1:length(mthd)
                try
                    icon = eval([clsName, '.' mthd{k}]);
                    imageicon = javaObjectEDT('javax.swing.ImageIcon',icon.getIconFile());
                    jlabel = javaObjectEDT('javax.swing.JLabel',mthd{k},imageicon,javax.swing.JLabel.LEFT);
                catch E
                    % Icon not implemented yet.
                    fprintf('%s\n', E.message);
                    jlabel = javaObjectEDT('javax.swing.JLabel',mthd{k});
                end
                i = rem(k-1,5); % col
                j = (k-i-1)/5;  % row
                str = sprintf('xy(%d,%d)', i+1, j+1);
                clc = com.jgoodies.forms.layout.CellConstraints;
                clc.insets.bottom = 1;
                c = eval(['clc' '.' str]);
                jpanel.add(jlabel,c);
            end
            
            % Show icons on a panel
            fig = figure(...
                'IntegerHandle','off', ...
                'Menubar','None',...
                'Toolbar','None',...
                'Name','Icon Catalog. To use: matlab.ui.internal.toolstrip.Icon.<NAME>', ...
                'NumberTitle','off', ...
                'Visible','on', ...
                'Resize', 'on', ...
                'Units','pixels');
            set(fig, 'ResizeFcn', @localFigureResize)
            pos = get(fig, 'Position');
            scroll = javaObjectEDT('javax.swing.JScrollPane', jpanel);
            [~, container] = javacomponent(scroll,[0 0 pos(3) pos(4)],fig);
            set(fig, 'UserData', {jpanel, container});
        end
        
        function icon = getImageIconFromBase64(str)
            token = 'base64,';
            base64str = str(strfind(str,token)+length(token):end);
            bytes = transpose(javax.xml.bind.DatatypeConverter.parseBase64Binary(base64str)); 
            st = java.io.ByteArrayInputStream(bytes);
            image = javax.imageio.ImageIO.read(st);
            icon = javaObjectEDT('javax.swing.ImageIcon',image);
        end
        
    end
    
end

% ----------------------------------------------------------------------------
function localFigureResize(fig,~)
    % Handle figure resize
    pos = get(fig, 'Position');
    ud  = get(fig, 'UserData');
    container = ud{2};
    set(container, 'Position', [0 0 pos(3) pos(4)]);
end
