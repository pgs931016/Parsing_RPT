% BSL Parsing Code
clc; clear; close all;


% %% Interface
% 
data_folder = 'G:\공유 드라이브\BSL-Data\Data\Hyundai_dataset\HNE 가속조건\1C 60 SEI';
% 
% Split the path using the directory separator
splitPath = split(data_folder, filesep);

% Find the index of "Data" (to be replaced)
index = find(strcmp('Data',splitPath), 1);

% Replace the first "Data" with "Processed_Data"
splitPath{index} = 'Processed_data';

% Create the new save_path
save_path = strjoin(splitPath, filesep);

% Create the directory if it doesn't exist
if ~exist(save_path, 'dir')
   mkdir(save_path)
end

I_1C = 55.6; %[A]
n_hd = 1; % headline number used in 'readtable' option. WonA: 14, Maccor: 3.
sample_plot = [1];

%% Engine
slash = filesep;
files = dir([data_folder slash 'HNE_Aging_SEI_1_7_87.txt']); % select only txt files (raw data)

for i = 1:length(files)
    fullpath_now = [data_folder slash files(i).name]; % path for i-th file in the folder
    data_now = readtable(fullpath_now,'FileType','text',...
                    'NumHeaderLines',n_hd,'readVariableNames',0); % load the data

    data1.I = data_now.Var7;
    data1.V= data_now.Var8;
    data1.t2 = data_now.Var6; % experiment time, format in duration
    data1.t1 = data_now.Var5; % step time, format in duration
    data1.cycle = data_now.Var4;
    data1.T = data_now.Var22;
    data1.Chgcap = data_now.Var10;
    data1.Dchgcap = data_now.Var11;
    data1.Vref = data_now.Var21;


     % datetime
     if isduration(data1.t2(1))
        data1.t = seconds(data1.t2);
     else
        data1.t = data1.t2;
     end

     % absolute current
     data1.I_abs = abs(data1.I);

     % type
     data1.type = char(zeros([length(data1.t),1]));
     data1.type(data1.I>0) = 'C';
     data1.type(data1.I==0) = 'R';
     data1.type(data1.I<0) = 'D';

     % step
     data1_length = length(data1.t);
     data1.step = zeros(data1_length,1);
     m  =1;
     data1.step(1) = m;
        for j = 2:data1_length
            if data1.type(j) ~= data1.type(j-1)
                m = m+1;
            end
            data1.step(j) = m;
        end



     %  check for error, if any step has more than one types
     vec_step = unique(data1.step);
     num_step = length(vec_step);
     for i_step = 1:num_step
          type_in_step = unique(data1.type(data1.step == vec_step(i_step)));
          
          if size(type_in_step,1) ~=1 || size(type_in_step,2) ~=1
              disp('ERROR: step assignent is not unique for a step')
              return
          end
     end


    % plot for selected samples
    if any(ismember(sample_plot,i))
        figure
      % [t,s] = title('Aging CH13');
        hold on

        % yyaxis left
        % plot(data1.t./3600,data1.V,'-')
        % plot(data1.t./3600,data1.Vref,'-g')
X = []; 
Y = [];
idx_list = []; % idx 값을 누적할 배열 초기화
% 
  % data2 =  load('G:\공유 드라이브\BSL-Data\Processed_data\Hyundai_dataset\HNE 가속조건\4C 10 Li-plating\3E SEP Specicif_plating18.mat');
% 


for i = 1:length(data1.Dchgcap)
    if data1.Dchgcap(i) ~= 0 && strcmp(data1.type(i), 'D')
        if i + 1 <= length(data1.type) && strcmp(data1.type(i + 1), 'R')
            idx = i ;
            idx_list = [idx_list, idx]; 
                X = [X, data1.cycle(idx)];
                Y = [Y, data1.Dchgcap(idx)];
        end
    end
end


% % X = [X; data2.x(2:end)];
% Y = [Y'; data2.y(2:end)'];


plot(1:length(Y), Y, 'o'); % 한 번에 플롯
xlabel('Cycle (n)');
ylabel('Capacity (Ah)');
title('SEI Aging Capacity');
set(gca, 'FontSize', 16);


        
        % xlabel('time (hours)')
        % ylabel('Voltage (V)')
        % xlabel('Cycle (n)')
        % ylabel('Capacity')
        % ylim([0 1.5])
  
        % yyaxis right
        % plot(data1.t./3600,data1.I/I_1C,'-')
        





       
        % ylabel('current (C)')
        % xlim([340013/3600 558298/3600])
        %xlim([162950 163100])
        %xlim([40.6572 86.5669])
        %xlim([40.5411 86.6944])
        % xlim([0 40.5411])
        % xlim([0 55])
        % ylim([-0.25 0.2])
        box on;
     
     % t.FontSize = 18;
    end

    % make struct (output format)
    data_line = struct('V',zeros(1,1),'I',zeros(1,1),'t',zeros(1,1),'indx',zeros(1,1),'type',char('R'),...
    'steptime',zeros(1,1),'T',zeros(1,1),'cycle',0);
    data = repmat(data_line,num_step,1);

    % fill in the struc
    n =1; 
    for i_step = 1:num_step

        range = find(data1.step == vec_step(i_step));
        data(i_step).V = data1.V(range);
        data(i_step).I = data1.I(range);
        data(i_step).t = data1.t(range);
        data(i_step).indx = range;
        data(i_step).type = data1.type(range(1));
        data(i_step).steptime = data1.t1(range);
        data(i_step).T = data1.T(range);
        data(i_step).cycle = data1.cycle(range(1));
        data(i_step).Q = abs(trapz(data1.t(range),data1.I(range)))/3600;
        %data(i_step).Vref = data1.Vref(range);
        % data(i_step).dchgcap = data1.dchagcap(range);
        % display progress
            if i_step> num_step/10*n
                 fprintf('%6.1f%%\n', round(i_step/num_step*100));
                 n = n+1;
            end
       
    end

    % data = data(85:end);
    % fig()

    %  plot(data.t./data.Q,'-')
    % save output data
    save_fullpath = [save_path slash '3E SEP Specicif_SEI.mat'];
    save(save_fullpath,'data','data1','X','Y')
    % 
    fig1 = fullfile(save_path,'3E SEP Specicif_SEI.fig');
    % 
    saveas(gcf, fig1);


end



