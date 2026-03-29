function rede = treinar_rede_temperature(data)
% Treina uma rede neuronal feedforward para prever temperature
% Chamada UMA vez antes do ciclo dos casos de teste
% Entradas da rede: vibration, rotation_speed, voltage
% Saída da rede:    temperature

% construir entradas e saídas (formato: atributos x casos)
entradas = [data.vibration, data.rotation_speed, data.voltage]';
saidas   = data.temperature';

% criar rede feedforward com 10 neurónios na camada oculta
rede = feedforwardnet(10);
rede.trainParam.showWindow = false; % desativar janelas de treino

% treinar com os 5000 casos históricos
rede = train(rede, entradas, saidas);

fprintf('Rede neuronal treinada para prever temperature.\n');

end
