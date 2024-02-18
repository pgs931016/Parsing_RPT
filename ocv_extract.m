clc; clear; close all;

% 데이터 로드
load('/Users/g.park/Library/CloudStorage/GoogleDrive-gspark@kentech.ac.kr/공유 드라이브/BSL_Data2/HNE_AgingDOE_processed/Experiment_data/Combined/CellID_6/CellID_6_Experiment_data.mat');

% cycle 값이 1인 인덱스 찾기
cycleOneIndexes = find([groupDataStruct.data.cycle] == 1);

% 인덱스 그룹화
indexDiffs = diff(cycleOneIndexes);
groupBreaks = [1, find(indexDiffs > 1) + 1, numel(cycleOneIndexes) + 1]; % 그룹 경계 인덱스

% 각 그룹에서 처음 7개 인덱스의 데이터 추출
groupedData = struct(); % 그룹 데이터를 저장할 구조체 초기화
for i = 1:numel(groupBreaks)-1
    groupStart = groupBreaks(i);
    groupEnd = min(groupBreaks(i+1)-1, groupStart + 6); % 그룹 내 7개 요소 또는 그 미만
    groupIndexes = cycleOneIndexes(groupStart:groupEnd); % 실제 인덱스 추출
    
    % 해당 인덱스의 데이터 추출
    for j = 1:length(groupIndexes)
        index = groupIndexes(j);
        groupedData(i).data(j) = groupDataStruct.data(index);
    end
end

% groupedData에서 데이터를 추출하여 별도의 변수에 할당
numGroups = min(length(groupedData), 4); % 처리할 그룹 수 설정

for i = 1:numGroups
    varName = sprintf('RPT%d', i); % 동적 변수 이름 생성 (예: RPT1, RPT2, ...)
    if ~isempty(groupedData(i).data)
        assignin('base', varName, groupedData(i).data); % 동적 변수에 데이터 할당
    end
end

save('RPT1.mat','RPT1');
save('RPT2.mat','RPT2');
save('RPT3.mat','RPT3');
save('RPT4.mat','RPT4');