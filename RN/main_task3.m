% =========================================================================
% main_task3.m — Redes Neuronais Feedforward (Tarefa 3.3)
% =========================================================================
% Estrutura:
%   a) Estudo de configurações: 10 repetições por config, registo de médias
%   b) Normalizado vs não normalizado: 3 melhores + 3 piores configs
%   c) Gravar as 3 melhores redes
%   d) Testar as 3 melhores no dataset de teste
% =========================================================================

clc; clear; close all;
addpath(genpath(pwd));

% -------------------------------------------------------------------------
% 0. Carregar e preparar dados
% -------------------------------------------------------------------------
fprintf('=== TAREFA 3.3 — REDES NEURONAIS ===\n\n');
fprintf('A carregar dataset tratado...\n');
load('results/dataset_tratado.mat'); % variável: data

% Classes (ordem fixa — usada em build_targets e test_best_nets)
classes = {'Normal', 'ElectricalFailure', 'MechanicalFailure'};

% Construir X e T (sem normalização)
X = build_inputs(data);
T = build_targets(data);

% Normalizar X (min-max por atributo, target NÃO é normalizado)
X_min  = min(X, [], 2);
X_max  = max(X, [], 2);
intervalo = X_max - X_min;
intervalo(intervalo == 0) = 1; % evitar divisão por zero
X_norm = (X - X_min) ./ intervalo;

fprintf('Dataset: %d casos, %d atributos, %d classes\n\n', ...
        size(X, 2), size(X, 1), size(T, 1));

% -------------------------------------------------------------------------
% a) Estudo de configurações
% -------------------------------------------------------------------------
fprintf('--- a) Estudo de configurações (10 repetições cada) ---\n\n');

% Definir configurações a testar
% Cada linha: {topologia, func_treino, func_ativacao, divisao}
configs = {
    % Topologia default
    [10],      'trainlm',  'softmax',  [70 15 15];
    [10],      'trainbr',  'softmax',  [70 15 15];
    [10],      'traingd',  'softmax',  [70 15 15];
    [10],      'trainscg', 'softmax',  [70 15 15];
    % Mais neurónios
    [20],      'trainlm',  'softmax',  [70 15 15];
    [50],      'trainlm',  'softmax',  [70 15 15];
    % Duas camadas
    [20 10],   'trainlm',  'softmax',  [70 15 15];
    [10 10],   'trainscg', 'softmax',  [70 15 15];
    % Funções de ativação na saída
    [10],      'trainlm',  'tansig',   [70 15 15];
    [10],      'trainlm',  'logsig',   [70 15 15];
    [10],      'trainlm',  'purelin',  [70 15 15];
    % Diferentes divisões
    [10],      'trainlm',  'softmax',  [80 10 10];
    [10],      'trainlm',  'softmax',  [60 20 20];
    [20 10],   'trainscg', 'softmax',  [80 10 10];
    % Combinações extra
    [30 15],   'trainlm',  'softmax',  [70 15 15];
    [20],      'trainbr',  'softmax',  [80 10 10];
};

n_configs = size(configs, 1);
resultados = zeros(n_configs, 2); % col1=media_global, col2=media_teste
top_nets   = {}; % guardar as melhores redes ao longo do estudo

% variáveis para rastrear as 3 melhores e 3 piores
melhores_acc  = [-inf -inf -inf];
melhores_idx  = [0 0 0];
melhores_nets = {[], [], []};
melhores_cfgs = {[], [], []};
piores_acc    = [inf inf inf];
piores_idx    = [0 0 0];

for c = 1:n_configs

    top   = configs{c, 1};
    ft    = configs{c, 2};
    fa    = configs{c, 3};
    div   = configs{c, 4};

    fprintf('Config %2d/%d: top=%-8s treino=%-8s ativ=%-8s div=%s\n', ...
            c, n_configs, mat2str(top), ft, fa, mat2str(div));

    [mg, mt, melhor_net, ~] = train_network(X, T, top, ft, fa, div);

    resultados(c, 1) = mg;
    resultados(c, 2) = mt;

    fprintf('           → Global: %.2f%% | Teste: %.2f%%\n\n', mg, mt);

    % Atualizar as 3 melhores
    [val_min, pos_min] = min(melhores_acc);
    if mt > val_min
        melhores_acc(pos_min)  = mt;
        melhores_idx(pos_min)  = c;
        melhores_nets{pos_min} = melhor_net;
        melhores_cfgs{pos_min} = configs(c, :);
    end

    % Atualizar as 3 piores
    [val_max, pos_max] = max(piores_acc);
    if mt < val_max
        piores_acc(pos_max) = mt;
        piores_idx(pos_max) = c;
    end

end

% Ordenar melhores por acc descendente
[melhores_acc_ord, ord] = sort(melhores_acc, 'descend');
melhores_idx_ord  = melhores_idx(ord);
melhores_nets_ord = melhores_nets(ord);
melhores_cfgs_ord = melhores_cfgs(ord);

% Ordenar piores por acc ascendente
[piores_acc_ord, ord2] = sort(piores_acc, 'ascend');
piores_idx_ord = piores_idx(ord2);

