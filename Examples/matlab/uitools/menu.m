function k = menu(xHeader,varargin)
%MENU   Generate a menu of choices for user input.
%   CHOICE = MENU(HEADER, ITEM1, ITEM2, ... ) displays the HEADER
%   string followed in sequence by the menu-item strings: ITEM1, ITEM2,
%   ... ITEMn. Returns the number of the selected menu-item as CHOICE,
%   a scalar value. There is no limit to the number of menu items.
%
%   CHOICE = MENU(HEADER, ITEMLIST) where ITEMLIST is a string, cell
%   array is also a valid syntax.
%
%   On most graphics terminals MENU will display the menu-items as push
%   buttons in a figure window, otherwise they will be given as a numbered
%   list in the command window (see example, below).
%
%   Example:
%       K = menu('Choose a color','Red','Blue','Green')
%       %creates a figure with buttons labeled 'Red', 'Blue' and 'Green'
%       %The button clicked by the user is returned as K (i.e. K = 2 
%       implies that the user selected Blue).
%
%   See also UICONTROL, UIMENU, GUIDE.

%   Copyright 1984-2012 The MathWorks, Inc.

if nargin > 0
    xHeader = convertStringsToChars(xHeader);
end

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

%=========================================================================
% Check input
%-------------------------------------------------------------------------
if nargin < 2
    disp(getString(message('MATLAB:uistring:menu:NoMenuItemsToChooseFrom')))
    k=0;
    return;
elseif nargin==2 && iscell(varargin{1})
  ArgsIn = varargin{1}; % a cell array was passed in
else
  ArgsIn = varargin;    % use the varargin cell array
end

%-------------------------------------------------------------------------
% Create the appropriate menu based on HG availability
%-------------------------------------------------------------------------
if matlab.ui.internal.isFigureShowEnabled()
    % Create a GUI menu to acquire answer "k"
    k = local_GUImenu( xHeader, ArgsIn );
else
    % Create an ascii menu to acquire answer "k"
    k = local_ASCIImenu( xHeader, ArgsIn );
end % if

%%#########################################################################
%   END   :  main function "menu"
%%#########################################################################

%%#########################################################################
%  BEGIN  :  local function local_ASCIImenu
%%#########################################################################
function k = local_ASCIImenu( xHeader, xcItems )

% local function to display an ascii-generated menu and return the user's
% selection from that menu as an index into the xcItems cell array

%-------------------------------------------------------------------------
% Calculate the number of items in the menu
%-------------------------------------------------------------------------
numItems = length(xcItems);

%-------------------------------------------------------------------------
% Continuous loop to redisplay menu until the user makes a valid choice
%-------------------------------------------------------------------------
while 1
    % Display the header
    disp(' ')
    disp(['----- ',xHeader,' -----'])
    disp(' ')
    % Display items in a numbered list
    for n = 1 : numItems
        disp( [ '      ' int2str(n) ') ' xcItems{n} ] )
    end
    disp(' ')
    % Prompt for user input
    k = input('Select a menu number: ');
    % Check input:
    % 1) make sure k has a value
    if isempty(k), k = -1; end
    % 2) make sure the value of k is valid
    if  (k < 1) || (k > numItems) ...
        || ~isa(k,'double') ...
        || ~isreal(k) || (isnan(k)) || isinf(k)
        % Failed a key test. Ask question again
        disp(' ')
        disp(getString(message('MATLAB:uistring:menu:SelectionOutOfRangeTryAgain')))
    else
        % Passed all tests, exit loop and return k
        return
    end % if k...
end % while 1

%%#########################################################################
%   END   :  local function local_ASCIImenu
%%#########################################################################

%%#########################################################################
%  BEGIN  :  local function local_GUImenu
%%#########################################################################
function k = local_GUImenu( xHeader, xcItems )

% local function to display a Handle Graphics menu and return the user's
% selection from that menu as an index into the xcItems cell array

%=========================================================================
% SET UP
%=========================================================================
% Set spacing and sizing parameters for the GUI elements
%-------------------------------------------------------------------------
MenuUnits   = 'pixels'; % units used for all HG objects
textPadding = [22 12];   % extra [Width Height] on uicontrols to pad text
uiGap       = 5;       % space between uicontrols
uiBorder    = 10;       % space between edge of figure and any uicontrol
winTopGap   = 60;       % gap between top of screen and top of figure **
winLeftGap  = 30;       % gap between side of screen and side of figure **
winWideMin  = 140;      % minimum window width necessary to show title

% ** "figure" ==> viewable figure. You must allow space for the OS to add
% a title bar (aprx 42 points on Mac and Windows) and a window border
% (usu 2-6 points). Otherwise user cannot move the window.

%-------------------------------------------------------------------------
% Calculate the number of items in the menu
%-------------------------------------------------------------------------
numItems = length( xcItems );

%=========================================================================
% BUILD
%=========================================================================
% Create a generically-sized invisible figure window
%------------------------------------------------------------------------
menuFig = figure( 'WindowStyle', 'normal', ...
                  'Units'       ,MenuUnits, ...
                  'Visible'     ,'off', ...
                  'NumberTitle' ,'off', ...
                  'Name'        ,getString(message('MATLAB:uistring:menu:MENU')), ...
                  'Resize'      ,'off', ...
                  'Colormap'    ,[], ...
                  'MenuBar'     ,'none',...
                  'ToolBar' 	,'none' ...
                   );

