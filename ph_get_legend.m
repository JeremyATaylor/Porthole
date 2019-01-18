
% Function: ph_get_legend
% -----------------------
%  Generates legend alongside the display window.
%
%       dataType: Character indicating type of values 
%       minValue: Minimum value within the dataset
%       maxValue: Maximum value within the dataset
%           pVal: Numeric probablity value 
%        pString: String for probability correction label
%
%  Copyright (C) 2018 ComCogNeuro
%  Written by Jeremy Taylor

function ph_get_legend(dataType,minValue,maxValue,pVal,pString) 
    
    load('ph_colours_64_warm.mat','colourMap');
    
    % Generate circular patches for each colour
    for i = 1:size(colourMap,1)
        x = [-9.25 -8.75 -8.75 -9.25];
        y = [0.1*i 0.1*i 0.1*(i-1) 0.1*(i-1)];
        patch(x,y,colourMap(i,:),'EdgeColor','none');
    end
    
    % Create text objects for maximum and minimum t/F-values
    text(-8.25,0.25,1,num2str(minValue),'Color','w', ...
        'FontSize',10,'FontName','Fira Mono OT','FontWeight','normal');
    text(-8.25,6.25,1, num2str(maxValue),'Color','w', ...
        'FontSize',10,'FontName','Fira Mono OT','FontWeight','normal');
    
    text(-11,6.25,1,[dataType '-VALUE '],'Color','w', ...
        'FontSize',12,'FontName','Fira Mono OT', ...
        'FontWeight','bold','Rotation',90,'HorizontalAlignment','right');
    
    % Probability text objects
    if strcmp(pString,'uncorrected')
        pString = cat(2,'(p<',num2str(pVal),',unc.)');
    else
        pString = cat(2,'(p<',num2str(pVal),',',pString,')');
    end
    
    text(-10,6.25,1,pString,'Color',[0.75,0.75,0.75], ...
        'FontSize',11,'FontName','Fira Mono OT','FontWeight','normal',...
        'Rotation',90,'HorizontalAlignment','right');
    
end