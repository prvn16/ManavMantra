function autoSwitch = autoSwitchToPaintersForPrint(pj)
% This undocumented helper function is for internal use.

% AUTOSWITCHTOPAINTERSFORPRINT 
% Checks to see if we should use painters for output generation when
% producing vector output, based on heuristic implemented here
% Copyright 2014-2017 The MathWorks, Inc.

    autoSwitch = false;
    fig = pj.Handles{1};
    isVectorFormat = length(pj.Driver) > 1 && ... 
                     (strncmp(pj.Driver(1:2), 'ps', 2) || ... 
                     any(strncmp(pj.Driver(1:3), {'eps', 'met', 'pdf', 'svg'}, 3)));
    
    %  We won't "auto switch" if 
    %    ** not doing a vector format or
    %    ** renderer was specified in call to print, or 
    %    ** user set figure's renderer (renderermode is 'manual'),  or 
    %    ** renderer is already set to 'painters' 
    if ~isVectorFormat || pj.rendererOption || ...
            strcmp(fig.RendererMode, 'manual') || strcmp(fig.Renderer, 'painters')
        return;
    end
    
    % use the heuristic to decide whether or not switch
    % auto switch only if the scene isn't too complex 
    % (previously also would auto switch if none of the axes were using 
    %  depth sorting... but that proved too optimistic as large surfaces 
    %  or large number of markers, for example, could result in time-consuming 
    %  output generation and large output files). 
    checker = matlab.graphics.internal.PrintPaintersChecker.getInstance();
    autoSwitch = ~checker.exceedsVertexLimits(fig); 
    
    % if we still think we can/should auto switch, check to see if the 
    % figure uses transparency and, if so, whether the output format
    % supports it (right now, PS/EPS don't support transparency 
    if autoSwitch && ~isempty(strfind(pj.Driver, 'ps'))
        % if transparency, don't autoswitch
        autoSwitch = ~hasTransparency(fig, checker.DebugMode); 
    end
    
    % if we still think we can/should auto switch, check to see if there is
    % any lighting involved, and don't autoSwitch if there is
    if autoSwitch
        autoSwitch = ~checker.exceedsLightingLimits(fig);
    end
    
    % if we still think we can/should auto switch, check to see if there is
    % any surface with texturemap facecolor exist, and don't autoSwitch if
    % it is going to be large output size (except PDF format) [g1651960]
    if autoSwitch && ~contains(pj.Driver, 'pdf')
        autoSwitch = ~checker.exceedsTextureLimits(fig);
    end
end

% helper function to look through objects and flag whether there are any
% visible objects using transparency
function hasTrans = hasTransparency(fig, debugMode)
   hasTrans = false;
   k = findobjinternal(fig, 'Visible', 'on');
   % these properties control transparency. if 1 it's fully opaque, 
   % otherwise there is some level of transparency, unless the associated color is 'none' 
   alphaProps = {'FaceAlpha', 'EdgeAlpha', 'MarkerFaceAlpha', 'MarkerEdgeAlpha'}; 
   colorProps = {'FaceColor', 'EdgeColor', 'MarkerFaceColor', 'MarkerEdgeColor'}; 
   for idx = 1:length(alphaProps) 
       kAlpha = findobjinternal(k, '-property', alphaProps{idx}, '-not', alphaProps{idx}, 1, '-depth', 0);
       % check for color not being none 
       if ~isempty(kAlpha) 
          kVals = get(kAlpha, colorProps{idx}); 
          if ~iscell(kVals)
             kVals = {kVals};
          end
          % if the associated <Color> property for these objects 
          % is not set to 'none' then we have transparency in use 
          % (if they're all set to 'none' then no color is displayed and it
          % doesn't matter that the associated <Alpha> property was not 1).
          if ~all(cellfun(@(x,y )strcmp(x,'none'), kVals))
             hasTrans = true; 
             break;  % no need to look further - we've found at least one
          end
       end
   end
   if debugMode 
       if hasTrans 
           fprintf('autoSwitchToPainters: transparency in use\n'); 
       else
           fprintf('autoSwitchToPainters: transparency not in use\n'); 
       end
   end
end