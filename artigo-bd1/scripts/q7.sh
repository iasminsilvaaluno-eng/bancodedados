#!/bin/bash
OUT=/opt/q7_investigacao.txt
plano() {
  (echo "$1 EXPLAIN (ANALYZE, BUFFERS)"; cat /opt/queries/q7.sql) | psql -U postgres -d tpch > /dev/null
  (echo "$1 EXPLAIN (ANALYZE, BUFFERS)"; cat /opt/queries/q7.sql) | psql -U postgres -d tpch
}
{
echo "===== 1) COM indices (cenario C) ====="
plano ""
echo "===== 2) COM indices, sem usar scan por indice ====="
plano "SET enable_indexscan=off; SET enable_bitmapscan=off; SET enable_indexonlyscan=off;"
} > $OUT 2>&1
/opt/limpar.sh > /dev/null 2>&1
{
echo "===== 3) SEM indices (baseline) ====="
plano ""
} >> $OUT 2>&1
psql -U postgres -d tpch -f /opt/rl_indices.sql > /dev/null 2>&1
echo "Pronto! Arquivo: $OUT"
