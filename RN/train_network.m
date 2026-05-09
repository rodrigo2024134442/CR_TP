function [media_global, media_teste, melhor_net, melhor_tr] = train_network(X, T, topologia, func_treino, func_ativacao, divisao, params)
% TRAIN_NETWORK — treina e avalia uma configuração de rede (10 repetições)
%
% Descrição:
%   Executa `N_REP` repetições de treino com a mesma configuração para
%   reduzir ruído estatístico. Para cada repetição treina uma rede, calcula
%   métricas no conjunto completo e no subconjunto de teste, e guarda a
%   melhor rede segundo a precisão no teste.
%
% Entradas:
%   X            — matriz de entrada [14 x N]
%   T            — matriz target one-hot [3 x N]
%   topologia    — vetor com nº de neurónios por camada (ex: [10] or [20 10])
%   func_treino  — algoritmo de treino ('trainlm', 'trainbr', 'traingd', 'trainscg')
%   func_ativacao— função de ativação para a camada de saída ('softmax','tansig',...)
%   divisao      — vector [treino val teste] em percentagem (ex.: [70 15 15])
%
% Saídas:
%   media_global — média da precisão global nas N_REP execuções (%)
%   media_teste  — média da precisão apenas no conjunto de teste (%)
%   melhor_net   — objeto rede com melhor desempenho (segundo acc no teste)
%   melhor_tr    — estrutura de treino associada à `melhor_net`

% Nota didática: ao usar `trainbr` pode não existir divisão de treino/teste
% interna (tr.testInd vazio). O código trata esse caso usando todo o dataset
% como aproximação quando necessário.

% `params` (opcional) — struct com hiperparâmetros, e.g.:
%   params.lr     - learning rate (ex.: 0.01)
%   params.epochs - número máximo de épocas (ex.: 500)

if nargin < 7
    params = struct();
end

    % Número de repetições (para reduzir variabilidade)
    N_REP = 10;

    % Vetores para guardar as precisões em cada repetição
    precisoes_global = zeros(1, N_REP);
    precisoes_teste  = zeros(1, N_REP);

    % Variáveis para guardar a melhor rede encontrada
    melhor_net = [];
    melhor_tr  = [];
    melhor_acc = -1; % inicialização com valor baixo

    % Loop principal (treinar várias vezes a rede)
    for rep = 1:N_REP

        % --- Criar rede neuronal ---
        % patternnet → rede para classificação
        net = patternnet(topologia, func_treino);

        % --- Definir função de ativação na camada de saída ---
        % Por defeito é 'softmax', só altera se for diferente
        if ~strcmp(func_ativacao, 'softmax')
            net.layers{end}.transferFcn = func_ativacao;
        end

        % --- Divisão dos dados (treino / validação / teste) ---
        net.divideParam.trainRatio = divisao(1) / 100;
        net.divideParam.valRatio   = divisao(2) / 100;
        net.divideParam.testRatio  = divisao(3) / 100;

        % --- Parâmetros de treino ---
        net.trainParam.showWindow = false; % desativa interface gráfica
        % epochs e learning rate podem ser substituídos por `params`
        if isfield(params, 'epochs')
            net.trainParam.epochs = params.epochs;
        else
            net.trainParam.epochs = 500;
        end
        if isfield(params, 'lr')
            % Nem todos os algoritmos usam explicitamente lr, mas definir
            % não causa erro (será ignorado quando inaplicável).
            net.trainParam.lr = params.lr;
        end
        net.trainParam.max_fail   = 10;    % early stopping (validação)

        % --- Treinar a rede ---
        [net, tr] = train(net, X, T);

        % --- Avaliação GLOBAL (todo o dataset) ---
        Y = net(X); % saídas da rede
        [~, pred] = max(Y, [], 1); % classe prevista
        [~, real] = max(T, [], 1); % classe real

        % cálculo da precisão (%)
        acc_global = 100 * sum(pred == real) / length(real);
        precisoes_global(rep) = acc_global;

        % --- Avaliação no conjunto de TESTE ---
        % Nota: 'trainbr' não separa dados → testInd vazio
        idx_teste = tr.testInd;

        if isempty(idx_teste)
            % Caso especial (ex: trainbr)
            % Usa todo o dataset como aproximação
            Y_teste = net(X);
            T_teste = T;
        else
            % Usa apenas os índices de teste
            Y_teste = net(X(:, idx_teste));
            T_teste = T(:, idx_teste);
        end

        % classes previstas vs reais
        [~, pred_t] = max(Y_teste, [], 1);
        [~, real_t] = max(T_teste, [], 1);

        % precisão no teste (%)
        acc_teste = 100 * sum(pred_t == real_t) / length(real_t);
        precisoes_teste(rep) = acc_teste;

        % --- Guardar a melhor rede ---
        % Critério: maior precisão no conjunto de teste
        if acc_teste > melhor_acc
            melhor_acc = acc_teste;
            melhor_net = net;
            melhor_tr  = tr;
        end

    end

    % --- Resultados finais (médias) ---
    media_global = mean(precisoes_global);
    media_teste  = mean(precisoes_teste);

end