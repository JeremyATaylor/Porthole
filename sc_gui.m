
% Function: sc_gui
% ----------------
%  Graphical user interface (GUI) for Stormcloud three-dimensional 
%  spatiotemporal rendering and/or exporting two-dimensional scalp maps.
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor 

function sc_gui

    global phParams scParams thisData clusterSize clusterMaxima clusterPeak

    % Initialise new figure
    f = figure('MenuBar','none','NumberTitle','off',...
        'Name','Stormcloud Menu','ToolBar','none',...
        'Position',[100 100 435 340]);
    
    % -- Load Import Elements  -----------------------------------------
    
    % Edit field for displaying or entering data filename 
    loadEdit = uicontrol(f,'Style','edit','String','Load dataset...',...
        'Position',[30 295 330 25],'FontSize',11,'FontAngle','italic');
    
    % Load button for importing data from file
    uicontrol(f,'Style','pushbutton','String','Load',...
        'Position',[370 290 45 33],'FontSize',11,'Callback',@load_button);
    
    % Start button for launching 3-D Stormcloud diagram
    uicontrol(f,'Style','pushbutton','String','Launch Stormcloud',...
        'Position',[20 20 195 40],'FontSize',13,'Callback',@start_button);

    % Export button for generating 2-D scalp maps
    uicontrol(f,'Style','pushbutton','String','Export Scalp Maps', ...
        'Position',[230 20 185 40],'FontSize',13,'Callback',@export_button);
    
    
    % -- Peak Selection Panel -------------------------------------------
    
    % Parent UI panel for peak selection elements
    peakPanel = uipanel(f,'Title','Peak Selection','FontSize',12,...
        'Units','pixels','Position',[20 80 195 190]); 
    
    % Checkbox indicating whether to annotate clusters 
    peakCheck = uicontrol(peakPanel,'Style','checkbox','Value',1, ...
        'String','Enable peak annotations','FontSize',11,...
        'Position',[15 145 320 20],'Callback',@peak_checkbox);
    
    % Listbox and header summarising all peaks within dataset 
    peakList = uicontrol(peakPanel,'Style','listbox', ...
        'FontSize',11,'FontName','FixedWidth','Max',Inf,'Min',1, ...
        'HorizontalAlignment','left','Position',[15 50 160 70]);
    peakHeader = uicontrol(peakPanel,'Style','text', ...
        'String','#    Size     Peak','FontSize',11, ...
        'HorizontalAlignment','left','FontName','FixedWidth', ...
        'FontWeight','bold','Position',[15 120 160 20]);
    
    % Instructions for selecting multiple peaks from listbox
    if ismac
        multiSelectString = ['To select multiple peaks, hold the ', ...
            'Command key and click each item'];
    else
        multiSelectString = ['To select multiple peaks, hold the ', ...
            'Control key and click each item'];
    end
    peakInstr = uicontrol(peakPanel,'Style','text','FontSize',10, ...
        'String',multiSelectString,'Position',[15 15 160 30]);
    
    
    % -- Display Customisation Panel ------------------------------------
    
    % Parent UI panel for display customisation elements
    displayPanel = uipanel(f,'Title','Display','FontSize',12,...
        'Units','pixels','Position',[235 80 180 190]);     
    
    % Popup to select circular or oval scalp shape
    shapeLabel = uicontrol(displayPanel,'Style','text', ...
        'FontSize',11,'HorizontalAlignment','left', ...
        'String','  Scalp Shape','Position',[10 95 80 20]);
    shapePopup = uicontrol(displayPanel,'Style','popupmenu',...
        'String',{'Circle','Oval'},'Position',[10 65 80 30]);
 
    % Popup to select volume viewing angle 
    uicontrol(displayPanel,'Style','text','String','  Viewing Angle', ...
        'FontSize',11,'HorizontalAlignment','left', ...
        'Position',[10 145 120 20]);
    viewPopup = uicontrol(displayPanel,'Style','popupmenu', ...
        'String',{'Right Posterior','Right Anterior','Left Anterior', ...
        'Left Posterior'},'Position',[10 115 120 30]);
    
    % Popup to select which side z-axis appears in figure
    uicontrol(displayPanel,'Style','text','String', ...
        '  Axis Side','FontSize',11,'HorizontalAlignment','left', ...
        'Position',[90 95 80 20]);
    axisPopup = uicontrol(displayPanel,'Style','popupmenu', ...
        'String',{'Left','Right'},'Position',[90 65 80 30]);
    
    % Checkbox indicating whether to customise limits of colour map
    customCheck = uicontrol(displayPanel,'Style','checkbox', ...
        'String','Set Custom Thresholds','FontSize',11, ...
        'Position',[15 40 320 20],'Callback',@custom_checkbox);
    
    % Edit fields to enter colour map minima and maxima
    minEdit = uicontrol(displayPanel,'Style','edit','String','Min', ...
        'Position',[15 15 65 20],'Enable','off');
    maxEdit = uicontrol(displayPanel,'Style','edit','String','Max', ...
        'Position',[95 15 65 20],'Enable','off');
    
    
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

    % Callback function for peak annotation checkbox
    function peak_checkbox(~,~,~)
        if (get(peakCheck,'Value') == get(peakCheck,'Max'))
            set(peakList,'Enable','on');
            set(shapePopup,'Enable','on');
            set(customCheck,'Enable','on');
            set(shapeLabel,'Enable','on');
            set(peakInstr,'Enable','on');
            set(peakHeader,'Enable','on');
            custom_checkbox();
        else
            set(peakList,'Enable','off');
            set(shapePopup,'Enable','off');
            set(customCheck,'Enable','off');
            set(minEdit,'Enable','off');
            set(maxEdit,'Enable','off');
            set(shapeLabel,'Enable','off');
            set(peakInstr,'Enable','off');
            set(peakHeader,'Enable','off');
        end
    end

    % Callback function for load button
    function load_button(~,~,~)        
        
        clear thisData

        % Prompt user for Porthole data file
        [filename, pathname] = uigetfile({'*.mat','MATLAB (*.mat)'}, ...
            'Select Porthole dataset');

        % User selected file, i.e. did not cancel
        if filename ~= 0
            dataFilename = cat(2,pathname,filename);
            set(loadEdit,'String',filename);
        end

        % Load file and check contents for Porthole dataset
        load(dataFilename);                     
        if exist('thisData','var') ~= 1
            error([filename ' does not contain valid dataset']);
        else
            fprintf(cat(2,'File selected: ',dataFilename,'\n'));
    
            % Extract cluster information from dataset
            [clusterSize,clusterMaxima,clusterPeak] = ...
                ph_get_peaks(thisData);

            % Cast numeric cluster information to strings
            clusterMaximaString = num2str(clusterMaxima,'%.3f');
            clusterSizeString = num2str(clusterSize,'%d');
            tableData = cell(1,length(clusterMaxima));
    
            % Format cluster information and update listbox
            for i = 1:length(clusterMaxima)
                tableData{i} = sprintf('%d    %s    %s',i, ...
                    clusterSizeString(i,:), clusterMaximaString(i,:));
            end
            set(peakList,'String',tableData);
            fprintf('Updated peak selection table\n');
        end       
    end
    
    % Callback function for start button
    function start_button(~,~,~)
        get_params();                   % Extract parameters from GUI
        stormcloud(thisData,scParams);  % Launch Stormcloud
    end

    % Callback function for export button
    function export_button(~,~,~)   
        get_params();                   % Extract parameters from GUI
        
        % Check peak annotation is enabled and peaks have been selected
        if ~scParams.annotateFlag 
            warning(['To export scalp maps, first enable peak ' ...
                'annotations, then select the peaks of interest']);
        else
            sc_export_maps(thisData,scParams);  % Export scalp maps
        end
    end

    % Anonymous function for extracting all parameters from GUI
    function get_params(~,~,~)
        scParams = struct;          % Initialise new data structure
        
        % Annotation Flag
        if get(peakCheck,'Value') == get(peakCheck,'Max')
            scParams.annotateFlag = 1;
        else
            scParams.annotateFlag = 0;
        end
        
        % Cluster Peaks
        scParams.peaks = clusterPeak(get(peakList,'Value'));  
        
        % Viewing Angle
        scParams.viewIndex = get(viewPopup,'Value');
        
        % Scalp Shape 
        shapeString = get(shapePopup,'String');
        scParams.scalpShape = lower(shapeString{get(shapePopup,'Value')});
        
        % Axis Side
        axisString = get(axisPopup,'String');
        scParams.axisSide = lower(axisString{get(axisPopup,'Value')});
        
        % Custom Threshold
        if get(customCheck,'Value') == get(customCheck,'Max')
            scParams.customThreshFlag = 1;
        else
            scParams.customThreshFlag = 0;
        end

        % Data minimum and maximum
        scParams.dataMax = str2double(get(maxEdit,'String'));
        scParams.dataMin = str2double(get(minEdit,'String'));  
    end

end