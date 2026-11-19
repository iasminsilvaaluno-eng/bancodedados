CREATE INDEX idx_rl_0 ON lineitem(l_orderkey);
CREATE INDEX idx_rl_1 ON lineitem(l_partkey);
CREATE INDEX idx_rl_2 ON lineitem(l_suppkey);
CREATE INDEX idx_rl_3 ON lineitem(l_shipdate);
CREATE INDEX idx_rl_4 ON lineitem(l_receiptdate);
CREATE INDEX idx_rl_5 ON lineitem(l_returnflag);
CREATE INDEX idx_rl_6 ON part(p_type);
CREATE INDEX idx_rl_7 ON nation(n_regionkey);
ANALYZE;
