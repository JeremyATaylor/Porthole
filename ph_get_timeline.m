
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
    
    load('ph_colours_64_warm.mat','colourMap');

    tDiff = tMax-tThresh;
    [~,ySize,zSize] = size(data);
    
    x = [xMax+8 xMax+8];
    y = [0 ySize];
    z = [-0.001 -0.001];
    plot3(x,y,z,'Color',[0.3 0.3 0.3],'LineWidth',2);
                
    for z = 1:zSize
        thisPeak = max(max(max(data(:,:,z))));
        
        thisValue = (thisPeak-tThresh)/tDiff;
    
        if thisValue == 0 || isnan(thisValue)
        	continue
        else 
            thisColour = colourMap(ceil(thisValue*64),:); 
            y = [(z-1)*ySize/zSize z*ySize/zSize];

            plot3(x,y,[0 0],'Color',thisColour,'LineWidth',2);
        end
    end

end
