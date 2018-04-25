% Graphical user interface components and tools
% MATLAB Version 9.4 (R2018a) 06-Feb-2018 
%
% GUI functions.
%   uicontrol  		- Create user interface control.
%   uimenu     		- Create user interface menu.
%   dragrect   		- Drag XOR rectangles with mouse.
%   ginput     		- Graphical input from mouse.
%   selectmoveresize	- Interactively select, move, resize, or copy objects.
%   uipanel            	- Uipanel container object.
%   uiresume   		- Resume execution of blocked program.
%   uistack    		- Reorder the visual stacking order of objects.
%   uiwait     		- Block execution and wait for resume.
%   waitfor    		- Block execution and wait for event.
%   waitforbuttonpress	- Wait for key/buttonpress over figure.
%
% GUI design tools.
%   align               - Align uicontrols and axes.
%   inspect             - Open the inspector and inspect object properties
%   propedit            - Graphical property editor
%  
% Dialog boxes.
%   dialog       	- Create dialog figure.
%   errordlg     	- Error dialog box.
%   helpdlg      	- Help dialog box.
%   inputdlg     	- Input dialog box.
%   listdlg      	- List selection dialog box.
%   menu         	- Generate a menu of choices for user input.
%   msgbox       	- Message box.
%   questdlg     	- Question dialog box.
%   uigetdir     	- Standard open directory dialog box
%   uigetfile    	- Standard open file dialog box.
%   uigetpref    	- question dialog box with preference support
%   uiputfile    	- Standard save file dialog box.
%   uiopen       	- Present file selection dialog with appropriate file filters.
%   uisave       	- GUI Helper function for SAVE
%   uisetcolor   	- Color selection dialog box.
%   uisetfont    	- Font selection dialog box.
%   waitbar      	- Display wait bar.
%   warndlg      	- Warning dialog box.
%
% Preferences.
%   addpref             - Add preference.
%   getpref             - Get preference.
%   ispref              - Test for existence of preference.
%   rmpref              - Remove preference.
%   setpref             - Set preference.
% 
% Miscellaneous utilities.
%   allchild   		- Get all object children
%   clipboard  		- Copy and paste strings to and from system clipboard.
%   findfigs   		- Position figures on to screen.
%   getpixelposition   	- Get the position of an HG object in pixel units.
%   listfonts  		- Get list of available system fonts in cell array.
%   movegui    		- Move a figure window to a specified position on the screen.
%   guidata    		- Store or retrieve application data.
%   guihandles 		- Return a structure of handles.
%   setpixelposition	- Set position HG object in pixels.
%   textwrap   		- Return wrapped string matrix for given UI Control.
%   uibuttongroup      	- Component to exclusively manage radiobuttons/togglebuttons.
%   uipushtool          - Create a pushbutton in the toolbar of a figure window.
%   uisetpref     	- manages preferences used in UIGETPREF
%   uitable		- creates a two dimensional graphic table component
%   uitoggletool        - Create a togglebutton in the toolbar of a figure window.
%   uitoolbar           - Create a toolbar in a figure window.

% Utilities, helper functions and undocumented functions
%   activateuimode	- This function is undocumented and will change in a future release
%   awtcreate		- WARNING: This feature is not supported in MATLAB
%   awtinvoke		- WARNING: This feature is not supported in MATLAB
%   btndown    		- Depress button in toolbar button group.
%   btngroup   		- Create toolbar button group.
%   btnicon    		- Icon library for BTNGROUP.
%   btnpress   		- Button press manager for toolbar button group.
%   btnresize  		- Resize Button Group.
%   btnstate   		- Query state of toolbar button group.
%   btnup      		- Raise button in toolbar button group.
%   createwinmenu   - This function is undocumented and will change in a future release
%   desktopmenufcn     	- Implements the Desktop menu of undocked figure windows.
%   editmenufcn   	- Implements part of the figure edit menu.
%   export2wsdlg       	- Exports variables to the workspace. 
%   fignamer   		- This function is undocumented and will change in a future release
%   figuretools        	- Create default menus or toolbar.
%   filemenufcn   	- Implements part of the figure file menu.
%   getptr     		- This function is undocumented and will change in a future release
%   getuimode		- This function is undocumented and will change in a future release
%   hasuimode		- This function is undocumented and will change in a future release
%   helpmenufcn        	- Implements part of the figure help menu.
%   icondisp   		- Display icons in BTNICON
%   insertmenufcn      	- Implements part of the figure insert menu.
%   isactiveuimode	- This function is undocumented and will change in a future release
%   javacomponent	- WARNING: This feature is not supported in MATLAB
%   makemenu  	        - This function is undocumented and will change in a future release
%   overobj    		- This function is undocumented and will change in a future release
%   remapfig   		- This function is undocumented and will change in a future release
%   setptr     		- This function is undocumented and will change in a future release
%   tabdlg     	        - This function is undocumented and will change in a future release
%   tipoftheday		- This function is undocumented and will change in a future release
%   toolsmenufcn       	- Implements part of the figure tools menu.
%   uiclearmode 		- This function is undocumented and will change in a future release
%   uicontainer		- WARNING: This feature is not supported in MATLAB
%   uiflowcontainer	- WARNING: This feature is not supported in MATLAB
%   uigetmodemanager   	- This undocumented function will be removed in a future release.
%   uigettool		- This function is undocumented and will change in a future release
%   uigridcontainer	- WARNING: This feature is not supported in MATLAB
%   uiload       	- This function is undocumented and will change in a future release
%   uimode		- This function is undocumented and will change in a future release
%   uirestore  		- This function is undocumented and will change in a future release
%   uisuspend  		- This function is undocumented and will change in a future release
%   uitab		- WARNING: This feature is not supported in MATLAB
%   uitabgroup		- WARNING: This feature is not supported in MATLAB
%   uitoolfactory	- This undocumented function may change in a future release.
%   uitree		- WARNING: This feature is not supported in MATLAB
%   uitreenode		- WARNING: This feature is not supported in MATLAB
%   uiundo		- Internal Use Only
%   usejavacomponent    - WARNING: This feature is not supported in MATLAB
%   viewmenufcn        	- Implements part of the figure view menu.
%   winmenu    		- Create submenu for "Window" menu item.
%   
% Deprecated functions.
%   cshelp		 - Installs GUI-wide context sensitive help.
%   figflag             - True if figure is currently displayed on screen.
%   getstatus           - Get status text string in figure.
%   menulabel           - Parse menu label for keyboard equivalent and accelerator keys.
%   popupstr   	        - Get popup menu selection string.
%   setstatus  	        - Set status text string in figure.
%
% Deprecated functions to be removed.
%   uigettoolbar        - Gets the figure's toolbar(s).

% Copyright 1984-2018 The MathWorks, Inc. 

