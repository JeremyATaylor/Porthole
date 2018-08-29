
%  Function: porthole
%  ------------------
%  Launches the Porthole visualisation.
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor 

function porthole(varargin)
%% Global Variables

    global quitFlag pauseFlag KeyDownVal b_KeyDown hp thisData phParams 
    quitFlag = false;       % Indicates user wishes to exit
    b_KeyDown = false;      % Indicates key being held down
    pauseFlag = false;      % Indicates animation is paused
    
    % Check input arguments
    if nargin == 1
        
        % For single argument, expecting filename
        if ischar(varargin{1})  
            load(varargin{1});
            
            % Check file contains dataset and parameter variables
            if ~exist('thisData','var') || ~exist('phParams','var')
                error(['Invalid file: Did not contain valid dataset ', ...
                    'and/or parameter variables']);
            end
        else 
            error('Invalid argument: Specify a filename (string)');
        end
            
    elseif nargin == 2
        
        % For two arguments, expecting the dataset and parameter variables
        if ~isnumeric(varargin{1}) || ~isstruct(varargin{2})
            error(['Incorrect arguments: Specify paired Porthole ', ...
                'dataset (3D double) and parameter (struct) variables']);
        else
            thisData = varargin{1};
            phParams = varargin{2};
        end
    else
        error(['Incorrect number of arguments: Specify either a', ...
            'filename (string) or paired Porthole dataset (3D double)', ...
            ' and parameter (struct) variables']);
    end

    [xDim,yDim,totalImages] = size(thisData);   % Store data dimensions
    thisData(thisData == 0) = NaN;
    
    % Rescale x-dimension for oval display window
    if strcmp(phParams.scalpShape,'oval')
       xMax = xDim*0.8; 
    else
       xMax = xDim; 
    end
    
    % Prompt for animation start time, convert to image index
    firstImage = (phParams.startTime-phParams.preStim)* ...
        phParams.sampleRate/1000+1;
    
    % Custom thresholds not sepecified, autofit colormap
    if phParams.customThreshFlag == 0 
        phParams.dataMax = max(max(max(thisData)));   % Maximum data value
        phParams.dataMin = min(min(min(thisData)));   % Minimum data value 
        fprintf('--------------------------------------\n');
        fprintf(' Colormap autofit was to dataset      \n');
        fprintf('--------------------------------------\n');
    end
    
    fprintf('\nLoading');   % Print loading message
    
%% Initialise New Figure

    screenDims = get(groot,'ScreenSize');       % Dimensions of screen
    screenWidth = screenDims(3);                % Screen width    
    screenHeight = screenDims(4);               % Screen height

    if screenWidth > screenHeight
        figureDims = [0 0 1.2*screenHeight 0.9*screenHeight];
    else
        figureDims = [0 0 screenWidth 0.75*screenWidth];
    end
    
    h_fig = figure('Position', figureDims, 'MenuBar','none', ...
        'DockControls','off', 'ToolBar','none'); 
    movegui(h_fig,'center');                    % Position window 
    axis off manual                  
    axis([-10 xMax+10 -8 yDim+10 -0.1 xDim])    % Set bounds of plot 
    
    set(h_fig,'KeyPressFcn', @keyDownListener,'KeyReleaseFcn', ...
        @keyUpListener, 'CloseRequestFcn', @FigureCloseRequest);
    set(gca,'projection','orthographic','cameraviewanglemode','manual',...
        'clipping','off');
    hold on

    set(h_fig,'color','k');                 % Set background black
    
    % Draw scalp outline
    ph_draw_scalp(xDim,yDim,0.001,phParams.scalpShape);  
    
    if phParams.channelFlag                 
        ph_channel_plot(phParams);          % Turn channel overlay on    
    end
    
    fontSize = 12;                          % Placeholder font size          
    
%% Initialise Camera
    
    campos('manual');                       % Manual camera control
    campos([xMax/2+1,yDim/2+1,1*xDim]);     % Set camera location
    camva(45);                              % Set field of view to 45° 
    camtarget([xMax/2+1,yDim/2+1,0]);       % Set center of view
    
