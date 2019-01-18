
% Function: ph_draw_scalp
% -----------------------
%  Draws a scalp outline with nose and ear reference points over the
%  display window.
%
%         xDim: Width of dataset spatial component
%         yDim: Height of dataset spatial component
%         zDim: Timeslice of ataset temporal component
%   scalpShape: Shape of scalp as string descriptor - 'oval' (SPM style) 
%                    or 'circle' (EEGlab or FieldTrip style) 
%
%  Copyright (C) 2018 
%  Written by Jeremy Taylor 

function ph_draw_scalp(xDim,yDim,zDim,scalpShape)        

    if ~isnumeric(xDim) || xDim <= 0
        error('xDim (%d) is not a valid integer value',xDim);
    end
    if ~isnumeric(yDim) || xDim <= 0
        error('yDim (%d) is not a valid integer value',yDim);  
    end
    
    if strcmp(scalpShape,'oval') 
        a = 0.4*xDim;
    elseif strcmp(scalpShape,'circle')
        a = 0.5*xDim;
    else
        error(['Invalid scalp shape (' scalpShape '): Specify string ' ...
            'descriptor "circle" or "oval"']);
    end
   
    b = yDim*0.5;
    xMax = 2*a;
    
    if zDim == 0.001
        lineWidth = 2;                    
        lineColour = [0.3 0.3 0.3];
    else
        lineWidth = 1;                    
        lineColour = [0.5 0.5 0.5];
    end
    
    hold on

%% Draw scalp outline

    theta = linspace(0,2*pi);     
    r = (a*b)./(sqrt((b*cos(theta)).^2 + (a*sin(theta)).^2));

    x = r.*cos(theta) + xMax/2;
    y = r.*sin(theta) + yDim/2;
    z = linspace(zDim,zDim);
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);
   
%% Draw nose

    x0 = a*cos(80/360*2*pi) + xMax/2;  
    y0 = (yDim/2)*sin(80/360*2*pi) + yDim/2;
    theta = 135/360*2*pi;
    radius = linspace(0, (x0-xMax/2)*sqrt(2));
    x = radius*cos(theta) + x0;
    y = radius*sin(theta) + y0;
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);
    
    x0 = a*cos(100/360*2*pi) + xMax/2;
    y0 = (yDim/2)*sin(100/360*2*pi) + yDim/2;
    theta = 225/360*2*pi;
    radius = linspace(0, (x0-xMax/2)*sqrt(2));
    x = radius*cos(theta) + x0;
    y = radius*sin(theta) + y0;
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);
    
%% Draw Left Ear
    
    x0 = 1.0462*(xMax/2)*cos(170/360*2*pi) + a;
    y0 = 1.0462*(yDim/2)*sin(170/360*2*pi) + b;
    theta = linspace(0,pi);
    radius = 0.0462*(xMax/2);
    
    x = radius*cos(theta) + x0;
    y = radius*sin(theta) + y0;
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);
    
    x1 = x0 + radius*cos(pi);
    y1 = y0 + radius*sin(pi);
    
    x0 = 1.0462*(xMax/2)*cos(190/360*2*pi) + a;
    y0 = 1.0462*(yDim/2)*sin(190/360*2*pi) + b;
    theta = linspace(pi,2*pi);
    radius = 0.0462*(xMax/2);
    
    x = radius*cos(theta) + x0;
    y = radius*sin(theta) + y0;
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);
    
    x2 = x0 + radius*cos(pi);
    y2 = y0 + radius*sin(pi);
    
    x = linspace(x1,x2);
    y = linspace(y1,y2);
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);   
    
%% Draw Right Ear
    
    x0 = 1.0462*(xMax/2)*cos(10/360*2*pi) + a;
    y0 = 1.0462*(yDim/2)*sin(10/360*2*pi) + b;
    theta = linspace(0,pi);
    radius = 0.0462*(xMax/2);
    
    x = radius*cos(theta) + x0;
    y = radius*sin(theta) + y0;
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);
    
    x1 = x0 + radius*cos(2*pi);
    y1 = y0 + radius*sin(2*pi);
    
    x0 = 1.0462*(xMax/2)*cos(350/360*2*pi) + a;
    y0 = 1.0462*(yDim/2)*sin(350/360*2*pi) + b;
    theta = linspace(pi,2*pi);
    radius = 0.0462*(xMax/2);
    
    x = radius*cos(theta) + x0;
    y = radius*sin(theta) + y0;
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);
    
    x2 = x0 + radius*cos(2*pi);
    y2 = y0 + radius*sin(2*pi);
    
    x = linspace(x1,x2);
    y = linspace(y1,y2);
    
    plot3(x,y,z,'Color',lineColour,'LineWidth',lineWidth);
    
end
