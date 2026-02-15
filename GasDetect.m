clc;
clear all;
close all;

f1 = figure;
f2 = figure;
f3 = figure;
f4 = figure;
f5 = figure;
f6 = figure;

FsOri = 244;
Ts = 1/FsOri;
R0 = 510; %千欧
RL = 22;  %千欧

fitArr = [];
featureBaseOri = [];    
featureBaseMinus = [];
labelBaseMat = [];
featureOri = [];    
featureMinus = [];
labelMat = [];

colorArr = {'#0072BD','#D95319','#7E2F8E'};

period = 200;
skipPoints = 20 * FsOri;  %有待商榷
periodPoint = period * FsOri;
sinFreq = 1/period;
cntBase = 0;
cntCon = 0;

R2BaseArr = [];
R2ConArr = [];

rmseBaseArr = [];
rmseConArr = [];
magBaseArr = [];
magConArr = [];
sumPhaDiff = [];

sumOutBaseArr = [];
sumOutConArr = [];
meanOutBaseArr = [];
meanOutConArr = [];
maxIdxArr = [];
maxConIdxArr = [];

baseBeginArr = [1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,2,1,1,1,1,2];  % The start file index
startPtArr = [20,20,2400,2400,1200,2400,2400,1200,20,20,2400,20,1200,2400,2400,2400,20,20,20,2400,20,20];  % The start minutes
beginSenArr = [9,9,6*ones(1,7),2*ones(1,4),6,2,2,6*ones(1,7)];  % The start index of TGS2618 in 16 sensor channels
endSenArr = [12,12,16*ones(1,21)];  % The end index of TGS2618 in 16 sensor channels

