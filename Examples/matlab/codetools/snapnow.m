function varargout = snapnow(varargin)
%SNAPNOW Force a snapshot of output.
%   SNAPNOW forces checking for figure and system changes when inside
%   publishing, and acts as a DRAWNOW otherwise.

%   DATA = SNAPNOW('get') returns the persistent data which is generated
%   and used during publishing.
%
%   SNAPNOW('set', DATA) sets this persistent data.  If empty, it is
%   assumed that publishing is exiting.  Otherwise it is assumed that
%   publishing is commencing, and other initializations to this data occur.
%
%   F = SNAPNOW('beginCell', iCell, ...) indicates that the cell iCell is
%   being entered during publishing.  SNAPNOW returns false, for its use in
%   conditional breakpoints.
%
%   F = SNAPNOW('endCell', iCell, ...) indicates that the cell iCell is
%   being left.  Again, SNAPNOW returns false, for its use in conditional
%   breakpoints.
%
%   These two forms may be combined:
%
%      snapnow('endCell', 2, 'beginCell', 3)
%
%   such as occurs on a cell-to-cell boundary.

% Matthew J. Simoneau, October 2006
% Copyright 2006-2011 The MathWorks, Inc.

persistent data
persistent cellStack

% Return false to continue execution.
if (nargout == 1)
    varargout = {false};
end

