% BSL Formation Code
clc; clear; close all;


%% Interface
% data_folder = 'C:\Users\jsong\Documents\MATLAB\Data\OCP\OCP0.05C_Cathode Half cell(5)';
data_folder = '/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/Battery Software Lab/Processed_data/Hyundai_dataset/HNE_FCC_AgingDOE_RPT_231126/HNE_FCC_RPT_231126';
save_path = data_folder;
I_1C = 0.00429; %[A]
slash = filesep;

%% Engine
files = dir([data_folder filesep '*.mat']);

for i = 1:length(files)
    fullpath_now = [data_folder filesep files(i).name];% path for i-th file in the folder
    load(fullpath_now);
end


% RPT-OCV
Vmin = 2.5;

rate = -0.05;
indices = [];
for j = 1:length(data)
        data(j).Iavg = mean(data(j).I);
        if  abs(rate - data(j).Iavg/I_1C) < -rate*0.02 && data(j).V(end)<Vmin
            indices = [indices, j];
            index1 = indices(1);
        disp(['Value found at index ', num2str(j)]);
        end
end


if isempty(indices)
    error('No cycles with the specified value found.');
end

fields = fieldnames(data);
OCV = repmat(struct(), index1, 1);
for i = 1:index1+1
    for j = 1:length(fields)
        fieldName = fields{j};
        OCV(i).(fieldName) = data(i).(fieldName);
    end 
end



%RPT-DCIR
rate = -0.2;
indices = [];
for j = 1:length(data)
    data(j).Iavg = mean(data(j).I);
    if  abs(rate - data(j).Iavg/I_1C) < -rate*0.02 && j>index1 && data(j).V(end)<Vmin
        indices = [indices, j];
        index2 = indices(1);
        disp(['Value found at index ', num2str(j)]);
    end
end

if isempty(indices)
    error('No cycles with the specified value found.');
end

fields = fieldnames(data);
DCIR = repmat(struct(), index2, 1);
for i = index1+2:index2+1
    for j = 1:length(fields)
        fieldName = fields{j};
        DCIR(i).(fieldName) = data(i).(fieldName);
    end
end



%RPT-CRATE
rate = -4;
indices = [];
for j = 1:length(data)
    data(j).Iavg = mean(data(j).I);
    if  abs(rate - data(j).Iavg/I_1C) < -rate*0.02 && j>index2  && data(j).V(end)<Vmin
        indices = [indices, j];
        index3 = indices(1);      
        disp(['Value found at index ', num2str(j)]);
    end
end

if isempty(indices)
    error('No cycles with the specified value found.');
end

fields = fieldnames(data);
CRATE = repmat(struct(), index3, 1);
for i = index2+2:index3+1
    for j = 1:length(fields)
        fieldName = fields{j};
        CRATE(i).(fieldName) = data(i).(fieldName);
    end
end



%RPT-GITT
fields = fieldnames(data);
GITT = repmat(struct(), index3+2, 1);
for i = index3+2:length(data)
    for j = 1:length(fields)
        fieldName = fields{j};
        GITT(i).(fieldName) = data(i).(fieldName);
    end
end



%RPT 범위
OCV = OCV(1:index1+1);
DCIR = DCIR(index1+2:index2+1);
CRATE = CRATE(index2+2:index3+1);
GITT = GITT(index3+2:end);




%OCV 데이터 세트에 대한 그래프 그리기
all_times = vertcat(OCV.t);
all_voltages = vertcat(OCV.V);
all_currents = vertcat(OCV.I);

figure;
hold on;
title('OCV');
xlabel('Time (hours)');
yyaxis left;
ylabel('Voltage (V)');
plot(all_times/3600, all_voltages, '-');

yyaxis right;
ylabel('C rate'); 
plot(all_times/3600, all_currents/I_1C, '-');
hold off;



% DCIR 데이터 세트에 대한 그래프 그리기
all_times = vertcat(DCIR.t);
all_voltages = vertcat(DCIR.V);
all_currents = vertcat(DCIR.I);

figure;
hold on;
title('DCIR');
xlabel('Time (hours)');
yyaxis left;
ylabel('Voltage (V)');
plot(all_times/3600, all_voltages, '-');

yyaxis right;
ylabel('C rate'); 
plot(all_times/3600, all_currents/I_1C, '-');
hold off;



% CRATE 데이터 세트에 대한 그래프 그리기
all_times = vertcat(CRATE.t);
all_voltages = vertcat(CRATE.V);
all_currents = vertcat(CRATE.I);

figure;
hold on;
title('CRATE');
xlabel('Time (hours)');
yyaxis left;
ylabel('Voltage (V)');
plot(all_times/3600, all_voltages, '-');

yyaxis right;
ylabel('C rate'); 
plot(all_times/3600, all_currents/I_1C, '-');
hold off;



% CRATE 데이터 세트에 대한 그래프 그리기
all_times = vertcat(GITT.t);
all_voltages = vertcat(GITT.V);
all_currents = vertcat(GITT.I);

figure;
hold on;
title('GITT');
xlabel('Time (hours)');
yyaxis left;
ylabel('Voltage (V)');
plot(all_times/3600, all_voltages, '-');

yyaxis right;
ylabel('C rate'); 
plot(all_times/3600, all_currents/I_1C, '-');
hold off;



%폴더 이름 설정
ocv_folder = 'RPT_OCV';
dcir_folder = 'RPT_DCIR';
crate_folder = 'RPT_CRATE';
gitt_folder = 'RPT_GITT';


% 각 폴더가 없으면 생성
if ~exist(fullfile(save_path, ocv_folder), 'dir')
    mkdir(fullfile(save_path, ocv_folder));
end

if ~exist(fullfile(save_path, dcir_folder), 'dir')
    mkdir(fullfile(save_path, dcir_folder));
end

if ~exist(fullfile(save_path, crate_folder), 'dir')
    mkdir(fullfile(save_path, crate_folder));
end

if ~exist(fullfile(save_path, gitt_folder), 'dir')
    mkdir(fullfile(save_path, gitt_folder));
end



for i = 1:length(files)
    fullpath_now = [data_folder filesep files(i).name]; % path for i-th file in the folder
    load(fullpath_now);

    % ... (rest of your existing code)

    % 폴더 이름 설정
    ocv_save_path = fullfile(save_path, ocv_folder, [files(i).name(1:end-4) '.mat']);
    dcir_save_path = fullfile(save_path, dcir_folder, [files(i).name(1:end-4) '.mat']);
    crate_save_path = fullfile(save_path, crate_folder, [files(i).name(1:end-4) '.mat']);
    gitt_save_path = fullfile(save_path, gitt_folder, [files(i).name(1:end-4) '.mat']);

    % 각 데이터 저장
    save(ocv_save_path, 'OCV');
    save(dcir_save_path, 'DCIR');
    save(crate_save_path, 'CRATE');
    save(gitt_save_path, 'GITT');
end


