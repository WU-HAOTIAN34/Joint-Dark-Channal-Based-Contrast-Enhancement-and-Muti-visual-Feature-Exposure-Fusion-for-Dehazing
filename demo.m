clc;clear all; close all;

InputPath = '.\inputImages\';
FileName = dir(strcat(InputPath, '*.PNG'));
TextName = dir(strcat(InputPath, '*.txt'));

for k=1:length(FileName)
    tempFileName = FileName(k).name;
    tempTextName = TextName(k).name;
    ImPath = strcat(InputPath, tempFileName);
    TextPath = strcat(InputPath, tempTextName);

    temptext = importdata(TextPath);
    dsize = temptext(1);
    
    I_hazy = imread(ImPath);
    res = MVMEF(I_hazy,dsize);
    a = res(:,:,1);
    imwrite(res, ['.\result\', tempFileName(1:end-4), '.png',]);
end

