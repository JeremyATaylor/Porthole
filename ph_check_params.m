
% Function: ph_check_params
% -------------------------
%  Error handling routine for Porthole parameter data structure. 
%  Displays warning messages for each error found and returns to total
%  number of errors.
%
%      params: Porthole parameters to be checked, specified as struct
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor

function [retVal] = ph_check_params(params)

    retVal = 0;     % Initialise error count
    
    % Warning messages are appended to list as errors are found
    warningList = '\nPlease check the following parameters:\n';
    fprintf('Verifying parameters...\n');

    if ~isstruct(params)
        error('Porthole parameters not packaged in struct data type');
    end

    % -- Dataset fields ------------------------------------------------
    
    % Contrast data type
    if ~isfield(params,'dataType')
        error('Data structure missing "dataType" field');
    elseif ~strcmp(params.dataType,'t') && ~strcmp(params.dataType,'F')
        error(['Data structure contains invalid data type ', ...
            '(expected "t" or "F" values)']);
    end
    
    % p-value
    if ~isfield(params,'pVal')
        error('Data structure missing "pVal" field');
    elseif isnan(str2double(params.pVal))
        warningList = cat(2,warningList, ...
            ' - p-value not specified or non-numeric\n');
        retVal = 1;
    elseif str2double(params.pVal) <= 0 || str2double(params.pVal) >= 1
        warningList = cat(2,warningList, ...
            ' - p-value outside expected range (0 to 1)\n');
        retVal = 1;
    end

    % Correction string
    if ~isfield(params,'corrString')
        error('Data structure missing "corrString" field');
    elseif ~strcmp(params.corrString,'FWE') && ...
            ~strcmp(params.corrString,'uncorrected')
        error(['Data structure contains invalid correction ', ...
            'string (expected "FWE" or "uncorrected")']);
    end    
    
    % Custom thresholds
    if ~isfield(params,'customThreshFlag')
        error('Data structure missing "customThreshFlag" field');  
    elseif params.customThreshFlag ~= 1 && params.customThreshFlag ~= 0
        error(['Data structure contains invalid custom ', ...
            'threshold flag (expected 0 or 1)']); 
    elseif params.customThreshFlag
        if isnan(params.dataMax) || isnan(params.dataMin)
            warningList = cat(2,warningList, ...
                ' - Custom Thresholds not specified or non-numeric\n');
            retVal = 1;
        elseif params.dataMin >= params.dataMax
            warningList = cat(2,warningList, ...
                ' - Custom Theshold minima greater than or equal to maxima\n');
            retVal = 1;      
        end
    end
    
    % -- Timing fields -------------------------------------------------
        
    % Check sampling rate is valid number
    if ~isfield(params,'sampleRate')
        error('Data structure missing "sampleRate" field');
    elseif isnan(params.sampleRate)
        warningList = cat(2,warningList, ...
            ' - Sampling Frequency not specified or non-numeric\n');
        retVal = 1;
    elseif params.sampleRate <= 0
        warningList = cat(2,warningList, ...
            ' - Sampling Frequency must be positive integer\n');
        retVal = 1;
    end
    
    % Pre-stimulus interval
    if ~isfield(params,'preStim')
        error('Data structure missing "preStim" field');
    elseif isnan(params.preStim)
        warningList = cat(2,warningList, ...
            ' - Pre-Stimulus Time not specified or non-numeric\n');
        retVal = 1;
    elseif str2double(params.preStim) >= 0
        warningList = cat(2,warningList, ...
            ' - Pre-Stimulus Time expected to be negative integer\n');
        retVal = 1;
    end
    
    % Start time
    if ~isfield(params,'startTime')
        error('Data structure missing "startTime" field');
    elseif isnan(params.startTime)
        warningList = cat(2,warningList, ...
            ' - Animation Start Time not specified or non-numeric\n');
        retVal = 1;
    end
    
    % -- Display fields ------------------------------------------------
    
    % Scalp shape
    if ~isfield(params,'scalpShape')
        error('Data structure missing "scalpShape" field');
    elseif ~strcmp(params.scalpShape,'oval') && ...
            ~strcmp(params.scalpShape,'circle')
        error(['Data structure contains invalid scalp shape ',...
            'string (expected "circle" or "oval")']);
    end 
    
    % Channel flags
    if ~isfield(params,'channelFlag')
        error('Data structure missing "channelFlag" field');  
    elseif params.channelFlag ~= 1 && params.channelFlag ~= 0
        error(['Data structure contains invalid ', ...
            'channel flag (expected 0 or 1)']);
    elseif params.channelLocationsFlag ~= 1 && ...
            params.channelLocationsFlag ~= 0
        error(['Data structure contains invalid ', ...
            'Channel Locations flag (expected 0 or 1)']);
    elseif params.channelLabelsFlag ~= 1 && params.channelLabelsFlag ~= 0
        error(['Data structure contains invalid ', ...
            'Channel Labels flag (expected 0 or 1)']);
    elseif params.channelFlag ~= (params.channelLabelsFlag || ...
            params.channelLocationsFlag)
        error(['Data structure contains inconsistancy between ', ...
            'channel flags (labels, locations and overall)']);        
    end
    
    % Channel Layout
    if ~isfield(params,'channelLayout')
        error('Data structure missing "channelLayout" field');
    elseif ~strcmp(params.scalpShape,'oval') && ...
            ~strcmp(params.scalpShape,'circle')
        error(['Data structure contains invalid Channel Layout ',...
            'string (expected "10-10" or "10-20")']);
    end     
    
    % ------------------------------------------------------------------
        
    % Check whether any errors were found
    if retVal
        fprintf(warningList);   % Display error messages
    end
    
end