%% Initialise Polygons

    % Pixel Verticies
    if strcmp(phParams.scalpShape,'oval')
        X = [0 0.8; 0 0.8];   
    else
        X = [0 1; 0 1]; 
    end
    Y = [0 0; 1 1];
    Z = [0 0; 0 0];
    
    hp = zeros(xDim,yDim,1);    % Object handle array            
    
    % Create first pixel
    hp(1) = surf(X,Y,Z,'Parent',gca);
    set(hp(1),'FaceAlpha',0.7,'FaceColor',[rand,rand,rand],...
        'EdgeColor','none');
    
    % Duplicate and translate individual pixels
    for i = 2:xDim
        hp(i,1) = copyobj(hp(1,1), gca);
        if strcmp(phParams.scalpShape,'oval')
            set(hp(i,1),'XData',(get(hp(i,1),'XData')+(i-1)*0.8),...
                'FaceColor',[rand,rand,rand],'FaceAlpha',0.7);
        else
            set(hp(i,1),'XData',(get(hp(i,1),'XData')+i-1),...
                'FaceColor',[rand,rand,rand],'FaceAlpha',0.7);            
        end
    end
    for i = 1:xDim
        if mod(i,6) == 0        % Whilst window is loading
            fprintf('.');       % Print elipsis... 
        end
        for j = 2:yDim
            hp(i,j) = copyobj(hp(1,1), gca);
            if strcmp(phParams.scalpShape,'oval')
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

%% Initialise Other Visual Elements
    
    % Animation Parameters
    RT = 0.25;                  % Repeat time between images (seconds)
    fps = 8;                    % Animation speed (frames per second)
    totalFrames = RT*fps;       % Total frames per image
    
    % Data Parameters
    dataDiff = phParams.dataMax-phParams.dataMin;  % Range of data values
    currentImage = firstImage;                     % Image being displayed
    
    % Initialise Legend and Timeline
    ph_get_legend(phParams.dataType,phParams.dataMin,phParams.dataMax, ...
        phParams.pVal,phParams.corrString);
    ph_get_timeline(phParams.dataMin,phParams.dataMax,xMax,thisData);
    
    % Initialise Text Menu
    menu = {'Image','','','Time','','','Peak'};
    text(-10,yDim+1,0.001,menu,'Color','w','FontSize',fontSize, ...
        'FontName','Fira Mono OT','FontWeight','bold', ...
        'VerticalAlignment','top');
    imageValues = {'','','','','','','','',''};
    timeUnits = ' ms';
    imageUnits = cat(2,' / ',num2str(totalImages));
    
    tic;    % Start the clock
        
