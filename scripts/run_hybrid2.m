addpath ../imports/classes;
addpath ../imports/functions;
rng('shuffle');

constants.nc = 60;
constants.popMax = 500;
constants.eliteMax = 120;
constants.mcProb = 0.15;
constants.survival = 30;

constants.nn = 30;
constants.f1 = 0.2;
constants.dataNoise = 0.03;
constants.nmax = 50;
constants.verb=1;

locations{1} = Location('Injection well, r=0.2m',[0.2]);
locations{2} = Location('Observation well, r=100m',[100]);
locations{3} = Location('Observation well, r=1000m',[1000]);

instruments{1} = Instrument('Pressure','p','Pa');
instruments{2} = Instrument('Displacement','d','mm');

times{1} = Times(logspace(-2,log10(3600*6),100),'s');

domains{1} = Domain('1d',[0 NaN]);

parameters{1} = Parameter('Pumping rate','Q','m^3/s');
parameters{2} = Parameter('Screened interval','h','m');
parameters{3} = Parameter('Poisson ratio','nu','');
parameters{4} = Parameter('log10 Permeability','logk','m^2');
parameters{5} = Parameter('Loading efficiency','gamma','');
parameters{6} = Parameter('Diffusion coeffecient','D','m^2/s');

objectives{1}  = Objective( locations{1}, instruments{1}, times{1}, 1.0, constants.dataNoise);
objectives{2}  = Objective( locations{1}, instruments{2}, times{1}, 1.0, constants.dataNoise);
%objectives{3}  = Objective( locations{2}, instruments{1}, times{1}, 1.0, constants.dataNoise);
%objectives{4}  = Objective( locations{2}, instruments{2}, times{1}, 1.0, constants.dataNoise);
%objectives{5}  = Objective( locations{3}, instruments{1}, times{1}, 1.0, constants.dataNoise);
%objectives{6}  = Objective( locations{3}, instruments{2}, times{1}, 1.0, constants.dataNoise);

decisions{1}  = Decision( domains{1}, parameters{1}, makedist('normal',1e-3,0.5e-3),       [0.5e-3 1.5e-3], 0.5e-3 );
decisions{2}  = Decision( domains{1}, parameters{2}, makedist('normal',100,40),            [40 140],        2.0 );
decisions{3}  = Decision( domains{1}, parameters{3}, makedist('normal',1e-3,0.5e-3),       [0.5e-3 1.5e-3], 1e-5 );
decisions{4}  = Decision( domains{1}, parameters{4}, makedist('normal',log10(1.02e-13),2), [-15 -11],       0.15 );
decisions{5}  = Decision( domains{1}, parameters{5}, makedist('normal',0.370,0.2),         [0 1],           0.05 );
decisions{6}  = Decision( domains{1}, parameters{6}, makedist('normal',0.814,0.2),         [0 5],           0.05 );

decisions{1}  = Decision( domains{1}, parameters{1}, makedist('normal',1e-3,0),            [0.5e-3 1.5e-3], 0 );
decisions{2}  = Decision( domains{1}, parameters{2}, makedist('normal',100,0),             [40 140],        0 );
decisions{3}  = Decision( domains{1}, parameters{3}, makedist('normal',1e-3,0),            [0.5e-3 1.5e-3], 0 );
decisions{4}  = Decision( domains{1}, parameters{4}, makedist('normal',log10(1.02e-13),2), [-15 -11],       0.15 );
decisions{5}  = Decision( domains{1}, parameters{5}, makedist('normal',0.370,0.2),         [0 1],           0.05 );
decisions{6}  = Decision( domains{1}, parameters{6}, makedist('normal',0.814,0),           [0 5],           0 );

trueSample{1}{1}  = Sample( decisions{1}, 1e-3 );
trueSample{1}{2}  = Sample( decisions{2}, 100 );
trueSample{1}{3}  = Sample( decisions{3}, 0.001 );
trueSample{1}{4}  = Sample( decisions{4}, log10(1.02e-13) );
trueSample{1}{5}  = Sample( decisions{5}, 0.379 );
trueSample{1}{6}  = Sample( decisions{6}, 0.814 );
trueData = forwardModel(trueSample,objectives);
trueSolution = Solution(trueSample{1},trueData{1});
objectives{1}.weight = 1.0 / var(trueData{1}{1}.predicted);
objectives{2}.weight = 1.0 / var(trueData{1}{2}.predicted);

opt1 = Optimization(objectives,decisions,trueSolution.realizations,constants,1);
opt1.sga(1);
%opt1.assignParetoDominance;
%opt1.updatePareto;

%{
opt2 = Optimization(objectives,decisions,trueSolution.realizations,constants);
opt2.mcmc(2999);
opt2.assignParetoDominance;
opt2.updatePareto;

opt3 = Optimization(objectives,decisions,trueSolution.realizations,constants);
opt3.sga(2999);
opt3.assignParetoDominance;
opt3.updatePareto;

opt4 = Optimization(objectives,decisions,trueSolution.realizations,constants);
opt4.vega(2999);
opt4.assignParetoDominance;
opt4.updatePareto;

opt5 = Optimization(objectives,decisions,trueSolution.realizations,constants);
opt5.moga(2999);
opt5.assignParetoDominance;
opt5.updatePareto;
%}

%plotComparison(opt1,opt2,opt3,opt4,opt5,'../frames/comparison_',1,2,1,3000);
%save('../data/results-mcmc.mat','opt1','opt2','opt3','opt4','opt5','trueSolution');
