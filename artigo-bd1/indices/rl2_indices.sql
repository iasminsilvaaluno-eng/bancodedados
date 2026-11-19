CREATE INDEX idx_rl2_0 ON lineitem(l_orderkey);
CREATE INDEX idx_rl2_1 ON lineitem(l_partkey);
CREATE INDEX idx_rl2_2 ON lineitem(l_suppkey);
CREATE INDEX idx_rl2_3 ON orders(o_orderkey);
CREATE INDEX idx_rl2_4 ON orders(o_custkey);
CREATE INDEX idx_rl2_5 ON orders(o_orderdate);
CREATE INDEX idx_rl2_6 ON partsupp(ps_suppkey);
CREATE INDEX idx_rl2_7 ON partsupp(ps_partkey, ps_suppkey);
ANALYZE;
