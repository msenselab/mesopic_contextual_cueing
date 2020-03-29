%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Description:   Data Analysis code for mesopic contextual learning project
%% Author:        Xuelian Zang
%% Contact:       zangxuelian@gmail.com or lianlian81821@126.com
%% date:          10/05/2013
%% update date: 28/03/2020
%% modified by Fiona Zhu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataProcessAll()

try
    close all
    clear all
    
    % set configurate parameters
    nEp = 5;
    nEpT = 1;
    subNum = 30;
    nExp = 6;
    
    % load the experiment data
    load('AllData');
    load('ErrData');
    load('RecData');
    load('DisData');
    

    
    % plot Mean error rates as a function of RT quartile subset(Figure 2)
    nEpAll = nEp + nEpT;
    ErrorProcess(dataAll, dataErr, nEpAll, nExp, subNum);
    
    % process the valid data and plot Figure 3 and Figure 4
    dataProcessValidLessColor(dataAll, subNum, nEp, nEpT, nExp);
    
    % recognition test and plot Figure 6 
    dataProcessRec(dataRec, subNum, nExp,nEpT);
catch ME
    disp(ME.message);
end

end


