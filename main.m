clc;
clear;

addpath(genpath(pwd));

disp('--- Tarefa 3.1: Tratamento do Dataset ---');
run('datasetfix/main_task1.m');

disp('--- Tarefa 3.2: CBR ---');
run('CRB/main_task2.m');

disp('--- Tarefa 3.3: Redes Neuronais ---');
%run('RN/main_task3.m');

disp('--- Tarefa 3.4: Comparação ---');
%run('Comparacao/main_task4.m');

disp('--- Execução completa ---');