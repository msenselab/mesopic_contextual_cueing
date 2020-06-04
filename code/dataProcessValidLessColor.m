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
        dataOut.(fieldName).RT = calMeanOfConditions(dataCurr.RT, dataCurr.NSub, dataCurr.New, dataCurr.NE, nSub);
        %CC.(fieldName) = dataOut.(fieldName).RT.spssArray(:,7:12)-dataOut.(fieldName).RT.spssArray(:,1:6) ;
        CC.(fieldName) = double(dataOut.(fieldName).RT.CCArrayNorm );
    end
    
    %%plot mean RTs and changes of CC together
    plotRTandCC(dataOut, nEp,nEpT,CC, nExp);
    
catch ME
    disp(ME.message);
end
end


function subBarPlot(plotData, barColor, figTitle, xTicksIn)
barWidth= 0.35;
%exp 1
subplot(1,3,3); hold on;
bar([1], plotData(1,1),  barWidth,'FaceColor',barColor(1,:));
bar([2], plotData(2,1),  barWidth,'FaceColor',barColor(2,:));

for i = 1:length(plotData(:,1))
    errorbar(i, plotData(i,1), plotData(i,2), 'k', 'linewidth',2);
end
ylabel('Change of CC (%)');
xticks([1:2]);
title(figTitle);
xticklabels( {xTicksIn(1,:), xTicksIn(2,:)});
xlim([0.7 2.3]);
%     set(gca,'XTickLabelRotation',15);
%     xlabel(xlabelIn);
hold off;
end

function plotRTandCC(dataOut, nEp, nEpT,CC, nExp)
%% calculate contextual cueing index
meanArray = [];
for iExp = 1:nExp
    fieldName = ['p' num2str(iExp)];
    %calculate CC difference between test and training session
    CCDiff = 100.*(CC.(fieldName)(:,6) - CC.(fieldName)(:,5));
    meanArray = [meanArray; [mean(CCDiff) std(CCDiff)/sqrt(length(CCDiff))]];
end
barColor = [0.6 0.6 0.6; 0.4 0.4 0.4];
markerSZ = 4;
lineWd = 0.8;
offset = 0.3 ;
xlimArry = [0 8.5];
%txtLoc = [1.3, 1.2; 5.25,1.2,];
txtLoc = [1.3, 1.1; 5.25, 1.1];
%% plot RT of the firt Exp
figure(), hold on;
set(gcf,'Units','inches','Position',[6 0.5 6.83 6.83*0.5]);
ylimArry = [0.8 4];
subplotMRT(xlimArry, ylimArry, dataOut.p1.RT, 1, '(A)', offset,nEp,nEpT, lineWd, markerSZ, txtLoc, 'Exp.1A', 'HC', 'LC', '', ''); %Exp.1A Photopic H2L
subplotMRT(xlimArry, ylimArry, dataOut.p2.RT, 2, '(B)', offset,nEp,nEpT, lineWd, markerSZ, txtLoc, 'Exp.1B', 'LC', 'HC', '', ''); %Exp.1B Photopic L2H
subBarPlot(meanArray(1:2,:), barColor,'(C)',['Exp.1A';'Exp.1B']);
saveas(gcf,'../figures/fig3_exp1.png')
hold off;




figure(), hold on;
set(gcf,'Units','inches','Position',[6 0.5 6.83 6.83*0.5]);
ylimArry = [0.8 4];
%     txtLoc(:,2) =  txtLoc(:,2) - 0.2;
subplotMRT(xlimArry, ylimArry, dataOut.p3.RT, 3, '(A)', offset,nEp,nEpT, lineWd, markerSZ,txtLoc, 'Exp.2A', 'HC', 'LC', 'light', 'light'); %Exp.2A  Mesopic H2L
subplotMRT(xlimArry, ylimArry, dataOut.p4.RT, 4, '(B)', offset,nEp,nEpT, lineWd, markerSZ,txtLoc, 'Exp.2B', 'LC', 'HC', 'light', 'light'); %Exp.2B  Mesopic L2H
subBarPlot(meanArray(3:4,:), barColor,'(C)',['Exp.2A';'Exp.2B']);
saveas(gcf,'../figures/fig4_exp2.png')
hold off;


