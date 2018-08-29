    
% Function: raincloud
% -------------------
%  Build three-dimensional volumetric representation of Porthole dataset.  
%  Raincloud uses an isometric perspective with viewpoints indexed as:
% 
%       [1] Right posterior      [3] Left anterior
%       [2] Right anterior       [4] Right posterior
%
%      thisData: Spatiotemporal dataset, specified as 3-D numeric array
%      rcParams: Raincloud parameters, specified as struct
%
%  Required parameters for Raincloud are:
%      viewIndex: Viewpoint index specified via integer (as above)
%       axisSide: Side of volume one which z-axis appears, specified
%                    via strings 'left' or 'right'
%   annotateFlag: Flag indicating whether to annotate specific clusters 
%                    within the dataset, specified as 1 or 0
%          peaks: Vector of peak indices to annotate
%     scalpShape: Shape of scalp as string descriptor - 'oval' (SPM style) 
%                    or 'circle' (EEGlab or FieldTrip style)
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor 

function raincloud(thisData,rcParams) 
    % Global variables
    global hp
    
    t0 = cputime;       % Start runtime counter
    
    % Check arguments contain valid dataset and parameter struct
    if ~isnumeric(thisData) || length(size(thisData)) ~= 3
        error('Invalid dataset: Expected numeric 3-D array');
    end
    if ~isstruct(rcParams)
        error('Invalid parameters: Expected arguments packaged in struct');
    end
    
    [xDim,yDim,zDim] = size(thisData);      % Dimensions of dataset
    
    % Check parameter data structure contains all required fields
    reqFields = {'viewIndex','axisSide','annotateFlag','peaks','scalpShape'};
    if sum(~isfield(rcParams,reqFields)) 
        missingFields = reqFields(find(~isfield(rcParams,reqFields)));
        fprintf('Parameter struct missing the following parameters:\n');
        for i = 1:length(missingFields)
            fprintf('  - %s\n',missingFields{i});
        end
        error('Missing parameters: Argument struct missing required fields');
    end
    
    % Check scalp shape string descriptor is 'circle' or 'oval'
    if ~ischar(rcParams.scalpShape)
        error(['Invalid scalp shape string (' rcParams.scalpShape ...
            '): Specify as string descriptor "circle" or "oval"']);
    elseif strcmp(rcParams.scalpShape,'oval') 
        xMax = 0.8*xDim;
    elseif strcmp(rcParams.scalpShape,'circle')
        xMax = xDim;
    else
        error(['Invalid scalp shape type: Specify as string descriptor' ...
            '"circle" or "oval"']);        
    end
    
    % Check axis side selector argument is 'left' or 'right'
    if ischar(rcParams.axisSide)
        if ~strcmp(rcParams.axisSide,'right') && ...
                ~strcmp(rcParams.axisSide,'left')
            error(['Invalid axis string: z-axis side specified '...
                'as string descriptors "left" or "right"']);
        end
    else
        error(['Invalid argument type: z-axis side specified as ' ...
            'string descriptors "left" or "right"']);
    end 
    
    % Check volume view angle index
    if ~isnumeric(rcParams.viewIndex)
        error(['Invalid argument type: Volume viewing angle index ' ...
            'must be integer in range 1 to 4']);        
    elseif rcParams.viewIndex ~= 1 && rcParams.viewIndex ~=2 && ...
            rcParams.viewIndex ~= 3 && rcParams.viewIndex ~= 4
        error(['Invalid argument value: Volume viewing angle index ' ...
            'must be integer in range 1 to 4']);
    end
    
    screenDims = get(groot,'ScreenSize');       % Dimensions of screen
    screenWidth = screenDims(3);                % Screen width    
    screenHeight = screenDims(4);               % Screen height
    
    % Request a new figure and initialise
    h_fig = figure('Position', [0,0,screenWidth/2,screenHeight*1.5], ...
        'Renderer','painters');         
    movegui(h_fig,'northeast');         % Position window 
    
    axis manual equal                  
    axis([0 xMax 0 yDim 0 zDim])        % Set bounds of plot area
    
    set(h_fig,'name','Raincloud');
    set(gca,'projection','orthographic','cameraviewanglemode','manual',...
        'clipping','off');
    hold on

    set(h_fig,'color',[1,1,1]);     % Set white background
    daspect([2 2 1]);               % Set axes aspect ratio
    
    % Draw 3D scalp map at peak indicies 
    if rcParams.annotateFlag
        for i = 1:length(rcParams.peaks)        
           ph_draw_scalp(xDim,yDim,rcParams.peaks(i),rcParams.scalpShape); 
        end
    end
 
%% Initisalise Camera and Lighting

    % Infinite light source
    light('Style','infinite');
 
    % Configure camera viewing angle
    azimuthAngle = -45+(rcParams.viewIndex*90);
    elevationAngle = 35.264;
    view(azimuthAngle,elevationAngle);
    
    
