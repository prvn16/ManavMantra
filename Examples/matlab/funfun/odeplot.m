function status = odeplot(t,y,flag,varargin)
%ODEPLOT  Time series ODE output function.
%   When the function odeplot is passed to an ODE solver as the 'OutputFcn'
%   property, i.e. options = odeset('OutputFcn',@odeplot), the solver calls
%   ODEPLOT(T,Y,'') after every timestep.  The ODEPLOT function plots all
%   components of the solution it is passed as it is computed, adapting
%   the axis limits of the plot dynamically.  To plot only particular
%   components, specify their indices in the 'OutputSel' property passed to
%   the ODE solver.  ODEPLOT is the default output function of the
%   solvers when they are called with no output arguments.
%
%   At the start of integration, a solver calls ODEPLOT(TSPAN,Y0,'init') to
%   initialize the output function.  After each integration step to new time
%   point T with solution vector Y the solver calls STATUS = ODEPLOT(T,Y,'').
%   If the solver's 'Refine' property is greater than one (see ODESET), then
%   T is a column vector containing all new output times and Y is an array
%   comprised of corresponding column vectors.  The STATUS return value is 1
%   if the STOP button has been pressed and 0 otherwise.  When the
%   integration is complete, the solver calls ODEPLOT([],[],'done').
%
%   See also ODEPHAS2, ODEPHAS3, ODEPRINT, ODE45, ODE15S, ODESET.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2016 The MathWorks, Inc.

    persistent TARGET_FIGURE TARGET_AXIS

    status = 0;         % Assume stop button wasn't pushed.
    callbackDelay = 1;  % Check Stop button every 1 sec.

    % support odeplot(t,y) [v5 syntax]
    if nargin < 3 || isempty(flag)
        flag = '';
    elseif isstring(flag) && isscalar(flag)
        flag = char(flag);
    end

    switch(flag)

      case ''    % odeplot(t,y,'')

        if (isempty(TARGET_FIGURE) || isempty(TARGET_AXIS))

            error(message('MATLAB:odeplot:NotCalledWithInit'));

        elseif (ishghandle(TARGET_FIGURE) && ishghandle(TARGET_AXIS))  % figure still open

            try
                ud = get(TARGET_FIGURE,'UserData');
                if ud.stop == 1  % Has stop button been pushed?
                    status = 1;
                else
                    for i = 1 : length(ud.anim)
                        addpoints(ud.anim(i),t,y(i,:));
                    end
                    if etime(clock,ud.callbackTime) < callbackDelay
                        drawnow update;
                    else
                        ud.callbackTime = clock;
                        set(TARGET_FIGURE,'UserData',ud);
                        drawnow;
                    end
                end
            catch ME
                error(message('MATLAB:odeplot:ErrorUpdatingWindow', ME.message));
            end

        end

      case 'init'    % odeplot(tspan,y0,'init')

        f = figure(gcf);
        TARGET_FIGURE = f;
        TARGET_AXIS = gca;
        ud = get(f,'UserData');

        % Initialize lines
        if ~ishold || ~isfield(ud,'lines')
            ud.lines = plot(t(1),y,'-o','Parent',TARGET_AXIS);
        end
        for i = 1 : length(y)
            ud.anim(i) = animatedline(t(1),y(i),'Parent',TARGET_AXIS,...
                                      'Color',get(ud.lines(i),'Color'),...
                                      'Marker',get(ud.lines(i),'Marker'));
        end

        if ~ishold
            set(TARGET_AXIS,'XLim',[min(t) max(t)]);
        end

        % The STOP button
        h = findobj(f,'Tag','stop');
        if isempty(h)
            pos = get(0,'DefaultUicontrolPosition');
            pos(1) = pos(1) - 15;
            pos(2) = pos(2) - 15;
            uicontrol( ...
                'Style','pushbutton', ...
                'String',getString(message('MATLAB:odeplot:ButtonStop')), ...
                'Position',pos, ...
                'Callback',@StopButtonCallback, ...
                'Tag','stop');
            ud.stop = 0;
        else
            % make sure it's visible
            set(h,'Visible','on');
            % don't change old ud.stop status
            if ~ishold || ~isfield(ud,'stop')
                ud.stop = 0;
            end
        end

        % Set figure data
        ud.callbackTime = clock;
        set(f,'UserData',ud);

        % fast update
        drawnow update;

      case 'done'    % odeplot([],[],'done')

        f = TARGET_FIGURE;
        TARGET_FIGURE = [];
        ta = TARGET_AXIS;
        TARGET_AXIS = [];

        if ishghandle(f)
            ud = get(f,'UserData');
            if ishghandle(ta)
                for i = 1 : length(ud.anim)
                    [tt,yy] = getpoints(ud.anim(i));
                    np = get(ta,'NextPlot');
                    set(ta,'NextPlot','add');
                    ud.lines(i) = plot(tt,yy,'Parent',ta,...
                                       'Color',get(ud.anim(i),'Color'),...
                                       'Marker',get(ud.anim(i),'Marker'));
                    set(ta,'NextPlot',np);
                    delete(ud.anim(i));
                end
            end
            set(f,'UserData',rmfield(ud,{'anim','callbackTime'}));
            if ~ishold
                set(findobj(f,'Tag','stop'),'Visible','off');
                if ishghandle(ta)
                    set(ta,'XLimMode','auto');
                end
            end
        end

        % full update
        drawnow;

      otherwise

        error(message('MATLAB:odeplot:UnrecognizedFlag', flag));

    end  % switch flag

end  % odeplot

% --------------------------------------------------------------------------
% Sub-function
%

function StopButtonCallback(~,~)
    ud = get(gcbf,'UserData');
    ud.stop = 1;
    set(gcbf,'UserData',ud);
end  % StopButtonCallback
