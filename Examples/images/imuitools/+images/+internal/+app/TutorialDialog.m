classdef TutorialDialog < handle
% TutorialDialog Display tutorial dialog with images and messages in an app
% context
%
%   FOR INTERNAL USE ONLY
%
%   images.internal.app.TutorialDialog(IMAGES,MESSAGES,TITLE) displays a
%   tutorial dialog that allows user to click through images with
%   corresponding text. IMAGES is a 1xN or Nx1 cell array of paths to the
%   images to be displayed in the tutorial, MESSAGES is a cell array of the
%   same size as IMAGES that contains the strings or char arrays for each
%   corresponding image. The number of images and messages must be the
%   same. TITLE is a string or char array of the message to be displayed in
%   the title bar.
%
%   images.internal.app.TutorialDialog(IMAGES,MESSAGES,TITLE,S) displays a
%   tutorial dialog with a checkbox that the user can select to not show
%   the dialog again. S must be the SettingsGroup setting of class
%   matlab.settings.Setting that the tutorial dialog checks before opening
%   and modifies when the checkbox is selected. 
%
%   If the "Don't show me again" checkbox is selected when the user closes
%   the tutorial, the setting (S.PersonalValue) will be set to false.
%   Before opening the dialog, the setting will be queried and the dialog
%   will only be opened if the setting is true.
%
%   Copyright 2017 The MathWorks, Inc.

    properties (Access = private)
        
        ImagePaths      % Cell array of file paths to images that will be 
                        % displayed in tutorial
                        
        MessageStrings  % Cell array of char arrays for message that 
                        % corresponds to each image
                        
        Title           % Message displayed in title bar
                        
        Setting         % Optional setting from SettingsGroup to allow user
                        % to not display tutorial again

    end
    
    properties (Dependent)
        CurrentIndex
    end
    
    properties (Access = private)
        
        CurrentIndexInternal = 1;
        NumPages
        
        % UI Components
        FigureHandle
        AxesHandle
        OKButton
        LeftButton
        RightButton
        CheckBox
        CheckBoxText
        Font
        TextHandleArray
        DotHandle
        DotAxesHandle
        Position = get(0,'DefaultFigurePosition');
        
        % Hardcoded Layout Parameters
        Offset = 10; % points
        OKButtonWidth = 40;
        OKButtonHeight = 17;
        ArrowButtonHeight = 20;
        ImageHeight = 220;
        DotHeight = 10;
        OKXOffset
        
    end
    
    methods (Access = public)
        
        function self = TutorialDialog(imagePaths,messageStrings,titleMessage,varargin)
            
            if nargin > 3
                assert(isa(varargin{1},'matlab.settings.Setting'),'The third argument must be a matlab.settings.Setting object.')
                self.Setting = varargin{1};
                
                % Check if user preference is set to not show dialog
                if ~self.Setting.ActiveValue
                    % Don't show dialog
                    return;
                end
            end
            
            assert(isa(imagePaths,'cell'),'Image paths should be in a cell array');
            assert(isa(messageStrings,'cell'),'Message strings should be in a cell array');
            assert(isequal(size(imagePaths),size(messageStrings)),'Number of images and messages should be equal');
            
            self.ImagePaths = imagePaths;
            self.MessageStrings = messageStrings;
            self.NumPages = numel(self.ImagePaths);
            self.Title = titleMessage;
            self.TextHandleArray = cell(size(messageStrings));
            
            self.createDialog();

        end
            
        function createDialog(self) 
            
            % Create font
            self.Font.FontUnits  = 'points';
            self.Font.FontSize   = get(0,'FactoryUicontrolFontSize');
            self.Font.FontName   = get(0,'FactoryUicontrolFontName');
            self.Font.FontWeight = get(0, 'DefaultTextFontWeight');
            
            self.Position = get(0,'DefaultFigurePosition');
            self.Position(3) = 200;
            self.Position(4) = self.ImageHeight + self.DotHeight + 40;
            
            % Create UI objects
            self.createFigure();
            self.createImageAxes();
            self.createDots();
            self.createOKButton();
            self.createRightButton();
            self.createLeftButton();
            self.createTextMessageArray();
            self.createCheckBox();          
            
            self.setFinalPositions();
            
            self.updatePage();
            
            % Make figure centered, visible, and modal
            movegui(self.FigureHandle,'center')
            set(self.FigureHandle,'HandleVisibility','callback','Visible','on');
            uiwait(self.FigureHandle)
            drawnow;
            
        end
        
        function createFigure(self)
            self.FigureHandle = dialog('Name',self.Title, ...
                'Pointer','arrow', ...
                'Units','points', ...
                'Visible','off', ...
                'KeyPressFcn',@self.doKeyPress, ...
                'WindowStyle','modal', ...
                'Toolbar','none', ...
                'HandleVisibility','on', ...
                'CloseRequestFcn', @self.closePopup, ...
                'Tag','TutorialDialog');
        end
        
        function createImageAxes(self)
            % create an axes for the images
            imagePos = [(2*self.Offset)+self.ArrowButtonHeight, self.Position(4)-self.ImageHeight-self.Offset, self.Position(3)-(4*self.Offset)-(2*self.ArrowButtonHeight), self.ImageHeight];
            self.AxesHandle = axes('Parent',self.FigureHandle, ...
                'Units','points', ...
                'Position',imagePos, ...
                'Tag','ImageAxes');
        end
        
        function createDots(self)
            % create an axes for the dots
            dotPos = [(2*self.Offset)+self.ArrowButtonHeight, self.Position(4)-self.ImageHeight-self.DotHeight-self.Offset, self.Position(3)-(4*self.Offset)-(2*self.ArrowButtonHeight), self.DotHeight];
            self.DotAxesHandle = axes('Parent',self.FigureHandle, ...
                'Units','points', ...
                'Position',dotPos, ...
                'Tag','ImageAxes', ...
                'Visible','off', ...
                'XLimMode','manual', ...
                'YLimMode','manual');
            
            yData = 0.5*ones([self.NumPages,1]);
            xSpacing = 0.025;
            xStart = 0.5 - (xSpacing*((self.NumPages - 1)/2));
            xFinish = 0.5 + (xSpacing*((self.NumPages - 1)/2));
            xData = xStart:xSpacing:xFinish;
            cData = 0.5*ones([self.NumPages,3]);
            cData(1,:) = [0 0 0];
            
            self.DotHandle = scatter(xData,yData,10,cData,...
                'Parent',self.DotAxesHandle,...
                'MarkerEdgeColor','none',...
                'MarkerFaceColor','flat');
            
            set(self.DotAxesHandle,'XLim',[0 1],'YLim',[0 1],'Visible','off');
            
        end
        
        function createTextMessageArray(self)
            msgTxtWidth = self.Position(3) - (2*self.Offset);
            msgTxtXOffset = self.Offset;
            msgTxtYOffset = (2*self.Offset) + self.OKButtonHeight;
            msgTxtHeight = max(0,self.Position(4) - self.ImageHeight - self.DotHeight - self.Offset - msgTxtYOffset);
            msgPos = [msgTxtXOffset, msgTxtYOffset, msgTxtWidth, msgTxtHeight];
            
            msgHandle = uicontrol(self.FigureHandle,self.Font, ...
                    'Style','text', ...
                    'Units','points', ...
                    'Position', msgPos, ...
                    'String',' ', ...
                    'Tag','MessageBox', ...
                    'HorizontalAlignment','left', ...
                    'BackgroundColor',self.FigureHandle.Color, ...
                    'ForegroundColor',[0 0 0]);
                
            msgAxesHandle = axes('Parent',self.FigureHandle ,'Position',[0 0 1 1],'Visible','off');
            
            for idx = 1:self.NumPages
                
                [wrapString,newMsgTxtPos] = textwrap(msgHandle,self.MessageStrings(idx),100);
                
                self.TextHandleArray{idx} = text('Parent',msgAxesHandle, ...
                    'Units','points', ...
                    'String',wrapString, ...
                    'Color',[0 0 0], ...
                    self.Font, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','bottom', ...
                    'Interpreter','none', ...
                    'Tag','MessageBox',...
                    'Visible','off');

                textExtent = get(self.TextHandleArray{idx}, 'Extent');

                %textExtent and extent from uicontrol are not the same. For Windows, extent from uicontrol is larger
                %than textExtent. But on Macs, it is reverse. Pick the max value.
                msgTxtWidth = max([msgTxtWidth newMsgTxtPos(3) textExtent(3)]);
                msgTxtHeight = max([msgTxtHeight newMsgTxtPos(4) textExtent(4)]);
            end
            
            delete(msgHandle);
            
            self.Position(3) = msgTxtWidth + (2*self.Offset);
            self.Position(4) = self.OKButtonHeight + self.ImageHeight + self.DotHeight + msgTxtHeight + (4*self.Offset);
        end
        
        function createOKButton(self)
            self.OKXOffset=(self.Position(3) - self.OKButtonWidth)/2;
            okPos = [self.OKXOffset, self.Offset, self.OKButtonWidth, self.OKButtonHeight, ];
            self.OKButton = uicontrol(self.FigureHandle,self.Font, ...
                'Style','pushbutton', ...
                'Units','points', ...
                'Position', okPos, ...
                'Callback',@self.closePopup, ...
                'KeyPressFcn',@self.doKeyPress, ...
                'String',getString(message('MATLAB:uistring:popupdialogs:OK')), ...
                'HorizontalAlignment','center', ...
                'Tag','OKButton');
        end
        
        function createRightButton(self)            
            rightPos = [self.Position(3)-self.Offset-self.ArrowButtonHeight, self.Position(4)/2, self.ArrowButtonHeight, self.ArrowButtonHeight];
            self.RightButton = uicontrol(self.FigureHandle,...
                'Style','pushbutton', ...
                'Units','points', ...
                'Position', rightPos, ...
                'Callback',@self.moveRight, ...
                'KeyPressFcn',@self.doKeyPress, ...
                'HorizontalAlignment','center', ...
                'Tag','RightButton',...
                'CData',self.getArrowIcon());
        end
        
        function createLeftButton(self)
            leftPos = [self.Offset, self.Position(4)/2, self.ArrowButtonHeight, self.ArrowButtonHeight];
            self.LeftButton = uicontrol(self.FigureHandle,...
                'Style','pushbutton', ...
                'Units','points', ...
                'Position', leftPos, ...
                'Callback',@self.moveLeft, ...
                'KeyPressFcn',@self.doKeyPress, ...
                'HorizontalAlignment','center', ...
                'Tag','LeftButton',...
                'CData',fliplr(self.getArrowIcon()));
        end
        
        function createCheckBox(self)
            
            % Only create check box if setting exists
            if isempty(self.Setting)
                return;
            end
            
            checkPos = [self.Offset, self.Offset, 15, 10];
            self.CheckBox = uicontrol('Style','checkbox',...
                'Parent',self.FigureHandle,...
                'Units','Points',...
                'Position',checkPos,...
                'Value',0,...
                'Tag','CheckBox');
            
            chkLabelXOffset = self.Offset + 15;
            chkLabelXWidth = self.OKXOffset - chkLabelXOffset;
            yPos = self.Font.FontSize;
            chkLabelPos = [chkLabelXOffset, self.Offset, chkLabelXWidth, yPos+2];
            
            self.CheckBoxText = uicontrol(self.FigureHandle,self.Font, ...
                'Style','text', ...
                'Units','points', ...
                'Position', chkLabelPos, ...
                'String',getString(message(sprintf('images:imageRegistration:dontShowAgain'))), ...
                'Tag','checkBoxLabel', ...
                'HorizontalAlignment','left', ...
                'Enable','inactive', ...
                'ButtonDownFcn', @self.checkBoxLabelCallback);

        end
        
        function setFinalPositions(self)
            
            % Set final figure position
            set(self.FigureHandle,'Position',self.Position);
            
            % Set final OK button position
            self.OKXOffset = (self.Position(3) - self.OKButtonWidth)/2;
            set(self.OKButton,'Position',[self.OKXOffset self.Offset self.OKButtonWidth self.OKButtonHeight]);
            
            pos = self.CheckBoxText.Position;
            pos(3) = self.OKXOffset - (self.Offset + 15);
            set(self.CheckBoxText,'Position',pos);
            
            % Set final text position
            txtPos = [self.Offset, self.OKButtonHeight+(2*self.Offset), 0];
            cellfun(@(x) set(x,'Position',txtPos),self.TextHandleArray);
            
            % Set final image axes position
            imagePos = [(2*self.Offset)+self.ArrowButtonHeight, self.Position(4)-self.ImageHeight-self.Offset, self.Position(3)-(4*self.Offset)-(2*self.ArrowButtonHeight), self.ImageHeight];
            set(self.AxesHandle,'Position',imagePos);
            
            dotPos = [(2*self.Offset)+self.ArrowButtonHeight, self.Position(4)-self.ImageHeight-self.DotHeight-self.Offset, self.Position(3)-(4*self.Offset)-(2*self.ArrowButtonHeight), self.DotHeight];
            set(self.DotAxesHandle,'Position',dotPos);
            
            % Set final left and right button positions
            rightPos = [self.Position(3)-self.Offset-self.ArrowButtonHeight, self.Position(4)/2, self.ArrowButtonHeight, self.ArrowButtonHeight];
            set(self.RightButton,'Position',rightPos);
            
            leftPos = [self.Offset, self.Position(4)/2, self.ArrowButtonHeight, self.ArrowButtonHeight];
            set(self.LeftButton,'Position',leftPos);
            
        end
        
    end
    
    methods (Access = private)
        % Callbacks
        function doKeyPress(self,obj,evt)
            switch(evt.Key)
                case 'right'
                    self.moveRight()
                case 'left'
                    self.moveLeft()
                case {'return','space','escape'}
                    self.closePopup(obj,evt);
            end
        end
        
        function checkBoxLabelCallback(self,varargin)
            if ~isempty(self.CheckBox)
                self.CheckBox.Value = ~self.CheckBox.Value;
            end
        end
        
        function moveRight(self,varargin)
            if self.CurrentIndex < self.NumPages
                set(self.TextHandleArray{self.CurrentIndex},'Visible','off');
                self.CurrentIndex = self.CurrentIndex + 1;
                self.updatePage();
            end
        end
        
        function moveLeft(self,varargin)
            if self.CurrentIndex > 1
                set(self.TextHandleArray{self.CurrentIndex},'Visible','off');
                self.CurrentIndex = self.CurrentIndex - 1;
                self.updatePage();
            end
        end
        
        function closePopup(self,varargin)
            if ~isempty(self.CheckBox) && self.CheckBox.Value
                self.Setting.PersonalValue = false;
            end            
            delete(gcf);
        end
        
        function updatePage(self)
            
            cData = 0.5*ones([self.NumPages,3]);
            cData(self.CurrentIndex,:) = [0 0 0];
            self.DotHandle.CData = cData;
            
            set(self.TextHandleArray{self.CurrentIndex},'Visible','on');
            I = imread(self.ImagePaths{self.CurrentIndex});
            imshow(I,'Parent',self.AxesHandle);
            
            if self.CurrentIndex == 1
                set(self.LeftButton,'Visible','off');
            else
                set(self.LeftButton,'Visible','on');
            end
            
            if self.CurrentIndex == self.NumPages
                set(self.RightButton,'Visible','of');
            else
                set(self.RightButton,'Visible','on');
            end
            
        end
        
    end
    
    methods
        % Set/Get methods
        function set.CurrentIndex(self,idx)
            idx = round(idx);
            assert(idx >= 1 && idx <= self.NumPages,'Invalid index requested.');
            self.CurrentIndexInternal = idx;
            self.updatePage();
        end
        
        function idx = get.CurrentIndex(self)
            idx = self.CurrentIndexInternal;
        end
    end
    
    methods (Static)
        
        function icon = getArrowIcon()
            arrowIcon = load(fullfile(matlabroot,'toolbox','images','icons','binary_arrow_icon.mat'));
            icon = double(repmat(arrowIcon.arrow,[1 1 3]));
            icon(icon == 1) = NaN;
        end
    end
    
end
