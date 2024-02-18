clc; clear; close all;

%% Interface

% data folder
data_folder = '/Users/g.park/Documents/gspark/MATLAB/Code';
% For a single file, specify directly
data_file = 'RPT4.mat'; % 파일 이름을 RPT4로 업데이트

% Load the data file directly
load(fullfile(data_folder, data_file));

% cathode, fullcell, or anode
id_cfa = 2; % Assuming fullcell for this example

% OCV steps
step_ocv_chg = 4;
step_ocv_dis = 6;

% parameters
y1 = 0.215685; % Example parameter

%% Engine

% Calculate capabilities for RPT4
for idx = 1:length(RPT4) % RPT4의 각 요소에 대해 반복
    if numel(RPT4(idx).t) > 1
        RPT4(idx).Q = abs(trapz(RPT4(idx).t,RPT4(idx).I))/3600; %[Ah]
        RPT4(idx).cumQ = abs(cumtrapz(RPT4(idx).t,RPT4(idx).I))/3600; %[Ah]
    end
end

RPT4(step_ocv_chg).soc = RPT4(step_ocv_chg).cumQ/RPT4(step_ocv_chg).Q;
RPT4(step_ocv_dis).soc = 1-RPT4(step_ocv_dis).cumQ/RPT4(step_ocv_dis).Q;

% Assemble the OCV struct for the single dataset using RPT4
x_chg = RPT4(step_ocv_chg).soc;  
y_chg = RPT4(step_ocv_chg).V;
z_chg = RPT4(step_ocv_chg).cumQ;
x_dis = RPT4(step_ocv_dis).soc;
y_dis = RPT4(step_ocv_dis).V;
z_dis = RPT4(step_ocv_dis).cumQ;

OCV_all.OCVchg = [x_chg y_chg z_chg];
OCV_all.OCVdis = [x_dis y_dis z_dis];

OCV_all.Qchg = RPT4(step_ocv_chg).Q;
OCV_all.Qdis = RPT4(step_ocv_dis).Q;

% Since there's only one dataset, it's also the golden dataset
OCV_golden = OCV_all;

% Plotting (if needed)
% 필요한 경우 여기에 OCV_golden 및 OCV_all을 사용하여 플로팅 코드를 작성하세요.

% Save
% 저장 경로를 필요에 따라 업데이트하세요.
save_folder = '/Users/g.park/Documents/gspark'; % 경로 업데이트
save_name = 'OCV_Result_RPT4'; % 저장 이름을 OCV_Result4_RPT4로 업데이트
save_fullpath = fullfile(save_folder, [save_name '.mat']);
save(save_fullpath, 'OCV_golden', 'OCV_all');