% Mostrar tabela de resultados
fprintf('\n--- Tabela de resultados ---\n');
fprintf('  %-4s %-8s %-8s %-8s %-10s %9s %9s\n', ...
        'Cfg', 'Top', 'Treino', 'Ativ', 'Divisão', 'Global%', 'Teste%');
fprintf('  %s\n', repmat('-', 1, 65));
for c = 1:n_configs
    fprintf('  %-4d %-8s %-8s %-8s %-10s %9.2f %9.2f\n', c, ...
            mat2str(configs{c,1}), configs{c,2}, configs{c,3}, ...
            mat2str(configs{c,4}), resultados(c,1), resultados(c,2));
end

fprintf('\n3 melhores configurações (por acc de teste):\n');
for k = 1:3
    fprintf('  %dº: Config %d — Teste: %.2f%%\n', k, melhores_idx_ord(k), melhores_acc_ord(k));
end
fprintf('\n3 piores configurações (por acc de teste):\n');
for k = 1:3
    fprintf('  %dº: Config %d — Teste: %.2f%%\n', k, piores_idx_ord(k), piores_acc_ord(k));
end

% -------------------------------------------------------------------------
% b) Normalizado vs não normalizado (3 melhores + 3 piores)
% -------------------------------------------------------------------------
fprintf('\n--- b) Normalizado vs Não Normalizado ---\n\n');

idx_comparar = [melhores_idx_ord, piores_idx_ord];
labels = {'Melhor 1', 'Melhor 2', 'Melhor 3', 'Pior 1', 'Pior 2', 'Pior 3'};

res_norm    = zeros(6, 2);
res_nonnorm = zeros(6, 2);

for k = 1:6

    c   = idx_comparar(k);
    top = configs{c, 1};
    ft  = configs{c, 2};
    fa  = configs{c, 3};
    div = configs{c, 4};

    fprintf('%s (Config %d):\n', labels{k}, c);

    % Sem normalização
    [mg_nn, mt_nn, ~, ~] = train_network(X,      T, top, ft, fa, div);
    % Com normalização
    [mg_n,  mt_n,  ~, ~] = train_network(X_norm, T, top, ft, fa, div);

    res_nonnorm(k, :) = [mg_nn, mt_nn];
    res_norm(k, :)    = [mg_n,  mt_n];

    fprintf('  Não normalizado — Global: %.2f%% | Teste: %.2f%%\n', mg_nn, mt_nn);
    fprintf('  Normalizado     — Global: %.2f%% | Teste: %.2f%%\n\n', mg_n,  mt_n);

end

fprintf('Resumo Normalizado vs Não normalizado:\n');
fprintf('  %-10s %14s %14s\n', '', 'Não norm. (%)', 'Norm. (%)');
fprintf('  %s\n', repmat('-', 1, 42));
for k = 1:6
    fprintf('  %-10s  G:%.2f T:%.2f   G:%.2f T:%.2f\n', labels{k}, ...
            res_nonnorm(k,1), res_nonnorm(k,2), res_norm(k,1), res_norm(k,2));
end

% -------------------------------------------------------------------------
% c) Gravar as 3 melhores redes
% -------------------------------------------------------------------------
fprintf('\n--- c) A gravar as 3 melhores redes ---\n');

if ~exist('results', 'dir')
    mkdir('results');
end

for k = 1:3
    net = melhores_nets_ord{k};
    cfg_linha = melhores_cfgs_ord{k};
    config = struct();
    config.topologia    = cfg_linha{1};
    config.func_treino  = cfg_linha{2};
    config.func_ativacao= cfg_linha{3};
    config.divisao      = cfg_linha{4};
    config.acc_teste    = melhores_acc_ord(k);

    nome_ficheiro = sprintf('results/best_net%d.mat', k);
    save(nome_ficheiro, 'net', 'config');
    fprintf('  Rede %d guardada: %s (Teste: %.2f%%)\n', k, nome_ficheiro, melhores_acc_ord(k));
end

% plotconfusion das 3 melhores (dataset completo)
fprintf('\nA gerar plotconfusion das 3 melhores redes...\n');
for k = 1:3
    net = melhores_nets_ord{k};
    Y = net(X);
    figure;
    plotconfusion(T, Y);
    title(sprintf('Melhor Rede %d — Dataset completo (Teste: %.2f%%)', k, melhores_acc_ord(k)));
end

% -------------------------------------------------------------------------
% d) Testar as 3 melhores no dataset de teste externo
% -------------------------------------------------------------------------
fprintf('\n--- d) Teste no dataset_TP_test.csv ---\n');

dados_teste = readtable('data/dataset_TP_test.csv', 'TextType', 'string');
dados_teste = convert_categoricals(dados_teste);

X_test = build_inputs(dados_teste);
T_test = build_targets(dados_teste);

% NOTA: as redes gravadas foram treinadas com X não normalizado (alínea a)
% pelo que o teste usa igualmente X_test sem normalização.
% X_test_norm está disponível caso se queira testar redes treinadas com X_norm.
X_test_norm = (X_test - X_min) ./ intervalo; 

test_best_nets(X_test, T_test, classes);

fprintf('\n=== TAREFA 3.3 CONCLUÍDA ===\n');