% Because publishing behaves so badly when there is an error in a
% conditional breakpoint (which there shouldn't be), put this all in a
% try-catch.
try
    
    % Parse inputs.
    if nargin > 0
        switch varargin{1}
            case 'get'
                varargout = {data};
                
            case 'set'
                cellStack = [];
                data = varargin{2};
                if isempty(data)
                    % Leaving publishing.
                    munlock;
                    data = [];
                else
                    % Initializing publishing.
                    mlock;
                    data.counter = makeCounter(0);
                    data.pictureList = {};
                    data.placeList = [];
                    data.options.filenameGenerator = makeFilenameGenerator(data.baseImageName);

                    % Systems.
                    data.plugins(1).check = @hasSimulink;
                    data.plugins(1).classname = 'internal.matlab.publish.PublishSimulinkSystems';
                    data.plugins(1).instance = [];

                    % Figures.
                    data.plugins(2).check = @true;
                    data.plugins(2).classname = 'internal.matlab.publish.PublishFigures';
                    data.plugins(2).instance = [];

                    % This gives us a placement for files with parse errors.
                    data.lastGo = 1;
                end
            
            case 'append'
                % Undocumented prototype code for creating animated GIFs.
                %
                % SNAPNOW is being called to createa an animation.
                %
                % For example: snapnow('append')

                if isempty(data)
                    % Running normally, outside the context of publishing.
                    if (nargin > 1)
                        pause(varargin{2})
                    end
                    drawnow
                else
                    % Inside the context of publishing.
                    if (nargin > 1)
                        data.append = varargin{2};
                    else
                        data.append = Inf;
                    end
                    iCell = cellStack(end);
                    data = leavingCell(iCell, data, true);
                    data = enteringCell(iCell, data, false);
                    data = rmfield(data,'append');
                end                
                
            otherwise
                % SNAPNOW is being called in a conditional breakpoint at a
                % cell boundary.  Pairs of arguments are processed in turn.
                %
                % For example: snapnow('endCell', 2, 'beginCell', 3);
                
                % Assume odd inputs are either beginCell or endCell.
                exiting = strcmp(varargin(1:2:end), 'endCell');
                iCell = [varargin{2:2:end}];
                
                % We've exited the file, perhaps prematurely.
                iCell(iCell < 0) = data.lastGo;
                
                % Short-circuit when this is a redundancy.
                % That is, when entering a cell that is alreay on the stack.
                % or leaving a cell that is not on the stack.
                toRemove = xor(ismember(iCell, cellStack), exiting);
                exiting(toRemove) = [];
                iCell(toRemove) = [];
                
                % Do a capture/compare on only the first "beginCell" or
                % "endCell".  Subsequent cases would recapture the same info.
                doCapture = false(size(iCell));
                doCapture(1) = true;
                
                % Take the appropriate action for each pair.
                for k = 1:numel(iCell)
                    if exiting(k)
                        cellStack(cellStack == iCell(k)) = [];
                        data = leavingCell(iCell(k), data, doCapture(k));
                    else
                        cellStack(end + 1) = iCell(k); %#ok<AGROW>
                        data = enteringCell(iCell(k), data, doCapture(k));
                    end
                end
                
        end
    else
        % Called directly with no arguments from user code.
        if isempty(data)
            % Running normally, outside the context of publishing.
            drawnow
        else
            % Inside the context of publishing.
            iCell = cellStack(end);
            data = leavingCell(iCell, data, true);
            data = enteringCell(iCell, data, false);
        end
    end
    
catch e
    % Something went wrong in the publishing infrastructure.
    disp(getReport(e))

end

end

%===============================================================================
function data = enteringCell(iCell, data, doCapture)

data.lastGo = iCell;

if doCapture
    for iPlugins = 1:numel(data.plugins)
        if data.plugins(iPlugins).check() && ...
                (exist(data.plugins(iPlugins).classname,'class') == 8)
            if isempty(data.plugins(iPlugins).instance)
                data.plugins(iPlugins).instance = feval(data.plugins(iPlugins).classname,data.options);
            end
            data.plugins(iPlugins).instance.enteringCell(iCell)
        end
    end
end

% Leave a divider in the output stream.
fprintf('%s%iA%iX',data.marker,iCell,data.counter())

end

%===============================================================================
function data = leavingCell(iCell, data, doCapture)

% Leave a divider in the output stream.
fprintf('%s%iZ%iX',data.marker,iCell,data.counter())

if doCapture
    for iPlugins = 1:numel(data.plugins)
        if data.plugins(iPlugins).check() && ...
                (exist(data.plugins(iPlugins).classname,'class') == 8)
            if isempty(data.plugins(iPlugins).instance)
                data.plugins(iPlugins).instance = feval(data.plugins(iPlugins).classname,data.options);
            end
            newFiles = data.plugins(iPlugins).instance.leavingCell(iCell);
            for iNewFiles = 1:numel(newFiles)
                if isfield(data,'append')
                    % Undocumented prototype code for creating animated GIFs.
                    X = imread(newFiles{iNewFiles});
                    delete(newFiles{iNewFiles})
                    [im,map] = rgb2ind(X,512,'nodither');
                    gifExists = numel(data.pictureList) > 0 && ...
                        ~isempty(regexp(data.pictureList{end},'\.gif$','once'));
                    if gifExists
                        if isinf(data.append)
                            imwrite(im,map,data.pictureList{end},'gif', ...
                                'WriteMode','append');
                        else
                            imwrite(im,map,data.pictureList{end},'gif', ...
                                'WriteMode','append','DelayTime',data.append);
                        end
                    else
                        newFilename = regexprep(newFiles{iNewFiles},'\.\w+$','.gif');
                        imwrite(im,map,newFilename,'gif','LoopCount',Inf);
                        data.pictureList{end+1} = newFilename;
                        data.placeList(end+1) = iCell;
                        data.placeList(end+1) = data.counter();
                    end
                else
                    data.pictureList{end+1} = newFiles{iNewFiles};
                    data.placeList(end+1) = iCell;
                    data.placeList(end+1) = data.counter();
                end
            end
        end
    end    
end

end

%==========================================================================
function countfcn = makeCounter(initvalue)
% This function returns a handle to a customized nested function 'getCounter'.
% initvalue specifies the initial value of the counter whose handle is
% returned.

currentCount = initvalue; % Initial value
countfcn = @getCounter; % Return handle to getCounter

    function count = getCounter
        % This function increments the variable 'currentCount', when it
        % gets called (using its function handle).
        currentCount = currentCount + 1;
        count = currentCount;
    end

end

%==========================================================================
function countfcn = makeFilenameGenerator(baseImageNameIn)
currentCount = 0; % Initial value
baseImageName = baseImageNameIn;
countfcn = @getFilenameGenerator;
    function imgNoExt = getFilenameGenerator
        currentCount = currentCount + 1;        
        imgNoExt = sprintf('%s_%02.f',baseImageName,currentCount);
    end
end

%==========================================================================
function tf = hasSimulink

try
    isSimulinkLoaded = is_simulink_loaded;
catch E
    if strcmp(E.identifier,'MATLAB:UndefinedFunction')
        isSimulinkLoaded = false;
    else
        rethrow(E)
    end
end

if isSimulinkLoaded
    [tf,~] = license('checkout','simulink');
else
    tf = false;
end
end
