function fifteen(action)
%FIFTEEN A sliding puzzle of fifteen squares and sixteen slots.
%   This example shows how to use SWITCH statements to control the flow of
%   program execution. Here, a SWITCH statement is used in conjunction
%   with a GUI to drive a puzzle program. Based on the action of the GUI,
%   the program will call itself using different inputs that switch among
%   tasks.
%
%   Solve the puzzle by sequentially lining all fifteen squares up, leaving
%   the last square empty.
%
%   Moves are made by clicking on a tile which lies in either the
%   same row or column as the open slot.

% Copyright 1984-2014 The MathWorks, Inc.

if nargin<1
   % Set up a working figure window and store it in the UserData for
   % action 'setup' to use.
   figure_h = figure;
   set(figure_h,'Units','points')
   set(figure_h,'UserData',figure_h);
   action = 'initialize';
end

% Actions to be switched on are: initialize, scramble, move, help.
switch action
   
   case 'initialize';
      % Set up the screen.
      figure_h = get(gcf,'UserData');
      
      set(figure_h,...
         'Color',[0.4 0.4 0.4],...
         'Menubar','none',...
         'Name',getString(message('MATLAB:demos:fifteen:TitleTheSlidingPuzzle')),...
         'NumberTitle','off',...
         'Position',[200 200 310 255],...
         'Resize','off');
      axis off
      
      % Create status bar.
      % Set the tag to 'click' mode (set to 'winner' mode is user has won).
      uicontrol(figure_h,...
         'BackgroundColor',[0.4 0.4 0.4],...
         'ForegroundColor',[1 1 1], ...
         'HorizontalAlignment','center',...
         'FontSize',18,...
         'Units','points',...
         'Position',[15 10 215 25],...
         'String',getString(message('MATLAB:demos:fifteen:LabelClickOnATileToSlideIt')),...
         'Style','text',...
         'Tag','click');
      
      % Create utility buttons (new game, help, close).
      % New game.
      uicontrol(figure_h,...
         'Callback','fifteen scramble',...
         'FontSize',12, ...
         'Units','points',...
         'Position',[235 175 65 30],...
         'String',getString(message('MATLAB:demos:fifteen:LabelNewGame')),...
         'Style','pushbutton');
      
      % Help.
      uicontrol(figure_h,...
         'Callback','fifteen help',...
         'Fontsize',12, ...
         'Units','points',...
         'Position',[235 110 65 30],...
         'String',getString(message('MATLAB:demos:shared:LabelHelp')),...
         'Style','pushbutton');
      
      % Close.
      uicontrol(figure_h,...
         'Callback','close(gcf)',...
         'Fontsize',12, ...
         'Units','points',...
         'Position',[235 45 65 30],...
         'String',getString(message('MATLAB:demos:shared:LabelClose')),...
         'Style','pushbutton');
      
      % Set up the game board.
      irows = 1;
      for counter = 1:16
         jcols = rem(counter,4);
         if jcols == 0
            jcols = 4;
         end
         position = [40*jcols 205-40*irows 40 40];
         index = (irows-1)*4+jcols;
         if jcols == 4
            irows = irows+1;
         end
         board.squares(index) = uicontrol(figure_h,...
            'FontSize',18,...
            'FontWeight','bold',...
            'Units','points',...
            'Position',position,...
            'Style','pushbutton',...
            'Tag',num2str(index));
      end
      
      % Save all the handles in the figure windows UserData (over-writing the
      % handle of the figure window since we do not need it anymore).
      set(figure_h,'userdata',board);
      fifteen('scramble')
      
   case 'scramble'
      score_board = randperm(16);
      % Wherever the location of '16' is is where we will start our open slot.
      num_16 = find(score_board == 16);
      board = get(gcf,'UserData');
      set(board.squares,...
         'BackgroundColor',[0.701961 0.701961 0.701961],...
         'Enable','on',...
         'Visible','on')
      set(board.squares,{'string'},num2cell(score_board)')
      
      % Change the value 16 (set it to black, disable it, and set the
      % string to empty; the color change will not take effect on the PC) and
      % turn the visibility of the board on.
      set(board.squares(num_16),...
         'BackgroundColor','black',...
         'Enable','off',...
         'String',' ');
      % Keep track of where the current free square is by storing it in
      % the board struct. We also want to keep track of the 'score'; this
      % way we know when we have won (i.e., when score(1:15) == 1:15).
      [board.free_square.x, board.free_square.y] = LocalGetXY(num_16);
      board.score = score_board;
      set(board.squares,...
         'Callback','fifteen move',...
         'Visible','on',...
         'UserData',board)
      
      % Since we could be restarting an old game (i.e., winner) we need to
      % check whether the 'winner' banner is up and, if so, change it.
      old_handle = findobj(gcf,'Tag','winner');
      if isempty(old_handle) == 0
         % We are in 'winner' mode; set back to 'click' mode.
         set(old_handle,...
            'String',getString(message('MATLAB:demos:fifteen:LabelClickOnATileToSlideIt')),...
            'Tag','click');
      end
      
      % Hide the object's handle from all other functions called at
      % the command line.
      set(gcf,'HandleVisibility','callback');
      
   case 'move'
      % Check that the move is legal.
      square_tag = str2double(get(gcbo,'Tag'));
      % Determine the x and y coordinates of the selected tile.
      [current.x, current.y] = LocalGetXY(square_tag);
      data = get(gcbo,'UserData');
      % Determine the x and y coordinates of the open tile.
      open.x = data.free_square.x;
      open.y = data.free_square.y;
      open_square = (open.x-1)*4+open.y;
      inc_by = 0;
      if current.x == open.x
         % The selected tile is on the same row as the open tile.
         loop = abs(current.y-open.y);  % 'loop' tells us how many tiles away we are
         inc_by = open.y<current.y;     % We need to know if we are moving right -> left or left -> right
         if inc_by == 0
            inc_by = -1;                 % We are moving right -> left
         end
      elseif current.y == open.y
         % The selected tile is in the same column as the open tile.
         loop = abs(current.x-open.x);  % 'loop' tells us how many tiles away we are
         direction = open.x<current.x;  % We need to know if we are moving up or moving down
         if direction == 1
            inc_by = 4;                  % We are moving up.
         else
            inc_by = -4;                 % We are moving down.
         end
      end
      
      if inc_by ~= 0
         % There was a legal move.
         square_handles = data.squares;
         score_board = data.score;
         set(square_handles(open_square),...
            'BackgroundColor',[0.701961 0.701961 0.701961],...
            'Enable','on');
         to_square = open_square;
         
         % Make the move.
         for index = 1:loop
            % Now slide over all the tiles between the selected tile and the
            % open tile.
            from_square = to_square+inc_by;
            from_value = get(square_handles(from_square),'String');
            set(square_handles(to_square),...
               'String',from_value);
            score_board(to_square) = str2double(from_value);
            to_square = from_square;
         end
         
         data.score = score_board;
         % Set up new free square.
         set(gcbo,...
            'BackgroundColor','black',...
            'Enable','off',...
            'String',' ');
         
         % Update the free square x and y coordinates.
         data.free_square.x = current.x;
         data.free_square.y = current.y;
         set(square_handles,'userdata',data);
         
         % Check for winner.
         if data.score(1:15) == 1:15
            % Change from 'click' mode to 'winner' mode.
            old_handle = findobj(gcf,'Tag','click');
            set(old_handle,...
               'String',getString(message('MATLAB:demos:fifteen:LabelWINNER')),...
               'Tag','winner');
         end
         
      end   % There was a legal move.
      
   case 'help'
      doc(mfilename);
      
   otherwise
      disp(getString(message('MATLAB:demos:fifteen:WarningUnknownAction',mfilename,action)))
      
end

% Calculate the xrow and ycol< of the tile.
function [x,y] = LocalGetXY(tile)

x = ceil(tile/4);
y = rem(tile,4);
if y == 0
   y = 4;
end
