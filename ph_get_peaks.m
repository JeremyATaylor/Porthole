
% Function: ph_get_peaks
% ----------------------
%  Detect discrete clusters within three-dimensional Porthole dataset and
%  compute the number of voxels, peak value and timepoint index for each.
%
%      thisData: Spatiotemporal dataset, specified as 3-D numeric array
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor 

%% ph_get_peaks

function [clusterSize, clusterMaxima, clusterPeak] = ph_get_peaks(thisData)

    % Binarise data and label discrete clusters
    [labeledData, clusterCount] = bwlabeln(thisData > 0);

    fprintf('Detected %d clusters\n', clusterCount);

    clusterSize = zeros(clusterCount,1);    % Number of voxels in cluster
    clusterMaxima = zeros(clusterCount,1);  % Maximum value in cluster
    clusterPeak = zeros(clusterCount,1);    % Time index of maxima

    % Iterate through clusters
    for c = 1:clusterCount    

        % Find size and maximum value within cluster
        clusterDataVector = thisData(find(labeledData == c));
        clusterSize(c) = length(clusterDataVector);
        clusterMaxima(c) = max(clusterDataVector);

        % Mask cluster from original data
        clusterDataVolume = (labeledData == c) .* thisData;

        % Time vector of local maxima within each time slice
        clusterPeakVector = squeeze(max(max(clusterDataVolume)));

        % Find time index where global maxima occurs
        [~,i] = max(clusterPeakVector);
        clusterPeak(c) = i;

    end

    % Sort clusters by descending order of maxima
    [clusterMaxima,i] = sort(clusterMaxima,'descend');
    clusterPeak = clusterPeak(i);
    clusterSize = clusterSize(i);

end