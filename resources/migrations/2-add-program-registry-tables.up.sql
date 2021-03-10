CREATE TABLE program_packages (name VARCHAR PRIMARY KEY);
CREATE TABLE program_package_files (id UUID PRIMARY KEY, package VARCHAR, relative_path VARCHAR, content TEXT);
