-- MySQL dump 8.22
--
-- Host: localhost    Database: palabra
---------------------------------------------------------
-- Server version	3.23.54

--
-- Table structure for table 'allowed_tags'
--

CREATE TABLE allowed_tags (
  id int(11) NOT NULL auto_increment,
  tag varchar(10) NOT NULL default '',
  PRIMARY KEY  (id),
  UNIQUE KEY tag (tag)
) TYPE=MyISAM;

--
-- Dumping data for table 'allowed_tags'
--


INSERT INTO allowed_tags VALUES (1,'br');
INSERT INTO allowed_tags VALUES (2,'dd');
INSERT INTO allowed_tags VALUES (3,'dl');
INSERT INTO allowed_tags VALUES (4,'dt');
INSERT INTO allowed_tags VALUES (5,'em');
INSERT INTO allowed_tags VALUES (6,'h1');
INSERT INTO allowed_tags VALUES (7,'h2');
INSERT INTO allowed_tags VALUES (8,'h3');
INSERT INTO allowed_tags VALUES (9,'h4');
INSERT INTO allowed_tags VALUES (10,'h5');
INSERT INTO allowed_tags VALUES (11,'h6');
INSERT INTO allowed_tags VALUES (12,'h7');
INSERT INTO allowed_tags VALUES (13,'li');
INSERT INTO allowed_tags VALUES (14,'ol');
INSERT INTO allowed_tags VALUES (15,'p');
INSERT INTO allowed_tags VALUES (16,'strong');
INSERT INTO allowed_tags VALUES (17,'table');
INSERT INTO allowed_tags VALUES (18,'td');
INSERT INTO allowed_tags VALUES (19,'tr');
INSERT INTO allowed_tags VALUES (20,'ul');

--
-- Table structure for table 'ca_ES'
--