%% Main Program

    % Inform user of settings
    fprintf('\nReady\n\n');
    fprintf('Controls:\n\n   Esc - Quit Program\n');
    fprintf(' Space - Pause Animation\n');
    
    % Main program loop --------------------------------------------------
    while quitFlag == false
        
        % Pause mode -------------------------------------------------
         while pauseFlag == true    
            if b_KeyDown    % If key held down, perform the following:
                switch KeyDownVal
                    case {'downarrow'} 	% Previous image
                        if currentImage > 1
                            currentImage = currentImage - 1;
                        end
                    case {'uparrow'} 	% Next image
                        if currentImage < totalImages - 1
                            currentImage = currentImage + 1;
                        end
                end
            end

            % Update timeline arrow location
            arrow = ph_get_arrow(currentImage,xMax,yDim,totalImages);    
            
            % Find peak value and location in current image
            [M,Ix] = max(thisData(:,:,currentImage),[],1); 
            [peakVal,yPeak] = max(M); 
            xPeak = Ix(yPeak); 
            
            % Convert numeric values to strings for display
            imageValues{2,1} = [num2str(currentImage) imageUnits];
            imageValues{5,1} = [num2str((currentImage-1) / ...
                phParams.sampleRate*1000+phParams.preStim) timeUnits];
            
            % Find peak value in current image
            if peakVal > 0
                imageValues{8,1} = num2str(peakVal);
                imageValues{9,1} = ['(' num2str(xPeak) ',' ...
                    num2str(yPeak) ')'];
            else
                imageValues{8,1} = 'None';
                imageValues{9,1} = '           ';
            end
            
            % Update Text 
            valueDisplay = text(-10,yDim+1,0.001,imageValues,...
                'Color','w','FontSize',fontSize,'FontName','Fira Mono OT',...
                'FontWeight','normal','VerticalAlignment','top');
            
            % Display Current Image
            for i = 1:xDim
                for j = 1:yDim
                    % Read current value, assign colour and write to pixel
                    thisValue = (thisData(i,j,currentImage) - ...
                        phParams.dataMin)/dataDiff;
                    thisColour = ph_get_colour(thisValue);
                    set(hp(i,j),'FaceColor', thisColour);
                end
            end

            % Prepare for the next loop
            drawnow();              % Render the scene
            pause(0.001);           % Give computer a break
            delete(valueDisplay);   % Delete old values being displayed
            delete(arrow);          % Delete existing arrow location
            
            if b_KeyDown    % If key held down, perform the following:
                switch KeyDownVal
                    case {'space'}                        
                        fprintf('\nAnimation resumed\n');
                        fprintf('Controls:\n\n        Esc - Quit Program\n');
                        fprintf('      Space - Pause Animation\n');
                        pauseFlag = false;
                        pause(0.01);
                end
            end
            
            if quitFlag == true || pauseFlag == false
                break
            end
        end
        % End pause mode ----------------------------------------------    
        
        % Animation mode ----------------------------------------------
        for thisImage = currentImage:totalImages
            if thisImage == totalImages
                thisImage = firstImage;
            end
            currentImage = thisImage;
            
            % Update timeline arrow location
            arrow = ph_get_arrow(thisImage,xMax,yDim,totalImages);
            
            % Update timeline text annotation
            timeString = [num2str((currentImage-1)/phParams.sampleRate* ...
                1000+phParams.preStim) timeUnits];
            timeLabel = text(xMax+9,yDim*thisImage/totalImages,timeString,...
                'Color','w','FontName','Fira Mono OT',...
                'FontSize',fontSize);
            
            % Find the "local" peak value, i.e. peak value in this image
            [M,Ix] = max(thisData(:,:,thisImage),[],1); 
            [peakVal,yPeak] = max(M); 
            xPeak = Ix(yPeak); 
            
            % Update text cell information 
            imageValues{2,1} = [num2str(thisImage) imageUnits];
            imageValues{5,1} = [num2str((currentImage-1) / ...
                phParams.sampleRate*1000+phParams.preStim) timeUnits];
            
            if peakVal > 0
                imageValues{8,1} = num2str(peakVal);
                imageValues{9,1} = ['(' num2str(xPeak) ',' ...
                    num2str(yPeak) ')'];
            else
                imageValues{8,1} = 'None';
                imageValues{9,1} = '           ';
            end
            
            % Display the text
            valueDisplay = text(-10, yDim+1, 0.001, imageValues, ...
                'Color','w','FontSize',fontSize,...
                'FontName','Fira Mono OT','FontWeight','normal',...
                'VerticalAlignment','top');
            
            for thisFrame = 1:totalFrames
                for i = 1:xDim
                    for j = 1:yDim
                        % Read current and next value for this pixel
                        thisValue = (thisData(i,j,thisImage) - ...
                            phParams.dataMin)/dataDiff;
                        nextValue = (thisData(i,j,thisImage+1) - ...
                            phParams.dataMin)/dataDiff;
                        
                        % Look up associated colours
                        thisColour = ph_get_colour(thisValue);
                        nextColour = ph_get_colour(nextValue);

                        % Perform colour interpolation
                        C = nextColour - thisColour;
                        colourVec = thisColour + ...
                            C*sin((thisFrame/totalFrames)*(pi/2));
                        
                        % Set the pixel colour
                        set(hp(i,j),'FaceColor', colourVec);
                    end
                end
         
                % Preparing for next loop:
                drawnow();              % Render the scene
                pause(1/fps-toc);       % Wait for next frame
                tic;                    % Start timer
            end
            
            % Delete arrow and text objects
            delete(valueDisplay);       
            delete(arrow);
            delete(timeLabel);
            
            if b_KeyDown    % If key held down, perform the following:
                switch KeyDownVal
                    case {'space'}          % Space bar held down
                        pauseFlag = true;   % Pause animation
                        fprintf('\nAnimation paused\n');
                        fprintf('Controls:\n\n        Esc - Quit Program\n');
                        fprintf('   Up Arrow - Next Image\n');
                        fprintf(' Down Arrow - Previous Image\n');
                        fprintf('      Space - Resume Animation\n');
                        pause(0.01);
                    end
            end

            if quitFlag == true || pauseFlag == true
                break
            end
        end  
        % End animation mode -------------------------------------------
    end
    % End main program loop ----------------------------------------------
    
    % Ensure program shut down
    FigureCloseRequest
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
    