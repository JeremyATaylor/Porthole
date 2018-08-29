
% Function: ph_get_colour
% -----------------------
%  Assigns colour representation to pixels in the display window for 
%  rendering, based on normalised value (between 0 and 1).
%
%       reading: Normalised numeric value
%        colour: RGB triplet 
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor


function [colour] = ph_get_colour(reading)

    % Colour lookup table
    colourLookup = [0.510, 0.122, 0.133;
                    0.776, 0.122, 0.149;
                    0.929, 0.129, 0.141;
                    0.933, 0.220, 0.137;
                    0.937, 0.259, 0.133;
                    0.961, 0.467, 0.137;
                    0.992, 0.686, 0.137;
                    0.973, 0.898, 0.247;
                    0.984, 0.949, 0.537];

    % Set colour according to threshold value
    if reading > 0.8
        colour = colourLookup(9,:);
    elseif reading > 0.7
        colour = colourLookup(8,:);
    elseif reading > 0.6
        colour = colourLookup(7,:);
    elseif reading > 0.5
        colour = colourLookup(6,:);
    elseif reading > 0.4
        colour = colourLookup(5,:);
    elseif reading > 0.3
        colour = colourLookup(4,:);
    elseif reading > 0.2
        colour = colourLookup(3,:);
    elseif reading > 0.1
        colour = colourLookup(2,:);
    elseif reading > 0
        colour = colourLookup(1,:);
    else
        colour = [0 0 0];
    end

end