%% Initialise Polygons

    % Voxel Verticies
    X = [1 1 1 1 1 
         1 1 0 0 1
         1 1 0 0 1
         0 0 0 0 0];
     
    if strcmp(rcParams.scalpShape,'oval')
        X = 0.8*X;
    end
   
    Y = [0 0 0 0 0
         0 0 0 0 0
         1 1 1 1 1
         1 1 1 1 1];
    
    Z = [1 1 1 1 1
         1 0 0 1 1
         1 0 0 1 1
         0 0 0 0 0]; 
    
    % Object handle array
    hp = zeros(xDim,yDim,zDim);                
    
    fprintf('\n Loading   ');
    
    % Create first voxel
    hp(1) = surf(X,Y,Z,'Parent',gca,'EdgeColor','none');
    
    thisData(thisData == 0) = NaN;
    dataMax = max(max(max(thisData)));     
    dataMin = min(min(min(thisData))); 
    dataDiff = dataMax-dataMin;    
    
    % Iterate through all points in dataset
    for i = 1:xDim
        if mod(i,3) == 0        
            fprintf('.');       % Increment loading progress bar
        end
        for j = 1:yDim
            for k = 1:zDim
                % Check datapoint contains non-zero value
                if ~isnan(thisData(i,j,k)) && (thisData(i,j,k) ~= 0)
                    
                    % Extract and normalise value from datapoint
                    thisValue = (thisData(i,j,k)-dataMin)/dataDiff;
                    
                    % Copy initial voxel into object handle array
                    hp(i,j,k) = copyobj(hp(1,1,1), gca);
                    
                    % Update voxel co-ordinates within volume
                    if strcmp(rcParams.scalpShape,'oval')
                        set(hp(i,j,k), ...
                            'XData',(get(hp(i,j,k),'XData')+(i-1)*0.8), ...
                            'YData',(get(hp(i,j,k),'YData')+j-1), ...
                            'ZData',(get(hp(i,j,k),'ZData')+k-1));
                    else
                        set(hp(i,j,k), ...
                            'XData',(get(hp(i,j,k),'XData')+i-1), ...
                            'YData',(get(hp(i,j,k),'YData')+j-1), ...
                            'ZData',(get(hp(i,j,k),'ZData')+k-1));
                    end
                    
                    % Update voxel colour and opacity proportional to value
                    set(hp(i,j,k),'FaceAlpha',thisValue/5,...
                        'FaceColor',[0.5 0.5 0.5]);
                end
            end
        end
    end
    fprintf('\tComplete\n');
    
    % Check initialised voxel at (1,1,1)
    if isnan(thisData(1,1,1)) || (thisData(1,1,1) == 0)
        delete(hp(1,1,1));  
    else
        set(hp(1,1,1),'FaceAlpha',thisValue/5,'FaceColor',[0.75 0.75 0.75]);
    end

    fprintf('\n Ready\n--------------------\n');
    fprintf(' Load Time = %.2fs\n====================\n',cputime-t0);
    
    camzoom(0.7);   % Zoom camera out for full volume to fit in frame
    
%% Draw Axes
    
    if rcParams.viewIndex == 1
        plot([0 xMax],[0 0],'Color','k');
        plot([xMax xMax],[0 yDim],'Color','k');
        if strcmp(rcParams.axisSide,'left')
            plot3([0 0],[0 0],[0 zDim],'Color','k');
        else
            plot3([xMax xMax],[yDim yDim],[0 zDim],'Color','k');
        end
        
    elseif rcParams.viewIndex == 2
        plot([0 xMax],[yDim yDim],'Color','k');
        plot([xMax xMax],[0 yDim],'Color','k');
        if strcmp(rcParams.axisSide,'left')
            plot3([xMax xMax],[0 0],[0 zDim],'Color','k');
        else
            plot3([0 0],[yDim yDim],[0 zDim],'Color','k');
        end
        
    elseif rcParams.viewIndex == 3
        plot([0 xMax],[yDim yDim],'Color','k');
        plot([0 0],[0 yDim],'Color','k');
        if strcmp(rcParams.axisSide,'right')
            plot3([0 0],[0 0],[0 zDim],'Color','k');
        else
            plot3([xMax xMax],[yDim yDim],[0 zDim],'Color','k');
        end
        
    elseif rcParams.viewIndex == 4
        plot([0 xMax],[0 0],'Color','k');
        plot([0 0],[0 yDim],'Color','k');
        if strcmp(rcParams.axisSide,'right')
            plot3([xMax xMax],[0 0],[0 zDim],'Color','k');
        else
            plot3([0 0],[yDim yDim],[0 zDim],'Color','k');
        end
    end
    
    axis off
    
    % Save figure as image
    outputFilename = cat(2,'raincloud_view', ...
        num2str(rcParams.viewIndex),'.png');
    saveas(h_fig,outputFilename);
    
end


    