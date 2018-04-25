function ret_type = hidden(varargin)
%HIDDEN Mesh hidden line removal mode.
%   HIDDEN ON sets hidden line removal on for meshes in the current axes.
%   HIDDEN OFF sets hidden line removal off so you can see through
%   meshes in the current axes.
%   HIDDEN by itself toggles the state of hidden line removal.
%   HIDDEN(AX, ...) modifies meshes in the axes specified by AX instead of
%   the current axes.
%
%   See also MESH.

%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(0,2);

if nargin == 0
    % hidden(), use GCA and toggle the hidden state.
    ax = gca;
    tog = 'tog';
elseif nargin == 1
    if isscalar(varargin{1}) && isgraphics(varargin{1},'axes')
        % hidden(ax), toggle the hidden state.
        ax = varargin{1};
        tog = 'tog';
    else
        % hidden(state), use GCA
        ax = gca;
        tog = lower(varargin{1});
    end
elseif isscalar(varargin{1}) && isgraphics(varargin{1},'axes')
    % hidden(ax, state)
    ax = varargin{1};
    tog = lower(varargin{2});
else
    error(message('MATLAB:TooManyInputs'));
end

hf = ancestor(ax,'figure');

if ischar(get(ax,'color'))
  bkgd = get(hf,'Color');
else
  bkgd = get(ax,'color');
end
% get mesh handle
hk = get(ax,'Children');
for i = 1:length(hk)
    % see if the object could be a mesh - must be a surface first.
    if strcmp('surface',get(hk(i),'type')) || strcmp(get(hk(i),'type'),'patch')
        fc = get(hk(i),'facecolor');
        % see if the object could be a mesh.
        if strcmp(fc,'none') || isequal(fc,bkgd)
            if strcmp(tog,'on')
                set(hk(i),'facecolor',bkgd);
            elseif strcmp(tog,'off')
                set(hk(i),'facecolor','none');
            else
                if strcmp(fc,'none')
                    set(hk(i),'facecolor',bkgd);
                    tog = 'on';
                else
                    set(hk(i),'facecolor','none');
                    tog = 'off';
                end
            end
        end
    end
end

if nargout > 0
   ret_type = tog;
end


