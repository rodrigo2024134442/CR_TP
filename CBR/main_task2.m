clc;
clear;

addpath(genpath(pwd));

load('results/dataset_tratado.mat'); % variável: data

fprintf('--- CBR START ---\n');

% novo caso (exemplo: primeiro registo)
novo_caso = data(1,:);

% REMOVE TARGET para simular problema
novo_caso.target = missing;

% 1. RETRIEVE
[idx, sim] = cbr_retrieve(novo_caso, data);

% 2. REUSE
solucao = cbr_reuse(data(idx,:));

% 3. REVISE
solucao_final = cbr_revise(solucao);

% 4. RETAIN
data = cbr_retain(data, novo_caso, solucao_final);

fprintf('Resultado final: %s\n', string(solucao_final));
fprintf('--- CBR END ---\n');