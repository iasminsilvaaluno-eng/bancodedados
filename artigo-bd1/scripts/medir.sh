#!/bin/bash
CEN=$1
OUT=/opt/resultados_$CEN.csv
echo "consulta,exec1_ms,exec2_ms,exec3_ms,mediana_ms" > $OUT
export PGOPTIONS='-c statement_timeout=120000'
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 22; do
  vals=()
  for r in 1 2 3; do
    s=$(date +%s%N)
    psql -U postgres -d tpch -q -v ON_ERROR_STOP=1 -f /opt/queries/q$i.sql > /dev/null 2>&1
    rc=$?
    e=$(( ($(date +%s%N) - s) / 1000000 ))
    if [ $rc -ne 0 ]; then
      if [ $e -ge 119000 ]; then m=TIMEOUT; else m=ERRO; fi
      vals=($m $m $m)
      break
    fi
    vals+=($e)
  done
  if [ "${vals[0]}" = "TIMEOUT" ] || [ "${vals[0]}" = "ERRO" ]; then
    med=${vals[0]}
  else
    med=$(printf '%s\n' "${vals[@]}" | sort -n | sed -n 2p)
  fi
  echo "Q$i,${vals[0]},${vals[1]},${vals[2]},$med" | tee -a $OUT
done
echo "Pronto! Arquivo: $OUT"
