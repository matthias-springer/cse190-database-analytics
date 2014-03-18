CREATE INDEX ON ivm_arv using hash (reader);
CREATE INDEX ON ivm_arv using hash (author);
CREATE INDEX ON ivm_nrv using hash (reader);
CREATE INDEX ON ivm_nrv using hash (nation);

CREATE INDEX ON posts using hash (id);
CREATE INDEX ON posts using btree (author);
CREATE INDEX ON friends using hash (x);
CREATE INDEX ON members using hash (id);
CREATE INDEX ON friends using hash (y);
CREATE INDEX ON members using btree (nation);
