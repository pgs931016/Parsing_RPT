% BSL Post processing code for rate capability test
clear; clc; close all;


%% Interface

% data folder
%data_folder = 'G:\Shared drives\Battery Software Lab\Data\Hyundai_dataset\C_rate\HNE_FCC_(6)_C_rate';
%OCV_fullpath = 'G:\Shared drives\Battery Software Lab\Data\Hyundai_dataset\OCV\FCC_(5)_OCV_C100.mat';
%np = 1; % 1 for CHC and FC, -1 for AHC

%data_folder = 'G:\Shared drives\Battery Software Lab\Data\Hyundai_dataset\C_rate\HNE_CHC_(5)_C_rate';
%OCV_fullpath = 'G:\Shared drives\Battery Software Lab\Data\Hyundai_dataset\OCV\CHC_(5)_OCV_C100.mat';
%np = 1; % 1 for CHC and FC, -1 for AHC


data_folder = 'H:\공유 드라이브\BSL_CYCLE\Data\LFP (16Ah)\Processed\4C60\RPT (OCV, DCIR, CRATE )';
OCV_fullpath = 'H:\공유 드라이브\BSL_CYCLE\Data\LFP (16Ah)\Processed\4C60\RPT (OCV, DCIR, CRATE )\OCV_golden.mat';
np = 1; % 1 for CHC and FC, -1 for AHC


% test parameters
    % capacity
    I_1C = 16; % [A]
    % tested c-rates
    crate_chg_vec = [0.1 0.5 1 2 4];
    crate_dis_vec = -crate_chg_vec;


%% Engine

% load OCV
load(OCV_fullpath) % variables: OCV_all, OCV_golden

% C-rate test filees
files = dir([data_folder filesep 'C-rate CH4*.mat']);

for i = 1
    fullpath_i = [data_folder filesep files(i).name];
    load(fullpath_i) % variable: data

    step_crate_chg = zeros(size(crate_chg_vec)); n = 1; 
    step_crate_dis = zeros(size(crate_dis_vec)); m = 1;
    for j = 1:length(data)
        % calculate the average current
            % ** this will be the selection criteria 
        data(j).Iavg = mean(data(j).I);

        % calculate step capacity (absolute)
        if length(data(j).t) > 1
            data(j).dQ = abs(trapz(data(j).t,data(j).I))/3600; % [Ah]
            data(j).cumdQ = abs(cumtrapz(data(j).t,data(j).I))/3600; %[Ah]
        else
            data(j).dQ = 0;
            data(j).cumdQ = 0;
        end
        


        % marking C-rate tests
        
        nth_chg = find(abs(crate_chg_vec - data(j).Iavg/I_1C) < 0.001);
        nth_dis = find(abs(crate_dis_vec - data(j).Iavg/I_1C) < 0.001);

        if ~isempty(nth_chg) && np*j < np*length(data)/2
            data(j).mark = nth_chg; % charging mark: 1, 2 ,3,..
            step_crate_chg(n) = j;
            n = n+1;
        elseif  ~isempty(nth_dis) && np*j > np*length(data)/2
            data(j).mark = -nth_dis; % dicharging mark: -1, -2, -3,...
            step_crate_dis(m) = j;
            m = m+1;
        else
            data(j).mark = 0;
        end


    end


    clear n m



    %% Plot Charging

    if np < 0 % anode
        step_crate_chg = [2 6 10 14 18];
    end

    % color map
    c_mat = turbo(length(step_crate_dis)+1);

    % plot OCV
    Q_ocv = mean([OCV_all.Qchg]);
    figure(1)
    hold on; box on
    plot(OCV_golden.OCVchg(:,1),OCV_golden.OCVchg(:,2),'Color','m','LineStyle','--');
    legend({'C/20'})
    hold on;

    % plot only C-rate tests
    % [temporal] only works for full cell
    for n = 1:length(step_crate_chg)
        j_n = step_crate_chg(n);

        % calculate soc
        [x_uniq,ind_uniq] = unique(OCV_golden.OCVchg(:,2));
        y_uniq = OCV_golden.OCVchg(ind_uniq',1);
        soc0 = interp1(x_uniq,y_uniq,data(j_n-1).V(end));
        % data(j_n).soc = soc0 + data(j_n).cumdQ/Q_ocv;
        %data(j_n).soc = soc0 - (1-0.23)*data(j_n).cumdQ/Q_ocv;
        data(j_n).soc = soc0 + data(j_n).cumdQ/Q_ocv;

        % plot
         plot(data(j_n).soc,data(j_n).V,'color',c_mat(n,:))
    end

    legend({'C/20','C/10','C/2','1C','2C','4C'},'location','southeast')

xlabel('SOC')
ylabel('voltage (V)')
xlim([0 1]);
ylim([2 4])
title('C-rate(Charge) CH4');
set(gca,'FontSize',15)
box on;

   % fig1 = fullfile(data_folder,'C-rate CH3.fig');
   %  saveas(gcf, fig1);

    if np <0
        return
    end
%% Plot Discharging

    % figure(2)
    % hold on; box on
    % plot(OCV_golden.OCVdis(:,1),OCV_golden.OCVdis(:,2),'Color','m','LineStyle','--');
    % 
    % 
    % for m = 1:length(step_crate_dis)
    %     j_m = step_crate_dis(m);
    % 
    %     % calculate soc
    %     soc1 = 1; % previous charging had CCCV
    %     % data(j_m).soc = 1-data(j_m).cumdQ/Q_ocv;
    %     data(j_m).soc = 0.01 + (1-0.01)*data(j_m).cumdQ/Q_ocv;
    % 
    %     %plot
    %     plot(data(j_m).soc,data(j_m).V,'color',c_mat(m,:))
    % end
    % 
    % 
    % legend({'C/20','C/10','C/2','1C','2C','4C'})


end










