function [rgb] = xyz2srgb(xyz)
    M = [ 3.2406 -1.5372 -0.4986; -0.9689 1.8758 0.0415; 0.0557 -0.2040 1.0570 ];
    [~, cols ] = size(xyz);
    rgb = M*xyz;
    for c = 1:cols
        for ch = 1:3
            if rgb(ch,c) <= 0.0031308
                rgb(ch,c) = 12.92*rgb(ch,c);
            else
                rgb(ch,c) = 1.055*(rgb(ch,c)^(1.0/2.4)) - 0.055;
            end
            % clip RGB
            if rgb(ch,c) < 0
                rgb(ch,c) = 0;
            elseif rgb(ch,c) > 1
                rgb(ch,c) = 1;
            end
        end
    end
end