CREATE TABLE ca_ES (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'ca_ES'
--



--
-- Table structure for table 'da_DK'
--

CREATE TABLE da_DK (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'da_DK'
--



--
-- Table structure for table 'de_DE'
--

CREATE TABLE de_DE (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'de_DE'
--


INSERT INTO de_DE VALUES (1,'kategorisch','de_DE','<h1>kategorisch</h1>\r\n<p><em>Adj</em></p>\r\n<p>Bedeutung</p>');
INSERT INTO de_DE VALUES (2,'katagorisch','de_DE','<h1>kategorisch</h1>\r\n<p><em>Adj</em></p>\r\nBedeutung<br>\r\nHallo');
INSERT INTO de_DE VALUES (3,'Hallo','de_DE',NULL);
INSERT INTO de_DE VALUES (4,'Tüte','de_DE',NULL);
INSERT INTO de_DE VALUES (5,'äüö','de_DE',NULL);

--
-- Table structure for table 'en_US'
--

CREATE TABLE en_US (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'en_US'
--


INSERT INTO en_US VALUES (1,'Hello','en_US','oi');
INSERT INTO en_US VALUES (2,'hello','en_US','<h1><em>hello</em></h1>');
INSERT INTO en_US VALUES (3,'HELLE','en_US',NULL);
INSERT INTO en_US VALUES (4,'HALLE','en_US','HAHA');
INSERT INTO en_US VALUES (5,'ashes','en_US',NULL);
INSERT INTO en_US VALUES (6,'we','en_US','<h1>we</h1>');
INSERT INTO en_US VALUES (7,'Iraq','en_US',NULL);
INSERT INTO en_US VALUES (8,'helle','en_US',NULL);
INSERT INTO en_US VALUES (9,'hint','en_US',NULL);
INSERT INTO en_US VALUES (10,'hour','en_US',NULL);
INSERT INTO en_US VALUES (11,'house','en_US',NULL);
INSERT INTO en_US VALUES (12,'him','en_US',NULL);
INSERT INTO en_US VALUES (13,'his','en_US',NULL);
INSERT INTO en_US VALUES (14,'her','en_US',NULL);
INSERT INTO en_US VALUES (15,'he','en_US',NULL);
INSERT INTO en_US VALUES (16,'hell','en_US',NULL);
INSERT INTO en_US VALUES (17,'high','en_US',NULL);
INSERT INTO en_US VALUES (18,'highway','en_US',NULL);
INSERT INTO en_US VALUES (19,'history','en_US',NULL);
INSERT INTO en_US VALUES (20,'heart','en_US',NULL);
INSERT INTO en_US VALUES (21,'hand','en_US',NULL);
INSERT INTO en_US VALUES (22,'helmet','en_US',NULL);

--
-- Table structure for table 'es_ES'
--

CREATE TABLE es_ES (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'es_ES'
--


INSERT INTO es_ES VALUES (1,'Hola','es_ES',NULL);
INSERT INTO es_ES VALUES (2,'hola','es_ES',NULL);
INSERT INTO es_ES VALUES (3,'corazón','es_ES',NULL);
INSERT INTO es_ES VALUES (4,'hallö','es_ES',NULL);

--
-- Table structure for table 'eu_ES'
--

CREATE TABLE eu_ES (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'eu_ES'
--


INSERT INTO eu_ES VALUES (1,'öäü','eu_ES',NULL);

--
-- Table structure for table 'fi_FI'
--

CREATE TABLE fi_FI (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'fi_FI'
--



--
-- Table structure for table 'fr_FR'
--

CREATE TABLE fr_FR (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'fr_FR'
--



--
-- Table structure for table 'hr_HR'
--

CREATE TABLE hr_HR (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'hr_HR'
--



--
-- Table structure for table 'hu_HU'
--

CREATE TABLE hu_HU (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'hu_HU'
--



--
-- Table structure for table 'id_ID'
--

CREATE TABLE id_ID (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'id_ID'
--



--
-- Table structure for table 'is_IS'
--

CREATE TABLE is_IS (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'is_IS'
--


INSERT INTO is_IS VALUES (1,'w','is_IS',NULL);

--
-- Table structure for table 'it_IT'
--

CREATE TABLE it_IT (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'it_IT'
--



--
-- Table structure for table 'languages'
--

CREATE TABLE languages (
  id int(11) NOT NULL auto_increment,
  lang_code varchar(5) NOT NULL default '',
  lang_name varchar(255) NOT NULL default '',
  PRIMARY KEY  (id),
  UNIQUE KEY lang_name (lang_name),
  UNIQUE KEY lang_code (lang_code)
) TYPE=MyISAM;

--
-- Dumping data for table 'languages'
--


INSERT INTO languages VALUES (1,'it_IT','Italiano');
INSERT INTO languages VALUES (2,'da_DK','Dansk');
INSERT INTO languages VALUES (3,'en_US','English');
INSERT INTO languages VALUES (4,'hu_HU','Magyar');
INSERT INTO languages VALUES (5,'hr_HR','Hrvatski');
INSERT INTO languages VALUES (6,'ca_ES','Català');
INSERT INTO languages VALUES (7,'eu_ES','Euskara');
INSERT INTO languages VALUES (8,'es_ES','Español');
INSERT INTO languages VALUES (9,'pl_PL','Polski');
INSERT INTO languages VALUES (10,'tr_TR','Türkçe');
INSERT INTO languages VALUES (11,'id_ID','Bahasa Indonesia');
INSERT INTO languages VALUES (12,'nl_NL','Nederlands');
INSERT INTO languages VALUES (13,'sl_SI','Slovenski');
INSERT INTO languages VALUES (14,'sq_AL','Shqipe');
INSERT INTO languages VALUES (15,'fi_FI','Suomi');
INSERT INTO languages VALUES (16,'pt_PT','Português');
INSERT INTO languages VALUES (17,'fr_FR','Français');
INSERT INTO languages VALUES (18,'no_NO','Bokmål');
INSERT INTO languages VALUES (19,'is_IS','Íslenska');
INSERT INTO languages VALUES (20,'sv_SE','Svenska');
INSERT INTO languages VALUES (21,'de_DE','Deutsch');

--
-- Table structure for table 'nl_NL'
--

CREATE TABLE nl_NL (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'nl_NL'
--



--
-- Table structure for table 'no_NO'
--

CREATE TABLE no_NO (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'no_NO'
--



--
-- Table structure for table 'pl_PL'
--

CREATE TABLE pl_PL (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'pl_PL'
--



--
-- Table structure for table 'pt_PT'
--

CREATE TABLE pt_PT (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'pt_PT'
--



--
-- Table structure for table 'sl_SI'
--

CREATE TABLE sl_SI (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'sl_SI'
--


INSERT INTO sl_SI VALUES (1,'ws','sl_SI',NULL);

--
-- Table structure for table 'sq_AL'
--

CREATE TABLE sq_AL (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'sq_AL'
--



--
-- Table structure for table 'sv_SE'
--

CREATE TABLE sv_SE (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'sv_SE'
--



--
-- Table structure for table 'tr_TR'
--

CREATE TABLE tr_TR (
  id int(11) NOT NULL auto_increment,
  word varchar(255) binary NOT NULL default '',
  language varchar(255) NOT NULL default '',
  description text,
  PRIMARY KEY  (id),
  UNIQUE KEY word (word)
) TYPE=MyISAM;

--
-- Dumping data for table 'tr_TR'
--



