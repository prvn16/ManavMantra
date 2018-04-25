function lorenz(action)
%LORENZ Plot the orbit around the Lorenz chaotic attractor.
%   This demo animates the integration of  the
%   three coupled nonlinear differential equations
%   that define the "Lorenz Attractor", a chaotic
%   system first described by Edward Lorenz of
%   the Massachusetts Institute of Technology.
%
%   As the integration proceeds you will see a
%   point moving around in a curious orbit in
%   3-D space known as a strange attractor. The
%   orbit is bounded, but not periodic and not
%   convergent (hence the word "strange").
%
%   Use the "Start" and "Stop" buttons to control
%   the animation.

%   Adapted for Demo by Ned Gulley, 6-21-93; jae Roh, 10-15-96
%   Copyright 1984-2014 The MathWorks, Inc.

% The values of the global parameters are
global SIGMA RHO BETA
SIGMA = 10.;
RHO = 28.;
BETA = 8./3.;

% Possible actions:
% initialize
% close

% Information regarding the play status will be held in
% the axis user data according to the following table:
play = 1;

if nargin<1,
    action = 'initialize';
end

switch action
    case 'initialize'
        oldFigNumber = watchon;
        
        figNumber = figure( ...
            'Name',getString(message('MATLAB:demos:lorenz:TitleLorenzAttractor')), ...
            'NumberTitle','off', ...
            'Toolbar', 'none', ...
            'Visible','off');
        colordef(figNumber,'black')
        axes( ...
            'Units','normalized', ...
            'Position',[0.07 0.10 0.74 0.95], ...
            'Visible','off');
        
        text(0,0,getString(message('MATLAB:demos:lorenz:LabelPressTheStartButton')), ...
            'HorizontalAlignment','center');
        axis([-1 1 -1 1]);
        
        % ===================================
        % Information for all buttons
        xPos = 0.85;
        btnLen = 0.10;
        btnWid = 0.10;
        % Spacing between the button and the next command's label
        spacing = 0.05;
        
        % ====================================
        % The CONSOLE frame
        frmBorder = 0.02;
        yPos = 0.05-frmBorder;
        frmPos = [xPos-frmBorder yPos btnLen+2*frmBorder 0.9+2*frmBorder];
        uicontrol( ...
            'Style','frame', ...
            'Units','normalized', ...
            'Position',frmPos, ...
            'BackgroundColor',[0.50 0.50 0.50]);
        
        % ====================================
        % The START button
        btnNumber = 1;
        yPos = 0.90-(btnNumber-1)*(btnWid+spacing);
        labelStr = getString(message('MATLAB:demos:shared:LabelStart'));
        callbackStr = 'lorenz(''start'');';
        
        % Generic button information
        btnPos = [xPos yPos-spacing btnLen btnWid];
        startHndl = uicontrol( ...
            'Style','pushbutton', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'String',labelStr, ...
            'Interruptible','on', ...
            'Callback',callbackStr);
        
        % ====================================
        % The STOP button
        btnNumber = 2;
        yPos = 0.90-(btnNumber-1)*(btnWid+spacing);
        labelStr = getString(message('MATLAB:demos:shared:LabelStop'));
        % Setting userdata to -1 (= stop) will stop the demo.
        callbackStr = 'set(gca,''Userdata'',-1)';
        
        % Generic  button information
        btnPos = [xPos yPos-spacing btnLen btnWid];
        stopHndl = uicontrol( ...
            'Style','pushbutton', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'Enable','off', ...
            'String',labelStr, ...
            'Callback',callbackStr);
        
        % ====================================
        % The INFO button
        labelStr = getString(message('MATLAB:demos:shared:LabelInfo'));
        callbackStr = 'lorenz(''info'')';
        infoHndl = uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'position',[xPos 0.20 btnLen 0.10], ...
            'string',labelStr, ...
            'call',callbackStr);
        
        % ====================================
        % The CLOSE button
        labelStr = getString(message('MATLAB:demos:shared:LabelClose'));
        callbackStr = 'close(gcf)';
        closeHndl = uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'position',[xPos 0.05 btnLen 0.10], ...
            'string',labelStr, ...
            'call',callbackStr);
        
        % Uncover the figure
        hndlList = [startHndl stopHndl infoHndl closeHndl];
        set(figNumber,'Visible','on', ...
            'UserData',hndlList);
        
        set(figNumber, 'CloseRequestFcn', 'clear global SIGMA RHO BETA;closereq');
        watchoff(oldFigNumber);
        figure(figNumber);
        
    case 'start'
        axHndl = gca;
        figNumber = gcf;
        hndlList = get(figNumber,'UserData');
        startHndl = hndlList(1);
        stopHndl = hndlList(2);
        infoHndl = hndlList(3);
        closeHndl = hndlList(4);
        set([startHndl closeHndl infoHndl],'Enable','off');
        set(stopHndl,'Enable','on');
        
        % ====== Start of Demo
        % The graphics axis limits are set to values known
        % to contain the solution.
        set(axHndl, ...
            'XLim',[0 50],'YLim',[-20 20],'ZLim',[-30 30], ...
            'Userdata',play, ...
            'XTick',[],'YTick',[],'ZTick',[], ...
            'SortMethod','childorder', ...
            'Visible','on', ...
            'NextPlot','add', ...
            'Userdata',play, ...
            'View',[-37.5,30], ...
            'Clipping','off');
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        
        % The orbit ranges chaotically back and forth around two different points,
        % or attractors.  It is bounded, but not periodic and not convergent.
        % The numerical integration, and the display of the evolving solution,
        % are handled by the function ODE23P.
        
        FunFcn = 'lorenzeq';
        % The initial conditions below will produce good results
        % y0 = [20 5 -5];
        % Random initial conditions
        y0(1) = rand*30+5;
        y0(2) = rand*35-30;
        y0(3) = rand*40-5;
        t0 = 0;
        tfinal = 100;
        pow = 1/3;
        tol = 0.001;
        
        t = t0;
        hmax = (tfinal - t)/5;
        hmin = (tfinal - t)/200000;
        h = (tfinal - t)/100;
        y = y0(:);
        
        % Save L steps and plot like a comet tail.
        L = 50;
        Y = y*ones(1,L);
        
        cla;
        
        head = line('color','r', 'Marker','.','MarkerSize',25,'LineStyle','none','XData',y(1),'YData',y(2),'ZData',y(3)) ;
        body = animatedline('color','y', 'LineStyle','-') ;
        tail = animatedline('color','b', 'LineStyle','-') ;
        
        % The main loop
        count = 0;
        while (get(axHndl,'Userdata') == play) && (h >= hmin)
            count = count + 1;
            if t + h > tfinal
                h = tfinal - t;
            end
            % Compute the slopes
            s1 = feval(FunFcn, t, y);
            s2 = feval(FunFcn, t+h, y+h*s1);
            s3 = feval(FunFcn, t+h/2, y+h*(s1+s2)/4);
            
            % Estimate the error and the acceptable error
            delta = norm(h*(s1 - 2*s3 + s2)/3,'inf');
            tau = tol*max(norm(y,'inf'),1.0);
            
            % Update the solution only if the error is acceptable
            if delta <= tau
                t = t + h;
                y = y + h*(s1 + 4*s3 + s2)/6;
                
                % Update the plot
                Y = [y Y(:,1:L-1)];
                set(head, 'XData', Y(1,1), 'YData', Y(2,1), 'ZData', Y(3,1));
                addpoints(body, Y(1,2), Y(2,2), Y(3,2));
                addpoints(tail, Y(1,L), Y(2,L), Y(3,L));
                
                % Update the animation every ten steps
                if ~mod(count,10)
                    drawnow;
                end
                
            end
            
            % Update the step size
            if delta ~= 0.0
                h = min(hmax, 0.9*h*(tau/delta)^pow);
            end
            
            % Bail out if the figure was closed.
            if ~ishandle(axHndl)
                return
            end
            
        end    % Main loop ...
        % ====== End of Demo
        % Flush all graphics
        drawnow;
        set([startHndl closeHndl infoHndl],'Enable','on');
        set(stopHndl,'Enable','off');
        
    case 'info'
        helpwin(mfilename);
        
end    % if strcmp(action, ...


% ===============================================================================
function ydot = lorenzeq(t,y)
% LORENZEQ Equation of the Lorenz chaotic attractor.
%   ydot = lorenzeq(t,y).
%   The differential equation is written in almost linear form.

global SIGMA RHO BETA

A = [ -BETA    0     y(2)
    0  -SIGMA   SIGMA
    -y(2)   RHO    -1  ];

ydot = A*y;
