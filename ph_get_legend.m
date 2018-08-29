
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
    
    % Colour lookup table
    colour = [0.510, 0.122, 0.133;
              0.776, 0.122, 0.149;
              0.929, 0.129, 0.141;
              0.933, 0.220, 0.137;
              0.937, 0.259, 0.133;
              0.961, 0.467, 0.137;
              0.992, 0.686, 0.137;
              0.973, 0.898, 0.247;
              0.984, 0.949, 0.537];

    theta = linspace(0,2*pi);
    x = 0.25*cos(theta)-9;
    y = 0.25*sin(theta);
    
    % Generate circular patches for each colour
    patch(x, y, colour(1,:));
    patch(x, y+0.75, colour(2,:), 'EdgeColor','none');
    patch(x, y+1.5, colour(3,:),'EdgeColor','none');
    patch(x, y+2.25, colour(4,:),'EdgeColor','none');
    patch(x, y+3, colour(5,:),'EdgeColor','none');
    patch(x, y+3.75, colour(6,:),'EdgeColor','none');
    patch(x, y+4.5, colour(7,:),'EdgeColor','none');
    patch(x, y+5.25, colour(8,:),'EdgeColor','none');
    patch(x, y+6, colour(9,:),'EdgeColor','none');
    
    % Create text objects for maximum and minimum t/F-values
    text(-8.25,0,1,num2str(minValue),'Color','w', ...
        'FontSize',10,'FontName','Fira Mono OT','FontWeight','normal');
    text(-8.25,6,1, num2str(maxValue),'Color','w', ...
        'FontSize',10,'FontName','Fira Mono OT','FontWeight','normal');
    
    text(-11,6.25,1,[dataType '-VALUE '],'Color','w', ...
        'FontSize',12,'FontName','Fira Mono OT', ...
        'FontWeight','bold','Rotation',90,'HorizontalAlignment','right');
    
    % Probability text objects
    pString = cat(2,'(p<',num2str(pVal),',',pString,')');
    text(-10,6.25,1,pString,'Color',[0.75,0.75,0.75], ...
        'FontSize',11,'FontName','Fira Mono OT','FontWeight','normal',...
        'Rotation',90,'HorizontalAlignment','right');
    
end