commonDir = 'I:\ExperimentDataCopy\IEEE_Dataport_preheat';
dirLen = 23;
beginDir = 1;  
for dirIdx = beginDir:dirLen   
    dirName = [commonDir, '\test', num2str(dirIdx)];        
    dirDataVOC = dir(dirName);
    dirDataVOC(1:2) = [];
    
    if dirIdx == dirLen
        matchString = '_air_sin200.mat';
        dirSensorBaseData = SelectFilesByRegExp(matchString,dirDataVOC); 
        baseNum = length(dirSensorBaseData);        
    else
        matchString = '_0ul_sin200.mat';
        dirSensorBaseData = SelectFilesByRegExp(matchString,dirDataVOC); 
        baseNum = length(dirSensorBaseData);
    end

    matchString = '1_(\d+\.?\d*)ul_sin200.mat'; 
    dirSensorData = SelectFilesByLeftRightText(dirDataVOC,matchString); 
    FileNum = length(dirSensorData);  
    
    for sensorInd = beginSenArr(dirIdx):endSenArr(dirIdx)   
        if sensorInd == 13  % Abnormal sensor channel
            continue;
        end
                
        baseBeginIdx = baseBeginArr(dirIdx);
        
        singleCoefBaseArr = [];
        phaseUnwrappBaseArr = [];
        for i = baseBeginIdx:baseNum
            filename = [dirSensorBaseData(i).folder '\' dirSensorBaseData(i).name];     
            volume = dirSensorBaseData(i).volume;
            
            dataLoad = load(filename);
            data_mix = dataLoad.data;
            datalenOri = length(data_mix(:,1));
            
            if datalenOri <= 1700*FsOri || dirIdx == dirLen-1
                maxSeg = 1;
                interPoints = 400 * FsOri;
            else
                maxSeg = 2;
                interPoints = 600 * FsOri;
            end
                                    

            if i == baseBeginIdx
                maxSeg = 1;
                startPoints = startPtArr(dirIdx);
            else
                startPoints = 20;
            end
                        
            inputCut = data_mix(startPoints*FsOri:end,1);
            totalLen = length(inputCut);
            partNum = floor(totalLen / periodPoint);                       
            
            for skipIdx = 1:maxSeg 
                skipPoints = (startPoints + (skipIdx-1)*1800) * FsOri; 
                %skipPoints = startPoints* FsOri + (skipIdx-1)*periodPoint ;  
                input = data_mix(skipPoints:end,1);
                [minInput,index] = min(input(1:periodPoint));  
                dataCut = data_mix(skipPoints+index(1):skipPoints+index(1)+interPoints,:);  
                   
                inputOri = dataCut(1:end,1)*2;
                output1Vol = dataCut(1:end,sensorInd); 
                output1Res = 2 * output1Vol * R0 * RL ./ (5*R0 - output1Vol * RL - 2 * output1Vol * R0);  %电阻值
                output1Conduct = 1./output1Res;  %电导率

                downSampleRate = 122;
                output1 = decimate(output1Conduct,downSampleRate);  
                inputLast = decimate(inputOri,downSampleRate);

                datalen = length(output1);
                Fs = FsOri/downSampleRate;
                time = linspace(0,datalen/Fs,datalen); 
                [maxValue,maxIdx] = max(output1(1:Fs*period));
                maxIdxArr = [maxIdxArr maxIdx];
                                   
                bestHarmoNum = 7;
                harmoArr = 0:bestHarmoNum;                

                [ZaEstOutBest,aEstBestTwoSideBase] = HarmoCoef_LS(output1,datalen,bestHarmoNum,sinFreq,Fs);
                fit = 1 - goodnessOfFit(real(ZaEstOutBest),output1,'NMSE');
                fitArr = [fitArr fit];  
                aEstBest = aEstBestTwoSideBase(bestHarmoNum+1:end);

                noLogMag = abs(aEstBest);
                singleCoef = (20*log10(abs(aEstBest)))';  
                phase = (angle(aEstBest))';            
                phaseUnwrapp = phaseUnwrapping_sin500(phase); 
                meanOut = mean(output1);                             
                                
                harmoArrFit = 1:(bestHarmoNum+1);
                if i == baseBeginIdx 
                    singleCoefBaseArr = [singleCoefBaseArr;singleCoef];
                    phaseUnwrappBaseArr = [phaseUnwrappBaseArr;phaseUnwrapp]; 
                    noLogMagBase = noLogMag;
                    singleCoefBase = singleCoef;
                    phaseUnwrappBase = phaseUnwrapp;
                    lastMeanOut = meanOut;
                    continue
                end       

                %singleCoefCon = sum(singleCoef - singleCoefBase);
                singleCoefCon = meanOut / lastMeanOut;
                phaseUnwrappCon = phaseUnwrapp - phaseUnwrappBase;                
                Rms = sqrt(mean(phaseUnwrappCon.^2));
                outputDiff = (meanOut - lastMeanOut)/lastMeanOut;
                sumOut = meanOut - lastMeanOut;
                
                for k = 2:(bestHarmoNum+1)
                    if phaseUnwrappCon(k) - phaseUnwrappCon(k-1) < -pi
                        phaseUnwrappCon(k:end) = phaseUnwrappCon(k:end) + 2*pi;
                    elseif phaseUnwrappCon(k) - phaseUnwrappCon(k-1) > pi
                        phaseUnwrappCon(k:end) = phaseUnwrappCon(k:end) - 2*pi;
                    else
                        phaseUnwrappCon = phaseUnwrappCon;
                    end
                end
                                
                % 拟合一个线性回归               
                mdl1 = fitlm(harmoArrFit, phaseUnwrappCon);
                R2 = mdl1.Rsquared.Ordinary;
                minusRmse = mdl1.RMSE;          
             
                rmseBaseArr = [rmseBaseArr minusRmse];
                meanOutBaseArr = [meanOutBaseArr outputDiff];
                sumOutBaseArr = [sumOutBaseArr sumOut];                
                
                R2BaseArr = [R2BaseArr R2];  
                magBaseArr = [magBaseArr singleCoefCon];
                labelBaseMat = [labelBaseMat;dirIdx sensorInd i skipIdx];
                
            end          
        end 
                         
        skipPoints = 20 * FsOri;
        startjIdx = 1;        
        lastCon = 0;
        for j = 1:FileNum   %FileNum
            filename = [dirSensorData(j).folder '\' dirSensorData(j).name];
            concen = dirSensorData(j).datenum / 1.2;
            
            if concen == 0
                continue
            end
            
            if concen > 10
                continue
            end
                              
            dataLoad = load(filename);
            data_mix = dataLoad.data;    
            input = data_mix(skipPoints:end,1);
            [minInput,index] = min(input(1:period*FsOri));  %相位从最小值开始
            dataCut = data_mix(skipPoints+index(1):end,:);  %相位都从0开始记录，把前几个周期的不稳定剔除 ,

            inputOri = dataCut(2:end,1)*2;
            output1Vol = dataCut(2:end,sensorInd); 
            output1Res = 2 * output1Vol * R0 * RL ./ (5*R0 - output1Vol * RL - 2 * output1Vol * R0);  %电阻值
            output1Conduct = 1./output1Res;  %电导率

            output1 = decimate(output1Conduct,downSampleRate);  
            inputLast = decimate(inputOri,downSampleRate);

            datalen = length(output1);
            Fs = FsOri/downSampleRate;
            time = linspace(0,datalen/Fs,datalen); 
            [maxValue,maxIdx] = max(output1(1:Fs*period));
            maxConIdxArr = [maxConIdxArr maxIdx];

            [ZaEstOutBest,aEstBestTwoSideBase] = HarmoCoef_LS(output1,datalen,bestHarmoNum,sinFreq,Fs);
            fit = 1 - goodnessOfFit(real(ZaEstOutBest),output1,'NMSE');
            fitArr = [fitArr fit];  
            aEstBest = aEstBestTwoSideBase(bestHarmoNum+1:end);

            meanOut = mean(output1);
            noLogMag = abs(aEstBest);
            singleCoef = (20*log10(abs(aEstBest)))';  
            phase = (angle(aEstBest))';            
            phaseUnwrapp = phaseUnwrapping_sin500(phase); 

            % 只减去前面一个浓度文件
            %singleCoefCon = sum(singleCoef - singleCoefBase);
            singleCoefCon = meanOut / lastMeanOut;
            
            phaseUnwrappCon = phaseUnwrapp - phaseUnwrappBase;               
            outputDiff = (meanOut - lastMeanOut)/lastMeanOut;  
            sumOut = meanOut - lastMeanOut;

            for k = 2:(bestHarmoNum+1)
                if phaseUnwrappCon(k) - phaseUnwrappCon(k-1) < -pi
                    phaseUnwrappCon(k:end) = phaseUnwrappCon(k:end) + 2*pi;
                elseif phaseUnwrappCon(k) - phaseUnwrappCon(k-1) > pi
                    phaseUnwrappCon(k:end) = phaseUnwrappCon(k:end) - 2*pi;
                else
                    phaseUnwrappCon = phaseUnwrappCon;
                end
            end
            mdl1 = fitlm(harmoArrFit, phaseUnwrappCon);
            R2 = mdl1.Rsquared.Ordinary;
            minusRmse = mdl1.RMSE;
            
            meanOutConArr = [meanOutConArr outputDiff];
            sumOutConArr = [sumOutConArr sumOut];
            rmseConArr = [rmseConArr minusRmse];
            R2ConArr = [R2ConArr R2];
            magConArr = [magConArr singleCoefCon];
            labelMat = [labelMat;dirIdx sensorInd lastCon concen];  
        end                 
    end
end
TimeTrainLast = [1,2,3,5,9,13.5,36,154];
TimeLast = [1,2,3,5,13,16,57,154];

% save('.\Parameter.mat','sumOutBaseArr','sumOutConArr',...
%     'magBaseArr','magConArr','meanOutBaseArr','meanOutConArr','rmseBaseArr','rmseConArr','labelBaseMat','labelMat')

load(fullfile('mat', 'MagPhaTrainTest.mat'));

figure('Position', [500, 300, 530, 320]);
errorbar(TimeTrainLast,meanMagTrainLast,stdMagTrainLast,'-*','LineWidth',3)
hold on
errorbar(TimeTrainLast,meanPhaTrainLast,stdPhaTrainLast,'-*','LineWidth',3)
ylabel('$P_\mathrm{D}$', 'Interpreter', 'latex')
set(gca, 'XScale', 'log');
set(gca, 'XLimMode', 'manual');
xlabel('Time (hour)')
% 使用虚拟线条创建图例
dummy1 = plot(NaN, NaN, 'color','#0072BD', 'LineWidth', 2.5, 'DisplayName', 'Magnitude feature');
dummy2 = plot(NaN, NaN, 'color','#D95319', 'LineWidth', 2.5, 'DisplayName', 'Phase feature');
legend([dummy1, dummy2], 'Location', 'best','fontsize',24);
set(gca,'Fontname','Times New Roman','fontsize',24)        
set(gca,'Linewidth',2)
grid on
grid minor
xlim([1,10^3])
xticks([10^0 10^1 10^2 10^3])
xticklabels({'10^0','10^1','10^2','10^3'})
ylim([0,1])
ytickformat('%.1f');
current_labels = yticklabels;
for yIdx = 1:length(current_labels)
    if strcmp(current_labels{yIdx}, '0.0')
        current_labels{yIdx} = '0';
    end
end
yticklabels(current_labels);

figure('Position', [500, 300, 530, 320]);
errorbar(TimeLast,meanMagTestLast,stdMagTestLast,'-*','LineWidth',3)
hold on
errorbar(TimeLast,meanPhaTestLast,stdPhaTestLast,'-*','LineWidth',3)
set(gca, 'XScale', 'log');
xlabel('Time (hour)')
ylabel('$P_\mathrm{D}$', 'Interpreter', 'latex')
set(gca, 'DefaultTextInterpreter', 'latex');
set(gca,'Fontname','Times New Roman','fontsize',24)        
set(gca,'Linewidth',2)
dummy1 = plot(NaN, NaN, 'color','#0072BD', 'LineWidth', 2.5, 'DisplayName', 'Magnitude feature');
dummy2 = plot(NaN, NaN, 'color','#D95319', 'LineWidth', 2.5, 'DisplayName', 'Phase feature');
legend([dummy1, dummy2], 'Location', 'best','fontsize',24);
grid on
grid minor
xlim([1,10^3])
xticks([10^0 10^1 10^2 10^3])
xticklabels({'10^0','10^1','10^2','10^3'})
ylim([0,1])
ytickformat('%.2f');
current_labels = yticklabels;
for yIdx = 1:length(current_labels)
    if strcmp(current_labels{yIdx}, '0.00')
        current_labels{yIdx} = '0';
    end
end
yticklabels(current_labels);
