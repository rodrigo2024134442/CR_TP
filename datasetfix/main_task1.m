
% main_task1.m
% Script para os 3 ficheiros do datasetfix:
%   - convert_categoricals.m
%   - fill_missing_inputs.m
%   - fill_missing_target.m


clc;
clear;
close all;

% adicionar pastas ao path para o MATLAB encontrar as funções
addpath('datasetfix');
addpath("results\");

fprintf('=== TAREFA 3.1 ===\n\n');


% Ler o dataset original
fprintf('A ler o dataset...\n');
data = readtable('data/dataset_TP.csv', 'TextType', 'string');
fprintf('Dataset lido: %d linhas, %d colunas\n\n', height(data), width(data));


% 2. Contar NaN e missing ANTES de tratar
fprintf('--- Valores em falta ANTES do tratamento ---\n');
colunas = data.Properties.VariableNames;
for i = 1:length(colunas)
    col = colunas{i};
    if isnumeric(data.(col))
        n = sum(isnan(data.(col)));
        if n > 0
            fprintf('  %-20s : %d NaN\n', col, n);
        end
    else
        n = sum(ismissing(data.(col)));
        if n > 0
            fprintf('  %-20s : %d missing\n', col, n);
        end
    end
end
fprintf('\n');


% Converter categóricos
fprintf('A converter categóricos...\n');
data = convert_categoricals(data);
fprintf('Conversão concluída!\n\n');


% Preencher missing values dos inputs
fprintf('A preencher valores em falta nos inputs...\n');
data = fill_missing_inputs(data);
fprintf('Preenchimento dos inputs concluído!\n\n');


% Verificar NaN nos inputs depois de tratar
fprintf('--- NaN nos inputs DEPOIS do tratamento ---\n');
nan_inputs = 0;
for i = 1:length(colunas)
    col = colunas{i};
    if isnumeric(data.(col))
        n = sum(isnan(data.(col)));
        if n > 0
            fprintf('  %-20s : %d NaN\n', col, n);
            nan_inputs = nan_inputs + n;
        end
    end
end
if nan_inputs == 0
    fprintf('  Nenhum NaN nos inputs!\n');
end
fprintf('\n');


% Mostrar quantos missing no target ANTES do fill_missing_target

n_antes = sum(ismissing(data.class_cat));
fprintf('--- Target ANTES do fill_missing_target ---\n');
fprintf('  Missing values no target: %d\n\n', n_antes);


% Preencher missing values do target com CBR
fprintf('A preencher valores em falta no target (CBR)...\n');
fprintf('  (pode demorar alguns minutos)\n');
data = fill_missing_target(data);
fprintf('\n');


% Verificar target depois de preencher
n_depois = sum(ismissing(data.class_cat));
fprintf('--- Target DEPOIS do fill_missing_target ---\n');
fprintf('  Missing values no target: %d\n\n', n_depois);


% Mostrar distribuição das classes no target
fprintf('--- Distribuição das classes ---\n');
classes = {'Normal', 'ElectricalFailure', 'MechanicalFailure'};
for i = 1:length(classes)
    n = sum(data.class_cat == classes{i});
    fprintf('  %-25s : %d registos (%.1f%%)\n', classes{i}, n, 100*n/height(data));
end
fprintf('\n');


% Resumo final
fprintf('=== RESUMO ===\n');
fprintf('  Linhas no dataset:        %d\n', height(data));
fprintf('  NaN nos inputs:           %d\n', nan_inputs);
fprintf('  Missing no target antes:  %d\n', n_antes);
fprintf('  Missing no target depois: %d\n\n', n_depois);

% Guardar o dataset tratado na pasta results/
fprintf('\nA guardar o dataset tratado...\n');
if ~exist('results', 'dir')
    mkdir('results');
end
save('results/dataset_tratado.mat', 'data');
fprintf('Dataset guardado em results/dataset_tratado.mat\n');