figure(), hold on;
set(gcf,'Units','inches','Position',[6 0.5 6.83 6.83*0.5]);
ylimArry = [0.8 4.6];
txtLoc(:,2) =  txtLoc(:,2);
subplotMRT(xlimArry, ylimArry, dataOut.p5.RT, 5, '(A)', offset,nEp,nEpT, lineWd, markerSZ, txtLoc, 'Exp.3A', 'HC', 'HC', 'light', ''); %Exp.3A HC-M2P
subplotMRT(xlimArry, ylimArry, dataOut.p6.RT, 6, '(B)', offset,nEp,nEpT, lineWd, markerSZ, txtLoc, 'Exp.3B', 'HC', 'HC', 'light', ''); %Exp.3B LC-M2P
subBarPlot(meanArray(5:6,:), barColor,'(C)',['Exp.3A';'Exp.3B']);
saveas(gcf,'../figures/fig5_exp3.png')
hold off;


end



function subplotMRT(xlimArry, ylimArry, DataIn, FigNum, titleName, offset,nEp,nEpT, lineWd, markerSZ,txtLoc, expName, trainingTxt, transferTxt, trainingColor, transferColor)

darkColor = [0.5 0.5 0.5];
brightColor = [0.95 0.95 0.95];
whiteColor = [1 1 1];
leftFig = mod(FigNum-1,2)+1;
%separate training and test session in the figure
testRightShift = 0.6;
trainLeftShift = -0.4;
subplot(1,3, leftFig); hold on;
if FigNum <= 2
    set(gca,'Color',brightColor);
elseif FigNum <= 4
    set(gca,'Color',darkColor);
else
    set(gca,'Color', darkColor);
    rectangle('Position',[5.3, 0.1, 3.3, 4.7],'Curvature', [0 0], 'FaceColor',brightColor);
end

errbarTrainColor = [0 0 0];
if(strcmp(trainingColor,'light'))
    errbarTrainColor = [0.15 0.15 0.15];
end

errbarTransferColor = [0 0 0];
if(strcmp(transferColor,'light'))
    errbarTransferColor = [0.15 0.15 0.15];
end

errorbar((1:nEp)+trainLeftShift, DataIn.m(1:nEp), DataIn.e(1:nEp),'o-', 'color', errbarTrainColor,  'linewidth', lineWd,'MarkerSize',markerSZ);
errorbar((1:nEp)+offset+trainLeftShift, DataIn.m(nEp+nEpT+1:end-1), DataIn.e(nEp+nEpT+1:end-1),'^-', 'color', errbarTrainColor, 'linewidth', lineWd,'MarkerSize', markerSZ);
errorbar(nEp+1+testRightShift, DataIn.m(nEp+nEpT), DataIn.e(nEp+nEpT),'o-', 'color', errbarTransferColor, 'linewidth', lineWd,'MarkerSize',markerSZ);
errorbar((nEp+1+testRightShift)+offset, DataIn.m(end), DataIn.e(end),'^-', 'color', errbarTransferColor, 'linewidth', lineWd,'MarkerSize',markerSZ);

ylab = ['Reaction times (secs)'];
if(~isempty(expName))
    ylab = ['Reaction times in ' expName ' (secs)'];
end
ylabel(ylab);
xlabel('Epoch');
text(txtLoc(1,1), txtLoc(1,2), 'Training', 'Color', [.0 .0 .0]);
text(txtLoc(2,1), txtLoc(2,2), 'Transfer', 'Color',[.0 .0 .0]);
text(txtLoc(1,1)+1, txtLoc(1,2)-0.2, trainingTxt, 'Color', [.0 .0 .0]);
text(txtLoc(2,1)+1, txtLoc(2,2)-0.2, transferTxt, 'Color',[.0 .0 .0]);

set(gca,'xLim',[xlimArry]);
xticks([(1:5)+trainLeftShift 6+testRightShift]);
xticklabels( {'1', '2','3','4', '5', '6'});
set(gca,'yLim',ylimArry);
title([titleName]);
hold off;

end




