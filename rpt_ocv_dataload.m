clc;clear;close all

%input 지정(ocp,ocv데이터),function model,function cost,cost function

%load the data
% data1 = load('/Users/g.park/Documents/gspark/OCV_Result_RPT1.mat');
% data1 = load('/Users/g.park/Documents/gspark/OCV_Result_RPT2.mat');
% data1 = load('/Users/g.park/Documents/gspark/OCV_Result_RPT3.mat');
data1 = load('/Users/g.park/Documents/gspark/OCV_Result_RPT4.mat');
data5 = load('/Users/g.park/Downloads/AHC_(5)_OCV_C20 .mat');
data6 = load('/Users/g.park/Downloads/CHC_(5)_OCV_C20.mat');

%half_cell_ocp(averaging the three) = golden ocp
 OCV2   = data1.OCV_golden.OCVchg;
 OCP_n1 = data5.OCV_golden.OCVchg;
 OCP_p1 = data6.OCV_golden.OCVchg;
 
% %Variable name(dataList)
% %datalist = dataList;
 
%plot actual OCP data (parameter)
%for i=1:size(OCP_n,2) %MATLAB에서 배열의 열을 반복하는 데 사용
     figure(1); hold on; box on
     plot(OCP_n1(:,1),OCP_n1(:,2))
     figure(2); hold on; box on
     plot(OCP_p1(:,1),OCP_p1(:,2)) 
%end
figure(1)
title('Anode OCP')
xlabel('x in LixC6')
ylabel('OCP [V]')
figure(2)
title('Cathode OCP')
xlabel('y in LixMO2')
ylabel('OCP [V]')

% 
% % plot actual OCV data(Variable)
% %for i=1:size(datalist,1) %MATLAB에서 배열의 행을 반복하는 데 사용
    Cap = data1.OCV_golden.OCVchg(:,1); % [Ah] Discharged capacity
    Cap_end = Cap(end);
    Q_cell = abs(Cap_end);
   % Q_cell = Cap_end;
    OCV_chg = data1.OCV_golden.OCVchg(:,2); % [V] Cell Voltage     
    %measurement = [Cap,OCV]; % OCV measurement matrix [q [Ah], v[V]]
    figure(3); hold on; box on
    plot(Cap,OCV_chg)  
%end
figure(3)
title('Full Cell OCV')
xlabel('Cap[mAh]')
ylabel('OCV [V]')

save('OCV_fit.mat','Q_cell','OCP_n1','OCP_p1','OCV2','Cap',"data1","data5","data6");
