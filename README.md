# Trabalho Prático — Conhecimento e Raciocínio 2025/2026

Licenciatura em Engenharia Informática — 2º ano, 2º semestre  
Instituto Superior de Engenharia — Politécnico de Coimbra

---

## Descrição

Este projeto implementa um sistema de diagnóstico de falhas num motor industrial com base em dois métodos:

- **CBR (Case-Based Reasoning)** — Raciocínio Baseado em Casos
- **Redes Neuronais Feedforward**

O dataset contém 5000 registos com 14 atributos de entrada (numéricos e categóricos) e uma coluna target com 3 classes possíveis: `Normal`, `Electrical Failure` e `Mechanical Failure`.

Todo o código está implementado em **MATLAB**, usando apenas a toolbox Deep Learning para as redes neuronais.

---

## Estrutura do Projeto

```
projeto_CR/
│
├── data/                        # Datasets originais (não modificar)
│   ├── dataset_TP.csv
│   └── dataset_TP_test.csv
│
├── datasetfix/                  # Tarefa 3.1 — Tratamento do dataset
│   ├── main_task1.m
│   ├── convert_categoricals.m
│   ├── fill_missing_inputs.m
│   └── fill_missing_target.m
│
├── CRB/                         # Tarefa 3.2 — Sistema CBR
│   ├── main_task2.m
│   ├── cbr_retrieve.m
│   ├── cbr_reuse.m
│   ├── cbr_revise.m
│   ├── cbr_retain.m
│   └── local_similarity.m
│
├── RN/                          # Tarefa 3.3 — Redes Neuronais
│   ├── main_task3.m
│   ├── build_inputs.m
│   ├── build_targets.m
│   ├── train_network.m
│   └── test_best_nets.m
│
├── Comparacao/                  # Tarefa 3.4 — CBR vs Redes Neuronais
│   └── main_task4.m
│
├── results/                     # Ficheiros gerados pelo código
│   ├── dataset_tratado.mat
│   ├── best_net1.mat
│   ├── best_net2.mat
│   └── best_net3.mat
│
├── main.m                       # Script principal — corre tudo por ordem
└── README.md
```

---

## Tarefas Implementadas

### Tarefa 3.1 — Tratamento do Dataset (`datasetfix/`)
- Conversão de atributos categóricos para numéricos com justificação
- Preenchimento de valores em falta nos atributos de entrada (média/mediana/moda)
- Preenchimento de valores em falta no target via CBR (Retrieve)

### Tarefa 3.2 — Sistema CBR (`CRB/`)
- **Retrieve:** cálculo de distâncias locais e similaridade global
- **Reuse:** rede neuronal feedforward para sugerir valor ajustado de `temperature`
- **Revise:** confirmação pelo utilizador
- **Retain:** adição do novo caso ao dataset
- Testes com diferentes pesos e dataset normalizado vs não normalizado

### Tarefa 3.3 — Redes Neuronais (`RN/`)
- Construção da matriz de entrada e target binário
- Treino e teste de múltiplas configurações (topologia, função de treino, ativação, divisão de dados)
- 10 repetições por configuração
- Gravação das 3 melhores redes

### Tarefa 3.4 — Comparação (`Comparacao/`)
- Análise comparativa entre CBR e Redes Neuronais
- Vantagens e limitações de cada método

---

## Como Correr

Abrir o MATLAB na raiz do projeto e executar:

```matlab
run('main.m')
```

Ou correr cada tarefa individualmente:

```matlab
run('datasetfix/main_task1.m')   % Tarefa 3.1
run('CRB/main_task2.m')          % Tarefa 3.2
run('RN/main_task3.m')           % Tarefa 3.3
run('Comparacao/main_task4.m')   % Tarefa 3.4
```

> **Nota:** A Tarefa 3.1 deve ser sempre executada primeiro, pois gera o `dataset_tratado.mat` usado pelas restantes tarefas.

---

## Requisitos

- MATLAB (versão recomendada: R2022b ou superior)
- Toolbox: Deep Learning Toolbox

---

## Entrega

- **Data limite:** 10 de maio de 2026 às 23:59
- **Formato:** ficheiro ZIP com código MATLAB, ficheiro Excel de resultados e relatório PDF
- **Defesas:** semanas de 11 a 22 de maio de 2026

---

## Autores

| Nome | Número | Turma |
|------|--------|-------|
|      |        |       |
|      |        |       |
