
% Function: ph_get_colour_64
% --------------------------
%  Assigns colour representation to pixels in the display window for 
%  rendering, based on normalised value (between 0 and 1). High-resolution
%  map contains 64 colours, for use with ph_export_images.
%
%       reading: Normalised numeric value
%    tempString: Temperature of colour map as string - 'warm' or 'cool'
%        colour: RGB triplet 
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor

function [colour] = ph_get_colour_64(reading,tempString)

    % Import high-resolution colour lookup table   
    load(['ph_colours_64_' tempString '.mat']);
    
    if exist('colourMap','var')
        colourCount = length(colourMap);    % Number of colours in map
        increment = 1/(length(colourMap));  % Normalisation factor
    else
        error('File does not contain valid colormap');
    end
    
    colour = [1 1 1];                   % Initialise colour to white
    
    % Increment through range of colours
    for i = 1:colourCount 
        if reading > i*increment        % Find reading on normalised scale
            colour = colourMap(i,:);    % Assign colour
        end
    end
    
end

