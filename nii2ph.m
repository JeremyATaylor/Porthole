
% Function: nii2mat
% -----------------
%  Converts a NIfTI-1 image from file to local variable and saves as
%  a MAT-file via a graphical user inferface for use with the 
%  Porthole visualisation tool.
%
%  Note: Ensure SPM has been added the MATLAB search path.

function nii2ph 

    % Prompt user for NIfTI filepath
    [fileName, pathName] = uigetfile({'*.nii','NIfTI-1 (*.nii)'}, ...
        'Select NIfTI-1 image');

    % User selected file, i.e. did not cancel
    if fileName ~= 0
        fullPath = cat(2,pathName,fileName);
        fprintf(cat(2,'File selected: ',fullPath,'\n'));
        fprintf('Importing from NIfTI-1...\n');

        % Read NIfTI image into 3D matrix
        headerInfo = spm_vol(fullPath);
        thisData = spm_read_vols(headerInfo);

        % Save variable as .mat file
        fprintf('Saving as MAT-file...\n');
        uisave('thisData','Untitled1');
    end
    
end