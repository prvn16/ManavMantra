function grid = gameoflife_stencil(initialGrid) %#codegen

numGenerations = 100;
grid = initialGrid;

% Loop through each generation updating the grid
for generation = 1:numGenerations
	 grid = gpucoder.stencilKernel(@updateElem, grid, [3,3], 'same');
end
end

function X = updateElem(window)
    [winH, winW]  = size(window);
    neighbors = 0;
    for ww = 1:winW
        for wh = 1:winH
            neighbors = window(1,1) + window(1,2) + window(1,3) ...
                + window(2,1) + window(2,3) ...
                + window(3,1) + window(3,2) + window(3,3);
        end
    end
    X = (window(2,2) & (neighbors == 2)) | (neighbors == 3);
end	


