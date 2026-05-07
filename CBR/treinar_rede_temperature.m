function rede = treinar_rede_temperature(data)
% TREINAR_REDE_TEMPERATURE Treina uma rede neuronal feedforward para prever temperature
%
% Entrada:
%   data — tabela com os dados já tratados
%
% Saída:
%   rede — rede neuronal treinada para regressão de temperature
%
% A rede usa como entradas:
%   vibration, rotation_speed e voltage
% e como saída:
%   temperature

    % Garantir que a tabela tem os campos necessários
    campos = {'temperature', 'vibration', 'rotation_speed', 'voltage'};
    for i = 1:numel(campos)
        if ~ismember(campos{i}, data.Properties.VariableNames)
            error('A coluna "%s" não existe na tabela de entrada.', campos{i});
        end
    end

    % Construir matriz de entrada e target
    X = [data.vibration'; data.rotation_speed'; data.voltage'];
    T = data.temperature';

    % Reprodutibilidade
    rng(1);

    % Rede feedforward simples para regressão
    rede = fitnet(10, 'trainscg');

    % Desativar janela gráfica durante o treino
    rede.trainParam.showWindow = false;
    rede.trainParam.epochs = 500;
    rede.trainParam.max_fail = 10;

    % Divisão dos dados
    rede.divideParam.trainRatio = 0.70;
    rede.divideParam.valRatio   = 0.15;
    rede.divideParam.testRatio  = 0.15;

    % Pré-processamento padrão
    rede.inputs{1}.processFcns = {'removeconstantrows', 'mapminmax'};
    rede.outputs{2}.processFcns = {'removeconstantrows', 'mapminmax'};

    % Treino
    rede = train(rede, X, T);

    fprintf('Rede neuronal treinada para prever temperature.\n');
end
