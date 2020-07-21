% Main script for running the surface - subsurface model
% Here you can define which year you want to compute, define your
% param{kk}eters, plot output variables, evaluate model performance....
%
% Author: Baptiste Vandecrux (bava@byg.dtu.dk)
% ========================================================================
clearvars
close all
clc
addpath(genpath('.\lib'))
addpath(genpath('Input'),genpath('Output'))

% All param{kk}eters are defined in a csv files in Input folder, however it is
% possible to overwrite the default value by defining them again in the
% "param{kk}" struct hereunder.

station_list =   {'KAN_M'};
% station_list = PROMICE_dir; %
RCM_list = {'RACMO'};

param = cell(size(RCM_list));
for kk = 1:length(RCM_list)
    
    % %%%%%%%%%%%%%%%%%%%%%
    % High resolution grid (comment if not needed)
    NumLayer = 100;
    param{kk}.z_max = 50;
    param{kk}.dz_ice = param{kk}.z_max/NumLayer;
    param{kk}.verbose = 1;
    param{kk}.lim_new_lay = param{kk}.z_max/NumLayer/10;

    % param{kk}.ConductionModel = 0;      % if 1 does CONDUCTION ONLY
    % In the conduction model, the temperature profile is reseted every night
    % at 2am local time usingg thermistor string readings

    % Heterogeneous precolation from Marchenko et al. (2017)
    % this considers only redistribution of the water from the first layer into
    % the rest of the subsurface
    % An alternative is to go through the whole column and check whether piping
    % can occur at any depth
    param{kk}.hetero_percol = 0; % 1 = whole scheme on; 0 = standard percolation
    param{kk}.hetero_percol_p = 1; % binomial probability for a piping event to be initiated
                                % In Marchenko et al. (2017) this happens at
                                % every time step (probability 1)
    param{kk}.hetero_percol_frac = 1; % fraction of the available water that can be
                                % In Marchenko et al. (2017) all the available
                                % water goes into redistribution (frac = 1)
    param{kk}.hetero_percol_dist = 5; % characteristic distance until which
                                % preferential percolation operates
                                % When using uniform probability distribution 
                                % for the redistribution Marchenko et al. (2017)
                                % recommends between 4.5 and 6 m as cut-off value

    % result of a tuning of densification schemes
    %    param{kk}.a_dens = 30.25;
    %    param{kk}.b_dens = 0.7;

    param{kk}.year    =  0;
    % by defining param{kk}.year, the model will be run only for that melt year
    % (i.e. 1st. april to 1st april) however you still need to make sure that 
    % "rows"  is set so that the appropriate values will be read in the weather 
    % data. To run the model only from 1 to rows, just leave param{kk}.year=0.

    param{kk}.track_density = 0;
    param{kk}.avoid_runoff = 0; 
    param{kk}.retmip = 0;

    % PROMICE_dir = dir('../AWS_Processing/Output/PROMICE/');
    % PROMICE_dir = {PROMICE_dir.name};
    % PROMICE_dir(1:2) = [];
    % for i = 1:length(PROMICE_dir)
    %     PROMICE_dir{i} = PROMICE_dir{i}(1:(end-6));
    % end
    param{kk}.vis = 'off';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%5
    model_version = RCM_list{kk};
        
for i =1:length(station_list)
    param{kk}.station =  station_list{i}; 
%     param{kk}.InputAWSFile = sprintf(['U:\\Storage Baptiste\\Code\\FirnModel_bv_v1.3\\Input' ...
%         '\\Weather data\\Temperature tracking\\data_%s_combined_hour.txt'],param{kk}.station);

    switch param{kk}.station
        case 'CP1'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/CP1/data_CP1_combined_hour.txt';
        case 'DYE-2'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/DYE-2/data_DYE-2_combined_hour.txt';
        case {'DYE-2_long' 'Dye-2_long'}
            param{kk}.InputAWSFile = 'data_DYE-2_1998-2015.txt';
        case {'DYE-2_HQ' 'Dye-2_16'}
            param{kk}.InputAWSFile = 'data_DYE-2_Samira_hour.txt';

        case 'Summit'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/Summit/data_Summit_combined_hour.txt';
        case 'NASA-SE'
    %         param{kk}.InputAWSFile = 'data_NASA-SE_1998-2015.txt';
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/NASA-SE/data_NASA-SE_combined_hour.txt';
        case 'NASA-E'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/NASA-E/data_NASA-E_combined_hour.txt';
        case 'NASA-U'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/NASA-U/data_NASA-U_combined_hour.txt';
        case 'SouthDome'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/SouthDome/data_SouthDome_combined_hour.txt';
        case 'TUNU-N'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/TUNU-N/data_TUNU-N_combined_hour.txt'; 
      case 'Saddle'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/Corrected/Saddle/data_Saddle_combined_hour.txt'; 
      case 'NGRIP'
            param{kk}.InputAWSFile = '../AWS_Processing/Output/NGRIP/data_NGRIP_combined_hour.txt'; 
      case 'GITS'
            param{kk}.InputAWSFile = ['../AWS_Processing/Output/GITS_',...
                model_version, '/data_GITS_combined_hour.txt'];
            param{kk}.OutputRoot = 'C:\Data_save\CC';

    % ======== other stations =================
    %     case {'KAN-U' 'KAN_U'}
    % %         param{kk}.InputAWSFile = 'data_KAN_U_combined_hour.txt';
    %         param{kk}.InputAWSFile = 'data_KAN_U_2012.txt';
    %         param{kk}.InputAWSFile = '../AWS_Processing/Output/KAN_U/data_KAN_U_combined_hour.txt';
        case {'Miege' 'FA'}
            param{kk}.InputAWSFile = 'data_Miege_combined_hour.txt';
        case PROMICE_dir
            param{kk}.InputAWSFile = ['../AWS_Processing/Output/PROMICE/',...
                param{kk}.station, '_RACMO/data_',...
                param{kk}.station, '_combined_hour.txt'];
            param{kk}.shallow_firn_lim = 3;
            param{kk}.deep_firn_lim = 5;
            param{kk}.min_tot_thick = 15;

            param{kk}.lim_new_lay = 0.005;
            param{kk}.z_max = 20;
            param{kk}.dz_ice = param{kk}.z_max/NumLayer;
        otherwise
            disp('Missing data file for the requested station.');
    end

% When you add sites
% 1) in Main.m: define path of InputAWSFile
% 2) in  .m: Define path for density profile
% 3) Make sure all information is reported in Input/Constants/InfoStation.csv file

%%  ========= Run model with name tag of your choice =======================
 [RunName, c] = HHsubsurf(param{kk});

end
end
