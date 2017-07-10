clc;
m = length(data.tr);
%m = 1000;
h = waitbar(0,'Initializing waitbar...');

for k = 1:m
part = data.tr{k};   
XY = part(:,1:2);
len = length(XY);
% 
% if len > 2    
%     for i = 1:len-1
%         vectarrow(XY(i,:), XY(i+1,:));
%         hold on
%     end
% end
if len >2
    perc = floor(k/m*100);
    waitbar(perc/100,h, horzcat('Track NO ', num2str(k), '/', num2str(m)));
    plot(XY(:,1), XY(:,2));
end

hold on;
end

close(h);
hold off;