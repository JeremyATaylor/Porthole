    
% Function: exportImages
% ----------------------
%  Exports static scalp map images with high resolution colour mapping 
%  from specified time points within a given Porthole dataset. 
%
%      thisData: Spatiotemporal dataset, specified as 3-D numeric array
%      rcParams: Raincloud parameters, specified as struct
%
%  Copyright (C) 2016 
%  Written by Jeremy Taylor 

function ph_export_maps(thisData,rcParams)
%% Global Variables
    global quitFlag pauseFlag KeyDownVal b_KeyDown hp 
    
    [xDim,yDim,totalImages] = size(thisData);   % Store data dimensions
    
    % Check whether specified indicies are within the dataset range
    if any(rcParams.peaks > totalImages)
        error('Invalid indices: Outside bounds of dataset time axis');
    end
    
    % Specify maxima and minima for mapping to colorbar
    if ~rcParams.customThreshFlag
        thisData(thisData == 0) = NaN;
        rcParams.dataMin = min(min(min(thisData))); 
        rcParams.dataMax = max(max(max(thisData)));
    end
    dataDiff = rcParams.dataMax-rcParams.dataMin;       
    
    if strcmp(rcParams.scalpShape,'oval')
       xMax = xDim*0.8; 
    else
       xMax = xDim; 
    end
    
    quitFlag = false;       % Flag to indicate if we wish to exit
    b_KeyDown = false;      % Flag to indicate if key being held down
    pauseFlag = true;       % Flag to indicate animation is paused
    
%% Initialise New Figure

    screenDims = get(groot,'ScreenSize');       % Dimensions of screen  
    screenHeight = screenDims(4);               % Screen height
    
    % Create new figure 
    h_fig = figure('Position', [0 0 0.8*screenHeight 0.8*screenHeight]);  
    movegui(h_fig,'center');                    % Position window 
    axis off manual                             
    axis([-10 xMax+10 -8 yDim+10 -0.1 xDim])    % Set bounds of plot 
    
    set(h_fig,'KeyPressFcn', @keyDownListener,'KeyReleaseFcn', ...
        @keyUpListener, 'CloseRequestFcn', @FigureCloseRequest);
    set(gca,'projection','orthographic','cameraviewanglemode','manual',...
        'clipping','off');
    hold on

    set(h_fig,'color',[1 1 1]);                     % Set background white
    ph_draw_scalp(xDim,yDim,0.001,rcParams.scalpShape); % Draw scalp outline     
    
%% Initialise Camera
    
    campos('manual');                       % Manual camera control
    campos([xMax/2+1,yDim/2+1,1*xDim]);     % Set camera location
    camva(45);                              % Set field of view to 45° 
    camtarget([xMax/2+1,yDim/2+1,0]);       % Set center of view
    
%% Initialise Polygons

    % Pixel Verticies
    if strcmp(rcParams.scalpShape,'oval')
        X = [0 0.8; 0 0.8];   
    else
        X = [0 1; 0 1]; 
    end    
    Y = [0 0; 1 1];
    Z = [0 0; 0 0];
    
    hp = zeros(xDim,yDim,1);    % Object handle array            
    
    % Create first pixel
    hp(1) = surf(X,Y,Z,'Parent',gca);
    set(hp(1),'FaceAlpha',1,'FaceColor',[rand,rand,rand],...
        'EdgeColor','none');
      
    % Duplicate and translate individual pixels
    for i = 2:xDim
        hp(i,1) = copyobj(hp(1,1), gca);
        if strcmp(rcParams.scalpShape,'oval')
            set(hp(i,1),'XData',(get(hp(i,1),'XData')+(i-1)*0.8),...
                'FaceColor',[rand,rand,rand],'FaceAlpha',0.7);
        else
            set(hp(i,1),'XData',(get(hp(i,1),'XData')+i-1),...
                'FaceColor',[rand,rand,rand],'FaceAlpha',0.7);            
        end
    end
    
    for i = 1:xDim
        for j = 2:yDim
            hp(i,j) = copyobj(hp(1,1), gca);
            if strcmp(rcParams.scalpShape,'oval')
                set(hp(i,j),'XData',(get(hp(i,j),'XData')+(i-1)*0.8),...
                    'YData',(get(hp(i,j),'YData')+j-1),...
                    'FaceColor',[rand,rand,rand],'FaceAlpha',0.7);
            else
                set(hp(i,j),'XData',(get(hp(i,j),'XData')+i-1),...
                    'YData',(get(hp(i,j),'YData')+j-1),...
                    'FaceColor',[rand,rand,rand],'FaceAlpha',0.7);                
            end
        end
    end

%% Main Program

    % Display Current Image
    for k = 1:length(rcParams.peaks)
        for i = 1:xDim
            for j = 1:yDim
                % Read the current and future values for this pixel                
                thisValue = (thisData(i,j,rcParams.peaks(k))- ...
                    rcParams.dataMin)/dataDiff;

                % Look up their associated colours
                thisColour = ph_get_colour_64(thisValue,'warm');

                % Set the pixel colour
                set(hp(i,j),'FaceColor', thisColour);
            end
        end
        drawnow();
        
        % Save individual images
        outputFilename = cat(2,'peak',num2str(k),'_t', ...
            num2str(rcParams.peaks(k)),'.png');
        saveas(h_fig,outputFilename);
    end

    if exist('h_fig','var')
        delete(h_fig)
    else
        delete(gcf)
    end
    
end

%% 'Key Down' Event Function
function keyDownListener(~,event)    
    % Flag and value indicating if (and which) key is being held down
    global b_KeyDown KeyDownVal     
    switch event.Key                % If holdable key is pressed
        case {'space','uparrow','downarrow'}
            b_KeyDown = true;       % Key down flag flipped
            KeyDownVal = event.Key; % Record which key being held
    end
end

%% 'Key Up' Event Function 
function keyUpListener(~,event)    
    global quitFlag b_KeyDown pauseFlag
    if b_KeyDown                % If held key released, but flag is true: 
        b_KeyDown = false;      % Set to false
    else
        switch event.Key
            case 'escape'
                quitFlag = true;    % Toggle quit flag
            case 'space'
                if pauseFlag == false;
                    pauseFlag = true;
                else
                    pauseFlag = false;
                end
            otherwise
                beep                % Bad selection tone
        end
    end
end

%% Figure Close Event Function
function FigureCloseRequest(~,~)  
    global quitFlag
    quitFlag = true;                % Toggle quit flag
    if exist('h_fig','var')
        delete(h_fig)
    else
        delete(gcf)
    end
end    
    