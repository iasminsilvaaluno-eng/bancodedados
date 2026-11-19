import psycopg2, random, time

conn = psycopg2.connect("dbname=tpch user=postgres")
conn.autocommit = True
cur = conn.cursor()

QUERIES = [open(f"/opt/queries/q{i}.sql").read()
           for i in list(range(1, 15)) + list(range(16, 23))]

CANDS = [
    ("lineitem", "l_orderkey"), ("lineitem", "l_partkey"), ("lineitem", "l_suppkey"),
    ("lineitem", "l_shipdate"), ("lineitem", "l_receiptdate"), ("lineitem", "l_commitdate"),
    ("lineitem", "l_returnflag"), ("lineitem", "l_shipmode"), ("lineitem", "l_partkey, l_suppkey"),
    ("orders", "o_orderkey"), ("orders", "o_custkey"), ("orders", "o_orderdate"), ("orders", "o_orderstatus"),
    ("customer", "c_custkey"), ("customer", "c_nationkey"), ("customer", "c_mktsegment"),
    ("supplier", "s_suppkey"), ("supplier", "s_nationkey"),
    ("partsupp", "ps_partkey"), ("partsupp", "ps_suppkey"), ("partsupp", "ps_partkey, ps_suppkey"),
    ("part", "p_partkey"), ("part", "p_brand"), ("part", "p_type"), ("part", "p_size"),
    ("nation", "n_regionkey"),
]

cache = {}
def avaliar(cfg):
    """Devolve (lista de custos estimados, um por consulta; tamanho dos índices)."""
    if cfg in cache:
        return cache[cfg]
    cur.execute("SELECT hypopg_reset()")
    tamanho = 0
    for i in cfg:
        t, c = CANDS[i]
        cur.execute(f"SELECT indexrelid FROM hypopg_create_index('CREATE INDEX ON {t}({c})')")
        oid = cur.fetchone()[0]
        cur.execute("SELECT hypopg_relation_size(%s)", (oid,))
        tamanho += cur.fetchone()[0]
    custos = []
    for q in QUERIES:
        cur.execute("EXPLAIN (FORMAT JSON) " + q)
        custos.append(cur.fetchone()[0][0]["Plan"]["Total Cost"])
    cache[cfg] = (custos, tamanho)
    return cache[cfg]

base, _ = avaliar(frozenset())

def melhora_media(antes, depois):
    """Média da melhora percentual de CADA consulta (todas pesam igual)."""
    return sum((a - b) / bq for a, b, bq in zip(antes, depois, base)) / len(base)

EPISODIOS = 300
K = 8
ALFA, GAMA = 0.1, 0.9
LAMBDA = 0.1      # penalidade por espaço (por GB)
Q = {}
inicio = time.time()

for ep in range(EPISODIOS):
    eps = max(0.05, 0.5 * (1 - ep / EPISODIOS))
    s = frozenset()
    for passo in range(K):
        acoes = [a for a in range(len(CANDS)) if a not in s]
        if random.random() < eps:
            a = random.choice(acoes)
        else:
            a = max(acoes, key=lambda x: Q.get((s, x), 0))
        s2 = s | {a}
        c1, t1 = avaliar(s)
        c2, t2 = avaliar(s2)
        r = melhora_media(c1, c2) - LAMBDA * (t2 - t1) / 1e9
        if passo == K - 1:
            melhor = 0
        else:
            prox = [x for x in range(len(CANDS)) if x not in s2]
            melhor = max(Q.get((s2, x), 0) for x in prox)
        antigo = Q.get((s, a), 0)
        Q[(s, a)] = antigo + ALFA * (r + GAMA * melhor - antigo)
        s = s2
    if (ep + 1) % 30 == 0:
        print(f"episódio {ep+1}/{EPISODIOS}  ({time.time()-inicio:.0f}s)", flush=True)

s = frozenset()
for _ in range(K):
    acoes = [a for a in range(len(CANDS)) if a not in s]
    s = s | {max(acoes, key=lambda x: Q.get((s, x), 0))}

custos, tam = avaliar(s)
print("\n=== Índices escolhidos pelo agente (versão 2) ===")
with open("/opt/rl2_indices.sql", "w") as f:
    for n, i in enumerate(sorted(s)):
        t, c = CANDS[i]
        cmd = f"CREATE INDEX idx_rl2_{n} ON {t}({c});"
        print(cmd)
        f.write(cmd + "\n")
    f.write("ANALYZE;\n")
print(f"\nMelhora média por consulta (custo estimado): {100*melhora_media(base, custos):.1f}%")
print(f"Espaço estimado dos índices: {tam/1e6:.0f} MB")
