clc;clear all; close all;
% FADE example
InputPath = '..\result\';
FileName = dir(strcat(InputPath, '*.png'));

for i = 1:length(FileName)
    tempFileName = FileName(i).name;
    ImPath = strcat(InputPath, tempFileName);
    image = imread(ImPath); 
    density = FADE(image);
    entropy(image)
    imwrite(image,['res/' tempFileName '+' num2str(density) '.png'])
end
