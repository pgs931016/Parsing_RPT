clc;clear;close all

folder_path{1} = 'G:\공유 드라이브\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\4CPD 1C (25-42)\10degC';
folder_path{2} = 'G:\공유 드라이브\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\4CPD 4C (25-42)\10degC';
folder_path{3} = 'G:\공유 드라이브\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\1CPD 1C (25-42)\10degC';
% folder_path{4} = 'G:\공유 드라이브\BSL_Data2\HNE_AgingDOE_Processed\HNE_FCC\1CPD 4C (25-42)\10degC';


legend_texts = {}; % 모든 폴더에 대한 legend 항목을 저장할 셀 배열 초기화

for k = 1:length(folder_path)
    % 해당 폴더의 파일 정보를 가져와서 data 변수에 저장
    files_s01 = dir(fullfile(folder_path{k}, '*s01*Merged7.mat'));
    files_s02 = dir(fullfile(folder_path{k}, '*s02*Merged7.mat'));
    merged_files = [files_s01; files_s02];


    for n = 1:length(merged_files)
       % 데이터 불러오기
       fullpath_now = fullfile(folder_path{k},merged_files(n).name);
       try
        data_now = load(fullpath_now);
       catch
        fprintf('Warning: Unable to load file "%s". Skipping...\n', merged_files(n).name);
        continue; % 다음 반복으로 건너뛰기
    end
       % 데이터 필드 잇는지 에러 확인
       if ~isfield(data_now, 'data_merged')
           error('File "%s" does not contain the expected variable "data".', merged_files(n).name);
        continue;
       end
       data_merged = data_now.data_merged;


   
    fileParts = strsplit(merged_files(n).name, '_');
    newNamePart = strjoin(fileParts(end-5:end-3)); 
    legend_texts{end+1} =  newNamePart;
    hold on;

    


figure(1)
data_D = data_merged(([data_merged.type]=='D')&(abs([data_merged.Q])>0.002)&([data_merged.rptflag]==0)|([data_merged.OCVflag])==2);
scatter([data_D.cycle],abs([data_D.Q])*1000, 'DisplayName', newNamePart)
ylim([0 5]);
xlabel('Cycle (n)');
ylabel('Cap (mAh)');  
hold on;

    end
end

figure(1)
legend(legend_texts, 'Location', 'best');
xlabel('Cycle (n)');
ylabel('Cap (mAh)');
ylim([2 5]);



% figure(2)
% Q_D_max = data_merged(([data_merged.type]=='D')&([data_merged.OCVflag])==2);
% Q_D_max = Q_D_max(1).Q;
% ylim([0 1.2]);
% xlabel('Cycle (n)');
% ylabel('Cap / Cap0');
% 
% Q_norm  = abs([data_D.Q]) / abs(Q_D_max);
% scatter([data_D.cycle],Q_norm)
% legend(newNamePart);hold on;
% 
% 
% figure(3)
% data_D_t = [];
% for i = 1:length(data_D)
% data_D_t = [data_D_t, data_D(i).t(end)]; 
% end
% scatter(data_D_t/3600,Q_norm)
% ylim([0.4 1.2]);
% xlabel('Time (h)');
% ylabel('Cap / Cap0');
% legend(newNamePart);hold on;


% figure(4)
% plot(data_merged.t, data_merged.I);
% 
% xlabel('Time (h)');
% ylabel('Current (mAh)');
% legend(newNamePart);hold on;


% figure(5)
% plot(data_merged.t, data_merged.V);
% 
% xlabel('time (h)');
% ylabel('Voltage (V)');
% legend(newNamePart);hold on;


% figure(1)
% legend;

% figure(2)
% legend(legend_texts);
% 
% figure(3)
% legend(legend_texts);

% figure(4)
% legend(legend_texts);
% 
% figure(5)
% legend(legend_texts);



  % legendFontSize = 16; % 적절한 폰트 크기로 변경하세요
  %   legend_handle = legend('레전드1', '레전드2', '레전드3'); % 레전드 핸들을 가져옵니다.
  %   set(legend_handle, 'FontSize', legendFontSize); % 레전드의 폰트 크기를 설정합니다.