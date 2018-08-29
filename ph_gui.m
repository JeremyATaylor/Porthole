
%  Function: ph_gui
%  ----------------
%  Graphical user interface (GUI) for specifying Porthole animations.
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor

function ph_gui

    global thisData phParams dataFilename

    % Intialise new figure
    f = figure('MenuBar','none','NumberTitle','off','ToolBar','none',...
        'Name','Porthole Menu','Position',[100 100 450 360]);
    
    % -- Data Import Elements -------------------------------------------
    
    % Edit field for displaying or entering data filename
    loadEdit = uicontrol(f,'Style','edit','String','Load dataset...', ...
        'Position',[30 315 290 25],'FontSize',11,'FontAngle','italic');
    
    % Load button for importing data and parameters from file
    uicontrol(f,'Style','pushbutton','String','Load', ...
        'Position',[330 310 45 33],'FontSize',11,'Callback',@load_button);
    
    % Save button for writing parameters to file
    uicontrol(f,'Style','pushbutton','String','Save', ...
        'Position',[380 310 45 33],'FontSize',11,'Callback',@save_button);
    
    % Start button for launching Porthole animation
    uicontrol(f,'Style','pushbutton','String','Launch Porthole', ...
        'Position',[20 20 410 40],'FontSize',13,'Callback',@start_button);
    
    
    % -- Timing Specification Panel -------------------------------------
    
    % Parent UI panel for timing specification elements
    timingPanel = uipanel(f,'Title','Timing','FontSize',12,...
        'Units','pixels','Position',[20 80 210 120]);
    
    % Edit field for specifying sampling frequency 
    freqEdit = uicontrol(timingPanel,'Style','edit', ...
        'Position',[130 70 40 20]);
    uicontrol(timingPanel,'Style','text','String','Sampling Frequency',...
        'FontSize',11,'HorizontalAlignment','right',...
        'Position',[10 70 110 20]);
    uicontrol(timingPanel,'Style','text','String','Hz','FontSize',11,...
        'HorizontalAlignment','left','Position',[180 70 20 20]);
    
    % Edit field for specifying pre-stimulus interval
    prestimEdit = uicontrol(timingPanel,'Style','edit', ...
        'Position',[130 40 40 20]);
    uicontrol(timingPanel,'Style','text','String','Pre-Stimulus Time',...
        'FontSize',11,'HorizontalAlignment','right',...
        'Position',[10 40 110 20]);
    uicontrol(timingPanel,'Style','text','String','ms','FontSize',11,...
        'HorizontalAlignment','left','Position',[180 40 20 20]);
    
    % Edit field for specifying animation start time
    startEdit = uicontrol(timingPanel,'Style','edit', ...
        'Position',[130 10 40 20]);
    uicontrol(timingPanel,'Style','text','String','Animation Start Time',...
        'FontSize',11,'HorizontalAlignment','right',...
        'Position',[10 10 110 20]);
    uicontrol(timingPanel,'Style','text','String','ms','FontSize',11,...
        'HorizontalAlignment','left','Position',[180 10 20 20]);
    
    
    % -- Display Customistion Panel -------------------------------------
    
    % Parent UI panel for customising display window
    displayPanel = uipanel(f,'Title','Display','FontSize',12,...
        'Units','pixels','Position',[250 80 180 120]);    
    
    % Popup to select circular or oval scalp shape
    uicontrol(displayPanel,'Style','text','String','  Scalp Shape', ...
        'FontSize',11,'HorizontalAlignment','left', ...
        'Position',[10 80 80 20]);
    shapePopup = uicontrol(displayPanel,'Style','popupmenu',...
        'String',{'Circle','Oval'},'Position',[10 50 80 30]);
    
    % Popup to select channel template
    uicontrol(displayPanel,'Style','text','String','  Layout','FontSize',11,...
        'HorizontalAlignment','left','Position',[90 80 80 20]);
    layoutPopup = uicontrol(displayPanel,'Style','popupmenu','Enable','off', ...
        'String',{'10-10','10-20'},'Position',[90 50 80 30]);
    
    % Checkbox indicating whether to display channel locations 
    locationsCheck = uicontrol(displayPanel,'Style','checkbox', ...
        'String','Channel Locations','FontSize',11, ...
        'Position',[13 30 120 20],'Callback',@locations_checkbox);
    
    % Checkbox indicating whether to display channel labels
    labelsCheck = uicontrol(displayPanel,'Style','checkbox', ...
        'String','Channel Labels','FontSize',11, ...
        'Position',[13 10 120 20],'Callback',@labels_checkbox);
    

    % -- Dataset Content Specification Panel ----------------------------
    
    % Parent UI panel for specifying the dataset
    datasetPanel = uipanel(f,'Title','Dataset','FontSize',12, ...
        'Units','pixels','Position',[20 215 410 80]);    
    
    % Popup for selecting contrast type
    uicontrol(datasetPanel,'Style','text','String','  Contrast', ...
        'FontSize',11,'HorizontalAlignment','left', ...
        'Position',[10 38 60 20]);
    typePopup = uicontrol(datasetPanel,'Style','popupmenu', ...
        'String',{'t','F'},'Position',[10 5 60 30]);
    
    % Edit field for specifying p-value threshold
    uicontrol(datasetPanel,'Style','text','String','p-value', ...
        'FontSize',11,'HorizontalAlignment','left', ...
        'Position',[75 38 50 20]);
    pValEdit = uicontrol(datasetPanel,'Style','edit', ...
        'Position',[75 15 50 20]);
    
    % Popup for selecting correction 
    uicontrol(datasetPanel,'Style','text','String','  Correction', ...
        'FontSize',11,'HorizontalAlignment','left', ...
        'Position',[130 38 70 20]);
    corrPopup = uicontrol(datasetPanel,'Style','popupmenu', ...
        'String',{'FWE','uncorrected'},'Position',[130 5 110 30]);
    
    % Checkbox for indicating whether to customise bounds of colorbar
    customCheck = uicontrol(datasetPanel,'Style','checkbox', ...
        'String','Set Custom Thresholds','FontSize',11, ...
        'Position',[245 40 320 20],'Callback',@custom_checkbox);
    
    % Edit fields for specifying colorbar minimum and maximum
    minEdit = uicontrol(datasetPanel,'Style','edit','String','Min', ...
        'Position',[250 15 60 20],'Enable','off');
    maxEdit = uicontrol(datasetPanel,'Style','edit','String','Max', ...
        'Position',[325 15 65 20],'Enable','off');

    
    % -- Anonymous functions -------------------------------------------
    
    % Callback function for custom thresholds checkbox
    function custom_checkbox(~,~,~)
        if (get(customCheck,'Value') == get(customCheck,'Max'))
            set(minEdit,'Enable','on');
            set(maxEdit,'Enable','on');
        else
            set(minEdit,'Enable','off');
            set(maxEdit,'Enable','off');
        end
    end

    % Callback function for channel locations checkbox
    function locations_checkbox(~,~,~)
        if (get(locationsCheck,'Value') == get(locationsCheck,'Max'))
            set(layoutPopup,'Enable','on');
        elseif (get(labelsCheck,'Value') == get(labelsCheck,'Min'))
            set(layoutPopup,'Enable','off');
        end
    end

    % Callback function for channel labels checkbox
    function labels_checkbox(~,~,~)
        if (get(labelsCheck,'Value') == get(labelsCheck,'Max'))
            set(layoutPopup,'Enable','on');
        elseif (get(locationsCheck,'Value') == get(locationsCheck,'Min'))
            set(layoutPopup,'Enable','off');
        end
    end

    % Callback function for load button
    function load_button(~,~,~)        
        clear thisData phParams

        % Prompt user for Porthole data file
        [filename, pathname] = uigetfile({'*.mat','MATLAB (*.mat)'}, ...
            'Select Porthole import');

        % User selected file, i.e. did not cancel
        if filename ~= 0
            dataFilename = cat(2,pathname,filename);
            set(loadEdit,'String',filename);
        end

        load(dataFilename);     % Load dataset from file
        
        % Check file contained Porthole dataset variable
        if exist('thisData','var') ~= 1
            error([filename ' does not contain valid dataset']);
        else
            fprintf(cat(2,'File selected: ',dataFilename,'\n'));
            
            % Check for previously saved Porthole parameters
            if exist('phParams','var')
                if ph_check_params(phParams) == 0
                    set_params();
                    fprintf('Imported previously saved parameters\n');
                else                    
                    warning(['Parameter errors found in file, ', ...
                        'loading data only']);
                end
            end
        end     
        
    end

    % Anonymous function for extracting parameters from GUI
    function get_params(~,~,~)
        
        dataType = get(typePopup,'String');
        phParams.dataType = dataType{get(typePopup,'Value')};       
        
        phParams.pVal = get(pValEdit,'String');
        
        corrString = get(corrPopup,'String');
        phParams.corrString = corrString{get(corrPopup,'Value')};
             
        phParams.sampleRate = str2double(get(freqEdit,'String'));
        phParams.preStim = str2double(get(prestimEdit,'String'));
        phParams.startTime = str2double(get(startEdit,'String'));
        
        phParams.channelLabelsFlag = get(labelsCheck,'Value');
        phParams.channelLocationsFlag = get(locationsCheck,'Value');
        phParams.channelFlag = phParams.channelLabelsFlag || ...
            phParams.channelLocationsFlag;
        
        channelLayout = get(layoutPopup,'String');
        phParams.channelLayout = channelLayout{get(layoutPopup,'Value')};
        
        phParams.customThreshFlag = get(customCheck,'Value');
        phParams.dataMax = str2double(get(maxEdit,'String'));
        phParams.dataMin = str2double(get(minEdit,'String'));
        
        scalpShape = get(shapePopup,'String');
        phParams.scalpShape = lower(scalpShape{get(shapePopup,'Value')});
        
    end

    % Anonymous function for assigning parameters to GUI 
    function set_params(~,~,~)
        
        set(pValEdit,'String',phParams.pVal);
        set(freqEdit,'String',num2str(phParams.sampleRate));
        set(prestimEdit,'String',num2str(phParams.preStim));
        set(startEdit,'String',num2str(phParams.startTime));
        
        set(customCheck,'Value',phParams.customThreshFlag);
        if phParams.customThreshFlag
            set(minEdit,'Enable','on');
            set(maxEdit,'Enable','on');
        else
            set(minEdit,'Enable','off');
            set(maxEdit,'Enable','off');
        end
            
        if ~isnan(phParams.dataMax)
            set(maxEdit,'String',num2str(phParams.dataMax));
        end
        if ~isnan(phParams.dataMin)
            set(minEdit,'String',num2str(phParams.dataMin));
        end
    
        set(labelsCheck,'Value',phParams.channelLabelsFlag);
        set(locationsCheck,'Value',phParams.channelLocationsFlag);
        if phParams.channelLabelsFlag || phParams.channelLocationsFlag
            set(layoutPopup,'Enable','on');
        else
            set(layoutPopup,'Enable','off');
        end        
    
        set(typePopup,'Value',find(strcmp(phParams.dataType, ...
            get(typePopup,'String'))));
        set(corrPopup,'Value',find(strcmp(phParams.corrString, ...
            get(corrPopup,'String'))));
        set(shapePopup,'Value',find(strcmpi(phParams.scalpShape, ...
            get(shapePopup,'String'))));
        set(layoutPopup,'Value',find(strcmp(phParams.channelLayout, ...
            get(layoutPopup,'String'))));        
    end

    % Callback function for start button 
    function start_button(~,~,~)      
        get_params();
        if ph_check_params(phParams) == 0
            porthole(thisData,phParams);
        end
    end

    % Callback function for save button
    function save_button(~,~,~)          
        % No dataset in workspace
        if exist('thisData','var') ~= 1             
            % Check whether user manuaully entered filename
            if strcmp(get(loadEdit,'String'), 'Load dataset...')
                fprintf('Please load dataset before saving parameters\n');
            else
                dataFilename = get(loadEdit,'String');  
                load(dataFilename); 
            end
        end
        
        % Check again for dataset
        if exist('thisData','var') ~= 1
            fprintf('Please load dataset before saving parameters\n');
        else
            get_params();
            ph_check_params(phParams); 
            save(dataFilename,'thisData','phParams');
            fprintf(['Appended parameters to dataset: ',dataFilename,'\n']);
        end                
    end

end


