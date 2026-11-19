# Otimização de Índices em Bancos de Dados Relacionais com Aprendizado por Reforço (TPC-H / PostgreSQL 16)

Este repositório contém os scripts, consultas SQL, listas de índices e logs de execução referentes aos experimentos do artigo **"Otimização de índices em bancos de dados relacionais com aprendizado por reforço: revisão e experimentação"** (UNIPAMPA, 2026).

## Conteúdo do Arquivo ('artigo-bd1')

- **`consultas/`**: Conjunto das 22 consultas geradas via `qgen` (`q1.sql` a `q22.sql`, fator de escala 1). 
*Nota: A consulta 'q15.sql' acompanha o conjunto gerado, mas foi excluída das medições experimentais por criar e remover uma visão temporária durante sua execução.*
- **`indices/`**: Scripts SQL ('CREATE INDEX') com as configurações de cada cenário:
  - `manual_indices.sql`: 11 índices definidos manualmente (Cenário B).
  - `rl_indices.sql`: 8 índices selecionados pelo Agente v1 (Cenário C).
  - `rl2_indices.sql`: 8 índices selecionados pelo Agente v2 (Cenário C2).
- **`resultados/`**: Arquivos CSV contendo os tempos individuais (em milissegundos) das 5 repetições cronometradas (após 1 execução de aquecimento) e suas respectivas medianas (`resultados5_*.csv`), a saída completa de `EXPLAIN (ANALYZE, BUFFERS)` da investigação da consulta Q7 (`q7_investigacao.txt`), e a pasta `preliminar/` com a rodada inicial exploratória de 3 repetições (`resultados_*.csv`).
- **`scripts/`**:
  - `rl.py` e `rl2.py`: Implementação em Python 3 (`psycopg2`) dos agentes de Q-learning tabular (v1 com 21 candidatos e 200 episódios; v2 com 26 candidatos e 300 episódios) utilizando índices hipotéticos via `HypoPG`.
  - `medir5.sh` e `medir.sh`: Scripts Bash de execução automatizada com `statement_timeout` de 120 segundos e cálculo da mediana.
  - `limpar.sh`: Script Bash para remoção de todos os índices e execução de `ANALYZE` entre os cenários.
  - `q7.sh` e `idxteste.sh`: Scripts Bash de diagnóstico da regressão de desempenho da consulta Q7 e avaliação isolada da remoção do índice `idx_rl_2`.

## Ambiente de Execução
- **SGBD:** PostgreSQL 16 ('postgres:16' em contêiner Docker) com extensão 'HypoPG 1.4.5'.
- **Benchmark:** TPC-H (`tpch-kit`, `dbgen` e `qgen` com fator de escala 1, 1 GB).
- **Linguagem:** Python 3 com biblioteca `psycopg2`.
