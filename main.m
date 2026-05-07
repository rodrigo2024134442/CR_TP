clc;
clear;

addpath(genpath(pwd));

disp('--- Tarefa 3.1: Tratamento do Dataset ---');
run('datasetfix/main_task1.m');

disp('--- Tarefa 3.2a: Sistema CBR ---');
run('CBR/main_task2.m');

disp('--- Tarefa 3.2b: Análise de Pesos CBR ---');
run('CBR/main_task2_weights_analysis.m');

disp('--- Tarefa 3.3: Redes Neuronais ---');
run('RN/main_task3.m');

disp('--- Tarefa 3.4: Comparação CBR vs RN ---');
run('Comparacao/main_task4.m');

disp('--- Execução completa ---');