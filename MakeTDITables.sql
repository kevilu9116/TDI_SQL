CREATE TABLE Genes
(
	gene_id int NOT NULL AUTO_INCREMENT,
	gene_name varchar(50),
	reference varchar(300),
	chromosome varchar(10),
	start_pos bigint,
	end_pos bigint,
	cytoband varchar(50),
	PRIMARY KEY (gene_id),
	UNIQUE (gene_name)
);

CREATE TABLE Exp_Platforms
(
	platform_id int NOT NULL AUTO_INCREMENT,
	-- data_type enum('', 'CNA')
	manufacturer varchar(200),
	platform varchar(200),
	PRIMARY KEY (platform_id)
);

CREATE TABLE Experiments
(
	exp_id int NOT NULL AUTO_INCREMENT,
	model varchar(100),
	description varchar(300),
	parameter_set varchar(300),
	name varchar(100),
	exp_date date,
	PRIMARY KEY (exp_id)
);

CREATE TABLE Cancer_Types
(
	cancer_type_id int NOT NULL AUTO_INCREMENT,
	cancer_name varchar(300) NOT NULL,
	abbv varchar(10),
	PRIMARY KEY (cancer_type_id),
	UNIQUE (abbv)
);

CREATE TABLE Patients
(
	patient_id int NOT NULL AUTO_INCREMENT,
	name varchar(100),
	age int,
	diag varchar(200),
	survival int,
	stage varchar(50),
	death enum('0', '1'),
	cancer_type_id int,
	PRIMARY KEY (patient_id),
	FOREIGN KEY (cancer_type_id) REFERENCES Cancer_Types(cancer_type_id) ON DELETE CASCADE,
	UNIQUE (name)
);

CREATE TABLE SGA_Unit_Group
(
	group_id int NOT NULL AUTO_INCREMENT,
	name varchar(30),
	cancer_type_id int,
	members varchar(500),
	unit_group_flag enum('1', '2'),
	PRIMARY KEY (group_id),
	FOREIGN KEY (cancer_type_id) REFERENCES Cancer_Types(cancer_type_id) ON DELETE CASCADE,
	UNIQUE (name)
);

CREATE TABLE Gene_Group_XRef
(
	gene_id int NOT NULL,
	group_id int NOT NULL,
	PRIMARY KEY (gene_id),
	FOREIGN KEY (gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE,
	FOREIGN KEY (group_id) REFERENCES SGA_Unit_Group(group_id) ON DELETE CASCADE
);

-- CREATE TABLE Somatic_Mutations
-- (
-- 	sm_id int NOT NULL AUTO_INCREMENT,
-- 	patient_id int,
-- 	gene_id int,
-- 	tissue enum('T', 'N'),
-- 	aa_loc_start int,
-- 	aa_loc_end int,
-- 	ref_val varchar(10),
-- 	tumor_val varchar(10),
-- 	start_pos int,
-- 	end_pos int,
-- 	aa_change varchar(30),
-- 	transcript varchar(50),
-- 	-- sample_val_1 varchar(10),
-- 	-- sample_val_2 varchar(10),
-- 	mut_type varchar(50),
-- 	PRIMARY KEY (sm_id),
-- 	FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
-- 	FOREIGN KEY (gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE
-- );

CREATE TABLE Somatic_Mutations
(
	sm_id int NOT NULL AUTO_INCREMENT,
	patient_id int,
	gene_id int,
	tissue enum('T', 'N'),
	ref_val varchar(10),
	tumor_val varchar(10),
	start_pos int,
	end_pos int,
	aa_loc int,
	aa_norm varchar(10),
	aa_mut varchar(10),
	transcript varchar(50),
	mut_type varchar(50),
	PRIMARY KEY (sm_id),
	FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
	FOREIGN KEY (gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE
);

CREATE TABLE SCNAs
(
	scna_id int NOT NULL AUTO_INCREMENT,
	patient_id int,
	gene_id int,
	tissue enum('T', 'N'),
	gistic_score int,
	platform_id int,
	PRIMARY KEY (scna_id),
	FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
	FOREIGN KEY (gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE,
	FOREIGN KEY (platform_id) REFERENCES Exp_Platforms(platform_id) ON DELETE CASCADE
);

CREATE TABLE SGAs
(
	sga_id int NOT NULL AUTO_INCREMENT,
	patient_id int,
	gene_id int,
	source_sm_id int,
	source_scna_id int,
	source_sga_unit int,
	PRIMARY KEY (sga_id),
	FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
	FOREIGN KEY (gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE,
	FOREIGN KEY (source_sm_id) REFERENCES Somatic_Mutations(sm_id) ON DELETE CASCADE,
	FOREIGN KEY (source_scna_id) REFERENCES SCNAs(scna_id) ON DELETE CASCADE,
	FOREIGN KEY (source_sga_unit) REFERENCES SGA_Unit_Group(group_id) ON DELETE CASCADE
);

CREATE TABLE DEGs
(
	deg_id int NOT NULL AUTO_INCREMENT,
	patient_id int NOT NULL,
	gene_id int NOT NULL,
	sample_type enum('T', 'N'),
	platform_id int,
	value enum('-1', '1'),
	PRIMARY KEY (deg_id),
	FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
	FOREIGN KEY (gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE,
	FOREIGN KEY (platform_id) REFERENCES Exp_Platforms(platform_id) ON DELETE CASCADE
);

CREATE TABLE TDI_Results
(
	tdi_id int NOT NULL AUTO_INCREMENT,
	patient_id int NOT NULL,
	gt_gene_id int,
	gt_unit_group_id int,
	ge_gene_id int,
	posterior float,
	exp_id int,
	PRIMARY KEY (tdi_id),
	FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
	FOREIGN KEY (gt_gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE,
	FOREIGN KEY (ge_gene_id) REFERENCES Genes(gene_id) ON DELETE CASCADE,
	FOREIGN KEY (exp_id) REFERENCES Experiments(exp_id) ON DELETE CASCADE,
	FOREIGN KEY (gt_unit_group_id) REFERENCES SGA_Unit_Group(group_id) ON DELETE CASCADE
);

CREATE VIEW TDI_SM
AS 
	SELECT gt_gene_id, ge_gene_id, start_pos, TDI_Results.patient_id
	FROM TDI_Results JOIN Somatic_Mutations ON TDI_Results.gt_gene_id = Somatic_Mutations.gene_id AND Somatic_Mutations.patient_id = TDI_Results.patient_id;

CREATE VIEW TDI_SCNA
AS
	SELECT gt_gene_id, ge_gene_id, TDI_Results.patient_id, gistic_score
	FROM TDI_Results JOIN SCNAs ON TDI_Results.gt_gene_id = SCNAs.gene_id AND TDI_Results.patient_id = SCNAs.patient_id;


