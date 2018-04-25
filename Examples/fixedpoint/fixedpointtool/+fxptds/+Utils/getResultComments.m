function [ comments ] = getResultComments( result )
    %GETRESULTCOMMENTS returns comments to be displayed in the result details pane

%   Copyright 2016 The MathWorks, Inc.
    
    commentGenerator = SimulinkFixedPoint.CommentGenerator();
    
    % Comments for the result
    comments = commentGenerator.getComments(result);
            
end