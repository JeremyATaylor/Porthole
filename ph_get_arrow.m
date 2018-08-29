
% Function: ph_get_arrow
% ----------------------
%  Generates a new arrow object along the timeline for the image 
%   currently being rendered.
%
%     imageNumber: Index for currently rendered image
%           xSize: Width of the dataset images
%           ySize: Height of the dataset images
%           zSize: Total number of images in the dataset
%           arrow: Handle for the arrow object
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor 

function arrow = ph_get_arrow(imageNumber,xSize,ySize,zSize)

    % Calculate arrowhead verticies
    x = [xSize+8.1 xSize+8.5 xSize+8.5];
    y = [ySize*imageNumber/zSize ySize*imageNumber/zSize+0.2 ...
        ySize*imageNumber/zSize-0.2];
    
    % Generate arrow object from verticies
    arrow = patch(x,y,'w','FaceAlpha',0.7,'EdgeColor','none');
    
end