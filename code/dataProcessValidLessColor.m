%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Description:   plot Change of CC from the training to the test session (figure 4 in the manuscript)
%% Author:        Xuelian Zang
%% Contact:       zangxuelian@gmail.com or lianlian81821@126.com
%% Date:          15/10/2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataOut = dataProcessValidLessColor(dataAll,  nSub, nEp, nEpT, nExp)
try
    
    titleIn='Reaction time (in Secs)';
    dataOut.RTContrastEp1Spss = [ ];
    dataOut.meanRTArrayEP1 = [];
    dataOut.errRTArrayEP1 = [];
    dataOut.RTContrast = [];
    contrastLabel = [1  0;  0 1;  3 2;  2 3;  3 1;  2 0];
    for iExp = 1:nExp
        fieldName = [ 'p' num2str(iExp)];
        dataCurr = dataAll(dataAll.NExp == iExp, :);
        %set contrast label of the training and the test epoch in each experiment
        dataCurr.contrast = contrastLabel( iExp , 1) * ones( size(dataCurr.RT) );
        dataCurr.contrast(dataCurr.NE > 5)  =  contrastLabel( iExp , 2);
        % calculate mean RT for different contrast / lighting
        % condition with all epochs
        tmp = grpstats(dataCurr, {'contrast','NSub'},{'mean'},'DataVars','RT');
        dataOut.(fieldName).RTContrastSpss  = reshape(tmp.mean_RT, nSub, []);%for each participant
        dataOut.(fieldName).RTContrastMean = grpstats(tmp , {'contrast'},{'mean','sem'},'DataVars','mean_RT');%overall mean
        
        % calculate mean RT for different contrast/lighting in the
        % first epoch
        dataCurrEp1 = dataCurr(dataCurr.NE == 1, :);
        RTContrastEp1Spss = grpstats( dataCurrEp1, {'contrast', 'NSub'},{'mean','sem'},'DataVars','RT');
        dataOut.RTContrastEp1Spss = [ dataOut.RTContrastEp1Spss,   RTContrastEp1Spss.mean_RT ];
        
        RTContrast = grpstats(  RTContrastEp1Spss, {'contrast'},{'mean','sem'},'DataVars','mean_RT');
        dataOut.RTContrast = [dataOut.RTContrast; [RTContrast.mean_mean_RT, RTContrast.sem_mean_RT] ];
        % calculate mean RTs for each condition
        dataOut.(fieldName).RT = calMeanOfConditions(dataCurr.RT, dataCurr.NSub, dataCurr.New, dataCurr.NE, nSub, nEp, nEpT, titleIn);
        %CC.(fieldName) = dataOut.(fieldName).RT.spssArray(:,7:12)-dataOut.(fieldName).RT.spssArray(:,1:6) ;
        CC.(fieldName) = double(dataOut.(fieldName).RT.CCArrayNorm );
    end
  
    % Figure 3 plot Mean RTs, with associated standard errors
    plotRTWithEpoch(dataOut, nEp,nEpT);
    
    % Figure 4 plot the Change of CC from the training to the test session
    plotFig4(CC, nExp);
    
catch ME
    disp(ME.message);
end
end

%% TODO the function need to be rewritten
% define a function to plot the Change of CC from the training to the test session
function plotFig4(CC, nExp)
meanArray = [];
for iExp = 1:nExp
    fieldName = ['p' num2str(iExp)];
    %calculate CC difference between test and training session
    CCDiff = 100.*(CC.(fieldName)(:,6) - CC.(fieldName)(:,5));
    meanArray = [meanArray; [mean(CCDiff) std(CCDiff)/sqrt(length(CCDiff))]];
end

barWidth= 0.35;
figure(); hold on;

bar([1, 3], meanArray([1,3],1),  barWidth,'FaceColor',[0.2 0.2 0.2]);
bar([2, 4], meanArray([2,4],1),  barWidth,'FaceColor',[0.5 0.5 0.5]);
bar([5, 6], meanArray([5,6],1),  0.6,'FaceColor',[0.8 0.8 0.8]);
for i = 1:length(meanArray)
    errorbar(i, meanArray(i,1), meanArray(i,2), 'k', 'linewidth',2);
end

ylabel('Change of CC (ms)');
xticks([1:6]);
xticklabels( {'Exp.1 Photopic H2L', 'Exp.2 Photopic L2H','Exp.3 Mesopic H2L','Exp.4 Mesopic L2H', 'Exp.5 HC-M2P', 'Exp.6 LC-M2P'});
set(gca,'XTickLabelRotation',-35);
legend( {'H2L', 'L2H', 'M2P'},'Location','Southoutside', 'Orientation', 'horizontal');
legend('boxoff');
text(-1.1, -385, 'Transfer');
text(1.52, 380, 'p=.019');
text(3.45, 350, 'p=.002');
hold off;
end





function plotRTWithEpoch(dataOut,  nEp, nEpT)
figure(), hold on;
set(gcf,'Units','inches','Position',[6 0.5 6.83 6.83*0.9]);


markerSZ = 4;
lineWd = 0.8;
offset = 0.3 ;

ylimArry = [0.9 4.8];
xlimArry = [0 6.8];

subplotMRT(xlimArry, ylimArry, dataOut.p1.RT, 1, 'Exp.1 Photopic H2L', offset,nEp,nEpT, lineWd, markerSZ);
subplotMRT(xlimArry, ylimArry, dataOut.p2.RT, 2, 'Exp.2 Photopic L2H', offset,nEp,nEpT, lineWd, markerSZ);
subplotMRT(xlimArry, ylimArry, dataOut.p3.RT, 3, 'Exp.3 Mesopic H2L', offset,nEp,nEpT, lineWd, markerSZ);
subplotMRT(xlimArry, ylimArry, dataOut.p4.RT, 4, 'Exp.4 Mesopic L2H', offset,nEp,nEpT, lineWd, markerSZ);
subplotMRT(xlimArry, ylimArry, dataOut.p5.RT, 5, 'Exp.5 HC-M2P', offset,nEp,nEpT, lineWd, markerSZ);
subplotMRT(xlimArry, ylimArry, dataOut.p6.RT, 6, 'Exp.6 LC-M2P', offset,nEp,nEpT, lineWd, markerSZ);

hold off;
end


function subplotMRT(xlimArry, ylimArry, DataIn, FigNum, titleName, offset,nEp,nEpT, lineWd, markerSZ)
   subplot(2,3,FigNum); hold on;
  
       errorbar(1:nEp, DataIn.m(1:nEp), DataIn.e(1:nEp),'ko-',  'linewidth', lineWd,'MarkerSize',markerSZ);
       errorbar((1:nEp)+offset, DataIn.m(nEp+nEpT+1:end-1), DataIn.e(nEp+nEpT+1:end-1),'k^-' , 'linewidth', lineWd,'MarkerSize', markerSZ);
       errorbar(nEp+1, DataIn.m(nEp+nEpT), DataIn.e(nEp+nEpT),'ko-', 'linewidth', lineWd,'MarkerSize',markerSZ);
       errorbar((nEp+1)+offset, DataIn.m(end), DataIn.e(end),'k^-', 'linewidth', lineWd,'MarkerSize',markerSZ);

       if FigNum == 1
            legend('old','new');
       end

       if FigNum == 1 || FigNum == 4
             ylabel('Reaction times (secs)');
       end

        if FigNum == 5
            xlabel('epoch');
        end
       set(gca,'xLim',[xlimArry]);  
       set(gca,'xTick',[1:1:6]);
       set(gca,'yLim',ylimArry);    
       title(titleName);
       hold off;
           
end




