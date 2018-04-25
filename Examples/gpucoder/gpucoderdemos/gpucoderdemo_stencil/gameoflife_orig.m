%% MATLAB vectorized implementation
function grid = gameoflife_orig(initialGrid)

numGenerations = 100;
grid = initialGrid;
[gridSize,~] = size(initialGrid);

% Loop through each generation updating the grid and displaying it
for generation = 1:numGenerations
    grid = updateGrid(grid, gridSize);
    
    imagesc(grid);
    colormap([1 1 1;0 0.5 0]);
    title(['Grid at Iteration ',num2str(generation)]);
    drawnow;
end

    function X = updateGrid(X, N)
        % Index vectors increase or decrease the centered index by one
        % thereby accessing neighbors to the left,right,up,down
        p = [1 1:N-1];
        q = [2:N N];
        % Count how many of the eight neighbors are alive.
        neighbors = X(:,p) + X(:,q) + X(p,:) + X(q,:) + ...
            X(p,p) + X(q,q) + X(p,q) + X(q,p);
        % A live cell with two live neighbors, or any cell with
        % three live neighbors, is alive at the next step.
        X = (X & (neighbors == 2)) | (neighbors == 3);
    end

end