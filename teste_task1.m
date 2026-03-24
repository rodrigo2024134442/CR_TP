% =========================================================================
% teste_task1.m
% Script para testar convert_categoricals.m e fill_missing_inputs.m
% Corre este ficheiro a partir da raiz do projeto
% =========================================================================

clc;        % limpa a consola
clear;      % limpa todas as variáveis
close all;  % fecha todos os gráficos

% Adicionar pastas ao path para o MATLAB encontrar as funções
addpath('datasetfix');
addpath('CRB');
addpath('RN');
addpath('Comparacao');

fprintf('=== TESTE TAREFA 3.1 ===\n\n');

% -------------------------------------------------------------------------
% 1. Ler o dataset original
% -------------------------------------------------------------------------
fprintf('A ler o dataset...\n');
data = readtable('data/dataset_TP.csv', 'TextType', 'string');
fprintf('Dataset lido: %d linhas, %d colunas\n\n', height(data), width(data));

% -------------------------------------------------------------------------
% 2. Mostrar quantos NaN existem ANTES de tratar
% -------------------------------------------------------------------------
fprintf('--- NaN ANTES do tratamento ---\n');
colunas = data.Properties.VariableNames;
for i = 1:length(colunas)
    col = colunas{i};
    if isnumeric(data.(col))
        n_nan = sum(isnan(data.(col)));
        if n_nan > 0
            fprintf('  %-20s : %d valores em falta\n', col, n_nan);
        end
    else
        n_missing = sum(ismissing(data.(col)));
        if n_missing > 0
            fprintf('  %-20s : %d valores em falta (texto)\n', col, n_missing);
        end
    end
end
fprintf('\n');

% -------------------------------------------------------------------------
% 3. Mostrar valores categóricos ANTES de converter
% -------------------------------------------------------------------------
fprintf('--- Categóricos ANTES da conversão ---\n');
fprintf('  maintenance_level (primeiros 5): ');
disp(data.maintenance_level(1:5));
fprintf('  operating_mode (primeiros 5):    ');
disp(data.operating_mode(1:5));
fprintf('  cooling_type (primeiros 5):      ');
disp(data.cooling_type(1:5));
fprintf('  sensor_status (primeiros 5):     ');
disp(data.sensor_status(1:5));

% -------------------------------------------------------------------------
% 4. Converter categóricos
% -------------------------------------------------------------------------
fprintf('A converter categóricos...\n');
data = convert_categoricals(data);
fprintf('Conversão concluída!\n\n');

% -------------------------------------------------------------------------
% 5. Preencher missing values dos inputs
% -------------------------------------------------------------------------
fprintf('A preencher valores em falta nos inputs...\n');
data = fill_missing_inputs(data);
fprintf('Preenchimento concluído!\n\n');

% -------------------------------------------------------------------------
% 6. Mostrar quantos NaN existem DEPOIS de tratar
% -------------------------------------------------------------------------
fprintf('--- NaN DEPOIS do tratamento ---\n');
nan_restantes = 0;
for i = 1:length(colunas)
    col = colunas{i};
    if isnumeric(data.(col))
        n_nan = sum(isnan(data.(col)));
        if n_nan > 0
            fprintf('  %-20s : %d valores em falta\n', col, n_nan);
            nan_restantes = nan_restantes + n_nan;
        end
    end
end
if nan_restantes == 0
    fprintf('  Nenhum NaN encontrado nos atributos de entrada!\n');
end
fprintf('\n');

% -------------------------------------------------------------------------
% 7. Verificar se o target ainda tem missing values
% -------------------------------------------------------------------------
n_target_missing = sum(ismissing(data.class_cat));
fprintf('--- Target (class_cat) ---\n');
fprintf('  Valores em falta no target: %d (serão tratados em fill_missing_target.m)\n\n', n_target_missing);

% -------------------------------------------------------------------------
% 8. Resumo final
% -------------------------------------------------------------------------
fprintf('=== RESUMO ===\n');
fprintf('  Linhas no dataset:         %d\n', height(data));
fprintf('  Colunas no dataset:        %d\n', width(data));
fprintf('  NaN nos inputs:            %d\n', nan_restantes);
fprintf('  Missing values no target:  %d\n\n', n_target_missing);
fprintf('Teste concluído com sucesso!\n');

% -------------------------------------------------------------------------
% 9. Guardar o dataset tratado na pasta results/
% -------------------------------------------------------------------------
fprintf('\nA guardar o dataset tratado...\n');
if ~exist('resultados', 'dir')
    mkdir('resultados');
end
save('resultados/dataset_tratado.mat', 'data');
fprintf('Dataset guardado em results/dataset_tratado.mat\n');
