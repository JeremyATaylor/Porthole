
% Function: channelPlot
% ---------------------
%  Loads channel locations and names from file, converts to shared 
%  co-ordinate system and plots channel locations over the scalp map. 
%
%      thisData: Spatiotemporal dataset, specified as 3-D numeric array
%      phParams: Porthole parameters, specified as struct
%
%  Required parameters to plot the channel layout are:
%  channelLocationsFlag: Flag indicating whether to annotate channel 
%                          locations as points, specified as 1 or 0
%     channelLabelsFlag: Flag indicating whether to annotate channel 
%                          labels as text, specified as 1 or 0
%         channelLayout: Co-ordinate system for channel layout, specified
%                          as string descriptor '10-10' or '10-20'
%            scalpShape: Shape of scalp, specified as string descriptor
%                          'oval' or 'circle'
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor 

function ph_channel_plot(phParams)

    % Load channel co-ordinates and names from file
    load('ph_channels.mat');
    channelCoords = channelCoords + 0.5;
    
    if strcmp(phParams.scalpShape,'oval');
        channelCoords(:,1) = channelCoords(:,1)*0.8;
    end
    
    % 10-20 co-ordinate system is subset of 10-10 system
    if strcmp(phParams.channelLayout,'10-20')
        channelCoords = channelCoords(Ix_1020,:);
        channelLabels = channelLabels(Ix_1020,:);
    end
    
    hold on
    
    % Plot individual points at respective channel co-ordinates
    if phParams.channelLocationsFlag 
        for i = 1:length(channelCoords)
            scatter3(channelCoords(i,1)-1,channelCoords(i,2)-1,0.002,20,'g'); 
        end
    end
    
    % Annotate channels above each point 
    if phParams.channelLabelsFlag && phParams.channelLocationsFlag
        for i = 1:length(channelCoords)          
            text(channelCoords(i,1)-1,channelCoords(i,2)-1+0.5, ...
                channelLabels{i},'Color','g','HorizontalAlign','center', ...
                'FontName','Fira Mono OT','FontSize',9);
        end
        
    % Annotate channels in place of each point
    elseif phParams.channelLabelsFlag && ~phParams.channelLocationsFlag
        for i = 1:length(channelCoords)
            text(channelCoords(i,1)-1,channelCoords(i,2)-1, ...
                channelLabels{i},'Color','g','HorizontalAlign','center', ...
                'FontName','Fira Mono OT','FontSize',9);
        end        
    end
end

