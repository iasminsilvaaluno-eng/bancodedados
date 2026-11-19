#!/bin/bash
declare -A COM SEM
export PGOPTIONS='-c statement_timeout=30000'
med() {
  psql -U postgres -d tpch -q -f /opt/queries/q$1.sql > /dev/null 2>&1
  v=()
  for r in 1 2 3; do
    s=$(date +%s%N)
    psql -U postgres -d tpch -q -f /opt/queries/q$1.sql > /dev/null 2>&1
    v+=($(( ($(date +%s%N) - s) / 1000000 )))
  done
  printf '%s\n' "${v[@]}" | sort -n | sed -n 2p
}
for q in 5 7 8 9 20 21; do COM[$q]=$(med $q); done
psql -U postgres -d tpch -q -c "DROP INDEX idx_rl_2; ANALYZE lineitem;"
for q in 5 7 8 9 20 21; do SEM[$q]=$(med $q); done
psql -U postgres -d tpch -q -c "CREATE INDEX idx_rl_2 ON lineitem(l_suppkey); ANALYZE lineitem;"
echo "consulta,com_idx_rl_2_ms,sem_idx_rl_2_ms"
for q in 5 7 8 9 20 21; do echo "Q$q,${COM[$q]},${SEM[$q]}"; done
