%% Information
% title              : State-dependent online reactivation for learning strategies in foraging
% authors            : Sangkyu Son, Maya Zhe Wang, Benjamin Y. Hayden, Seng Bum Micheal Yoo
% inquiry about code : Sangkyu Son (ss.sangkyu.son@gmail.com)

%% setup
clear all; close all; clc; warning off
genDir = pwd;                             % Note, change this line into your proper working directory!
utilDir = fullfile(genDir,'/utils');
dataDir = fullfile(genDir,'/data');
addpath(genpath(utilDir))
subj = {'P','S'};
rois = {'RSC','OFC'};

%% Figure 1
drawFigure1C(dataDir,subj); 
drawFigure1D(dataDir,subj);
drawFigure1E(dataDir,subj);
drawFigure1F(dataDir,subj);
drawFigure1G(dataDir,subj);
drawFigure1H(dataDir,subj);
drawFigure1I(dataDir,subj);

%% Figure 2
drawFigure2B(dataDir,subj,rois); 
drawFigure2D(dataDir,subj,rois); 
drawFigure2E(dataDir,subj,rois); 
drawFigure2G(dataDir,subj,rois);

%% Figure 3
drawFigure3B(dataDir,subj); 
drawFigure3C(dataDir,subj,rois);
drawFigure3D(dataDir,subj,rois);

%% Figure 4
drawFigure4A(dataDir,subj,rois);
% drawFigure4C(dataDir,subj); 
% drawFigure4D(dataDir,subj);
% Please request inter areal analysis data for running 4C and 4D (due to size)

%% Extended Data Figures
% drawFigureS1(dataDir,subj); % Note, this will take long for running the ISOMAP algorithm (~20m)
drawFigureS2(dataDir,subj);
drawFigureS3(dataDir,subj);
drawFigureS4C(dataDir,subj,rois);
drawFigureS5(dataDir,subj);
