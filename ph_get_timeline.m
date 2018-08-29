
% Function: ph_get_timeline
% -------------------------
%  Generates timeline for dataset navigation alongside the display window.
%
%     tThresh: Threshold t-value in the dataset, i.e. minimum value
%        data: Imported dataset
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor


function ph_get_timeline(tThresh,tMax,xMax,data)
    
    tDiff = tMax-tThresh;
    [xSize,ySize,zSize] = size(data);
    
    x = linspace(xMax+8.05,xMax+8.05,2);
    y = linspace(0,ySize,2);
    z = linspace(-0.001,-0.001,2);
    plot3(x,y,z,'Color',[0.25 0.25 0.25],'LineWidth',2);

    for z = 1:zSize
        thisPeak = max(max(max(data(:,:,z))));
        thisColour = ph_get_colour((thisPeak-tThresh)/tDiff);
        if ~isequal(thisColour, [0 0 0])
            x = [xMax+8 xMax+8.1 xMax+8.1 xMax+8];
            y = [(z-1)*ySize/zSize (z-1)*ySize/zSize z*ySize/zSize ...
                z*ySize/zSize];
            patch(x,y,thisColour,'FaceAlpha',0.7,'EdgeColor','none');
        end
    end

end
