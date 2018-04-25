function status = odephas2(~,y,flag,varargin)
%ODEPHAS2  2-D phase plane ODE output function.
%   When the function odephas2 is passed to an ODE solver as the 'OutputFcn'
%   property, i.e. options = odeset('OutputFcn',@odephas2), the solver
%   calls ODEPHAS2(T,Y,'') after every timestep.  The ODEPHAS2 function plots
%   the first two components of the solution it is passed as it is computed,
%   adapting the axis limits of the plot dynamically.  To plot two
%   particular components, specify their indices in the 'OutputSel' property
%   passed to the ODE solver.
%
%   At the start of integration, a solver calls ODEPHAS2(TSPAN,Y0,'init') to
%   initialize the output function.  After each integration step to new time
%   point T with solution vector Y the solver calls STATUS = ODEPHAS2(T,Y,'').
%   If the solver's 'Refine' property is greater than one (see ODESET), then
%   T is a column vector containing all new output times and Y is an array
%   comprised of corresponding column vectors.  The STATUS return value is 1
%   if the STOP button has been pressed and 0 otherwise.  When the
%   integration is complete, the solver calls ODEPHAS2([],[],'done').
%
%   See also ODEPLOT, ODEPHAS3, ODEPRINT, ODE45, ODE15S, ODESET.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2016 The MathWorks, Inc.

    persistent TARGET_FIGURE TARGET_AXIS

    status = 0;          % Assume stop button wasn't pushed.
    callbackDelay = 1;   % Check Stop button every 1 sec.

    % support odephas2(t,y) [v5 syntax]
    if nargin < 3 || isempty(flag)
        flag = '';
    elseif isstring(flag) && isscalar(flag)
        flag = char(flag);
    end
    
    switch(flag)

      case ''    % odephas2(t,y,'')

        if (isempty(TARGET_FIGURE) || isempty(TARGET_AXIS))

            error(message('MATLAB:odephas2:NotCalledWithInit'));

        elseif (ishghandle(TARGET_FIGURE) && ishghandle(TARGET_AXIS))  % figure still open

            try

                ud = get(TARGET_FIGURE,'UserData');

                if ud.stop == 1  % Has stop button been pushed?
                    status = 1;
                else
                    addpoints(ud.anim,y(1,:),y(2,:));

                    if etime(clock,ud.callbackTime) < callbackDelay
                        % fast update
                        drawnow update;
                    else
                        % check Stop button callback
                        ud.callbackTime = clock;
                        set(TARGET_FIGURE,'UserData',ud);
                        drawnow;
                    end
                end
            catch ME
                error(message('MATLAB:odephas2:ErrorUpdatingWindow', ME.message));
            end

        end

      case 'init'   % odephas2(tspan,y0,'init')

        % Get figure data
        f = figure(gcf);
        TARGET_FIGURE = f;
        TARGET_AXIS = gca;
        ud = get(f,'UserData');

        % Initialize lines
        if ~ishold || ~isfield(ud,'line')
            ud.line = plot(y(1),y(2),'-o','Parent',TARGET_AXIS);
        end
        ud.anim = animatedline(y(1),y(2),'Parent',TARGET_AXIS,...
                               'Color',get(ud.line,'Color'),...
                               'Marker',get(ud.line,'Marker'));

        % The STOP button
        h = findobj(f,'Tag','stop');
        if isempty(h)
            pos = get(0,'DefaultUicontrolPosition');
            pos(1) = pos(1) - 15;
            pos(2) = pos(2) - 15;
            uicontrol( ...
                'Style','pushbutton', ...
                'String',getString(message('MATLAB:odephas2:ButtonStop')), ...
                'Position',pos, ...
                'Callback',@StopButtonCallback, ...
                'Tag','stop');
            ud.stop = 0;
        else
            % make sure it's visible
            set(h,'Visible','on');
            % don't change current ud.stop status
            if ~ishold || ~isfield(ud,'stop')
                ud.stop = 0;
            end
        end

        % Set figure data
        ud.callbackTime = clock;
        set(f,'UserData',ud);

        % fast update
        drawnow update;

      case 'done'    % odephas2([],[],'done')

        f = TARGET_FIGURE;
        TARGET_FIGURE = [];
        ta = TARGET_AXIS;
        TARGET_AXIS = [];

        % Clean figure data
        if ishghandle(f)
            ud = get(f,'UserData');
            if ishghandle(ta)
                [y1,y2] = getpoints(ud.anim);
                ud.line = plot(y1,y2,'Parent',ta,...
                               'Color',get(ud.anim,'Color'),...
                               'Marker',get(ud.anim,'Marker'));
                delete(ud.anim);
            end
            set(f,'UserData',rmfield(ud,{'anim','callbackTime'}));
            if ~ishold
                set(findobj(f,'Tag','stop'),'Visible','off');
            end
        end

        % full update
        drawnow;

      otherwise

        error(message('MATLAB:odephas2:UnrecognizedFlag', flag));

    end  % switch flag

end  % odephas2

% --------------------------------------------------------------------------
% Sub-function
%

function StopButtonCallback(~,~)
    ud = get(gcbf,'UserData');
    ud.stop = 1;
    set(gcbf,'UserData',ud);
end  % StopButtonCallback

% --------------------------------------------------------------------------
