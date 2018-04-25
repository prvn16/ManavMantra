function vars = load_vvariables(filename)
vars = whos('-file', filename);
vars = {vars.name};
end
