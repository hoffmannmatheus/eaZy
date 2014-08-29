CREATE TABLE IF NOT EXISTS device ( 
    id INTEGER PRIMARY KEY,
    id_device INTEGER NOT NULL,
    name VARCHAR(80) NOT NULL,
    type VARCHAR(80) NOT NULL
); 

CREATE TABLE IF NOT EXISTS scene ( 
    id INTEGER PRIMARY KEY,
    source_device INTEGER NOT NULL,
    source_attr VARCHAR(80) NOT NULL,
    source_value VARCHAR(80) NOT NULL,
    target_device INTEGER NOT NULL,
    target_state VARCHAR(80) NOT NULL
); 