%------------------------------------------------------------------------
% Add generically-sized header text with same background color as figure
%------------------------------------------------------------------------
hText = uicontrol(...
        'Parent'      ,menuFig, ...
        'Style'       ,'text', ...
        'String'      ,xHeader, ...
        'Units'       ,MenuUnits, ...
        'Position'    ,[ 100 100 100 20 ], ...
        'HorizontalAlignment'  ,'center',...
        'BackgroundColor'  ,get(menuFig,'Color') );

% Record extent of text string
maxsize = get( hText, 'Extent' );
textWide  = maxsize(3);
textHigh  = maxsize(4);

%------------------------------------------------------------------------
% Add generically-spaced buttons below the header text
%------------------------------------------------------------------------
% Loop to add buttons in reverse order (to automatically initialize numitems).
% Note that buttons may overlap, but are placed in correct position relative
% to each other. They will be resized and spaced evenly later on.

hBtn = zeros(numItems, 1);
for idx = numItems : -1 : 1  % start from top of screen and go down
    n = numItems - idx + 1;  % start from 1st button and go to last
    % make a button
    hBtn(n) = uicontrol( ...
               'Parent'         ,menuFig, ...
               'Units'          ,MenuUnits, ...
               'Position'       ,[uiBorder uiGap*idx textHigh textWide], ...
               'Callback'       , {@menucallback, n}, ...
               'String'         ,xcItems{n} );
end % for

%=========================================================================
% TWEAK
%=========================================================================
% Calculate Optimal UIcontrol dimensions based on max text size
%------------------------------------------------------------------------
cAllExtents = get( hBtn, {'Extent'} );  % put all data in a cell array
AllExtents  = cat( 1, cAllExtents{:} ); % convert to an n x 3 matrix
maxsize     = max( AllExtents(:,3:4) ); % calculate the largest width & height
maxsize     = maxsize + textPadding;    % add some blank space around text
btnHigh     = maxsize(2);
btnWide     = maxsize(1);

%------------------------------------------------------------------------
% Retrieve screen dimensions (in correct units)
%------------------------------------------------------------------------
screensize = get(0,'ScreenSize');  % record screensize

%------------------------------------------------------------------------
% How many rows and columns of buttons will fit in the screen?
% Note: vertical space for buttons is the critical dimension
% --window can't be moved up, but can be moved side-to-side
%------------------------------------------------------------------------
openSpace = screensize(4) - winTopGap - 2*uiBorder - textHigh;
numRows = min( floor( openSpace/(btnHigh + uiGap) ), numItems );
if numRows == 0; numRows = 1; end % Trivial case--but very safe to do
numCols = ceil( numItems/numRows );

%------------------------------------------------------------------------
% Resize figure to place it in top left of screen
%------------------------------------------------------------------------
% Calculate the window size needed to display all buttons
winHigh = numRows*(btnHigh + uiGap) + textHigh + 2*uiBorder;
winWide = numCols*(btnWide) + (numCols - 1)*uiGap + 2*uiBorder;

% Make sure the text header fits
if winWide < (2*uiBorder + textWide)
    winWide = 2*uiBorder + textWide;
end

% Make sure the dialog name can be shown
if winWide < winWideMin %pixels
    winWide = winWideMin;
end

% Determine final placement coordinates for bottom of figure window
bottom = screensize(4) - (winHigh + winTopGap);

% Set figure window position
set( menuFig, 'Position', [winLeftGap bottom winWide winHigh] );

%------------------------------------------------------------------------
% Size uicontrols to fit everyone in the window and see all text
%------------------------------------------------------------------------
% Calculate coordinates of bottom-left corner of all buttons
xPos = ( uiBorder + (0:numCols-1)'*( btnWide + uiGap )*ones(1,numRows) )';
xPos = xPos(1:numItems); % [ all 1st col; all 2nd col; ...; all nth col ]
yPos = ( uiBorder + (numRows-1:-1:0)'*( btnHigh + uiGap )*ones(1,numCols) );
yPos = yPos(1:numItems); % [ rows 1:m; rows 1:m; ...; rows 1:m ]

% Combine with desired button size to get a cell array of position vectors
allBtn   = ones(numItems,1);
uiPosMtx = [ xPos(:), yPos(:), btnWide*allBtn, btnHigh*allBtn ];
cUIPos   = num2cell( uiPosMtx( 1:numItems, : ), 2 );

% adjust all buttons
set( hBtn, {'Position'}, cUIPos );

%------------------------------------------------------------------------
% Align the Text and Buttons horizontally and distribute them vertically
%------------------------------------------------------------------------

% Calculate placement position of the Header
textWide = winWide - 2*uiBorder;

% Move Header text into correct position near the top of figure
set( hText, ...
     'Position', [ uiBorder winHigh-uiBorder-textHigh textWide textHigh ] );

%=========================================================================
% ACTIVATE
%=========================================================================
% Make figure visible
%------------------------------------------------------------------------
set( menuFig, 'Visible', 'on' );

%------------------------------------------------------------------------
% Wait for choice to be made (i.e UserData must be assigned)...
%------------------------------------------------------------------------
waitfor(menuFig,'userdata')

%------------------------------------------------------------------------
% Selection has been made or figure has been deleted. 
% Assign k and delete the Menu figure if it is still valid.
%------------------------------------------------------------------------
if ishghandle(menuFig)
    k = get(menuFig,'UserData');
    delete(menuFig)
else
    % The figure was deleted without a selection. Return 0.
    k = 0;
end

%%#########################################################################
%   END   :  local function local_GUImenu
%%#########################################################################


function menucallback(btn, evd, index)                                 %#ok
set(gcbf, 'UserData', index);
