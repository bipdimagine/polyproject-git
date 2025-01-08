package queryValidationDB;

use strict;
use DBI;
use DBD::mysql;
use Data::Dumper;
use JSON;


sub createSchemasValidationTmp {
	my ($dbh,$Schemas) = @_;
	my $sql = qq{DROP DATABASE IF EXISTS $Schemas};
	$dbh->do($sql);
}

sub createSchemasValidation {
	my ($dbh,$Schemas) = @_;
	my $sql = qq{create database $Schemas};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
}

#	my $sql = qq{DROP TABLE IF EXISTS $Schemas};

sub dropSchemasValidation {
	my ($dbh,$Schemas) = @_;
	my $sql = qq{DROP DATABASE IF EXISTS $Schemas};
	$dbh->do($sql);
}
=mod
sub createExonValidation {
	my ($dbh,$Schemas) = @_;
	
	###### Table Exons ######
	my $sql = qq{    
		CREATE TABLE $Schemas.exons
		(`exon_id` varchar(200) NOT NULL,
		`project_name` varchar(45) NOT NULL,
		`chromosome` varchar(5) NOT NULL,
		`start` int(11) NOT NULL,
		`end` int(11) NOT NULL,
		`todo` int(11) NOT NULL,
		`done` int(11) NOT NULL,
		`user_name` varchar(45) NOT NULL,
		`transcript` varchar(60) NOT NULL,
		`gene` varchar(60) NOT NULL,
		`sample_name` varchar(45) NOT NULL,
		`creation_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		`modification_date` timestamp NOT NULL default '0000-00-00 00:00:00',
		KEY `index_3` (`exon_id`),
		KEY `index_2` USING BTREE (`project_name`)
		) 
		ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; InnoDB free: 185344 kB; InnoDB free:';
	};
	$dbh->do($sql);

	###### Table Reports ######
	my $sql1 = qq{    
		CREATE TABLE $Schemas.reports
		(`report_id` int(11) NOT NULL auto_increment,
		`sample` varchar(45) NOT NULL,
		`project` varchar(45) NOT NULL,
		`json` text NOT NULL,
		`creation_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		`conclusion` text NOT NULL,
		`user_name` varchar(45) NOT NULL,
		PRIMARY KEY  (`report_id`),
		UNIQUE KEY `index_2` (`sample`,`project`)
		) 
		ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; InnoDB free: 185344 kB; InnoDB free:';
	};
	$dbh->do($sql1);
	
	###### Table Variations ######
	my $sql2 = qq{    
		CREATE TABLE $Schemas.variations
		(`variation_id` int(11) NOT NULL auto_increment,
		`polyid` varchar(100) NOT NULL,
		`vcfid` varchar(100) NOT NULL,
		`genbo_id` int(11) default NULL,
		`version` varchar(10) NOT NULL,
		PRIMARY KEY  (`variation_id`),
		UNIQUE KEY `index_2` (`polyid`),
		UNIQUE KEY `index_3` (`vcfid`),
		KEY `index_4` USING BTREE (`genbo_id`)
		)		
		ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; InnoDB free: 185344 kB; InnoDB free:';
	};
	$dbh->do($sql2);
	
	###### Table Validations ######

	my $sql3 = qq{    
		CREATE TABLE $Schemas.validations
		(`variation_id` int(11) NOT NULL,
 		`project_name` varchar(45) NOT NULL,
		`project_id` int(11) NOT NULL,
		`user_name` varchar(45) NOT NULL,
		`validation` int(11) NOT NULL,
		`creation_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		`sample_name` varchar(45) NOT NULL,
		`vcf_line` varchar(1000) NOT NULL,
		`modification_date` timestamp NOT NULL default '0000-00-00 00:00:00',
		`sam_lines` blob NOT NULL,
		`validation_id` int(11) NOT NULL auto_increment,
		`method` varchar(45) NOT NULL,
		`validation_sanger` int(11) NOT NULL,
		PRIMARY KEY  USING BTREE (`validation_id`),
		UNIQUE KEY `index_2` (`variation_id`,`project_name`,`user_name`,`sample_name`),
		CONSTRAINT `FK_validations_1` FOREIGN KEY (`variation_id`) REFERENCES `variations` (`variation_id`) ON DELETE CASCADE
		)		
		ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; InnoDB free: 185344 kB; InnoDB free:';
	};
	$dbh->do($sql3);
}
=cut
=mod
		CONSTRAINT `FK_validations_1` FOREIGN KEY (`variation_id`) REFERENCES `variations` (`variation_id`) ON DELETE CASCADE
=cut

sub createExonValidation {
	my ($dbh,$Schemas) = @_;
	
	###### Table Exons ######
	my $sql = qq{    
		CREATE TABLE $Schemas.exons
		(`exon_id` varchar(200) NOT NULL,
		`project_name` varchar(45) NOT NULL,
		`chromosome` varchar(5) NOT NULL,
		`start` int(11) NOT NULL,
		`end` int(11) NOT NULL,
		`todo` int(11) NOT NULL,
		`done` int(11) NOT NULL,
		`user_name` varchar(45) NOT NULL,
		`transcript` varchar(60) NOT NULL,
		`gene` varchar(60) NOT NULL,
		`sample_name` varchar(45) NOT NULL,
		`creation_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		`modification_date` timestamp NOT NULL default '0000-00-00 00:00:00',
		PRIMARY KEY (`exon_id`,`project_name`) USING BTREE,
		KEY `index_3` (`exon_id`),
		KEY `index_2` USING BTREE (`project_name`)
		) 
		ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; InnoDB free: 185344 kB; InnoDB free:';
	};
	$dbh->do($sql);

	###### Table Reports ######
	my $sql1 = qq{    
		CREATE TABLE $Schemas.reports
		(`report_id` int(11) NOT NULL auto_increment,
		`sample` varchar(45) NOT NULL,
		`project` varchar(45) NOT NULL,
		`json` text NOT NULL,
		`creation_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		`conclusion` text NOT NULL,
		`user_name` varchar(45) NOT NULL,
		PRIMARY KEY  (`report_id`),
		UNIQUE KEY `index_2` (`sample`,`project`)
		) 
		ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; InnoDB free: 185344 kB; InnoDB free:';
	};
	$dbh->do($sql1);
	###### Table Variations ######
	my $sql2 = qq{    
		CREATE TABLE $Schemas.variations
		(`variation_id` int(11) NOT NULL auto_increment,
		`polyid` varchar(100) NOT NULL,
		`vcfid` varchar(100) NOT NULL,
		`genbo_id` int(11) default NULL,
		`version` varchar(10) NOT NULL,
		PRIMARY KEY  (`variation_id`),
		UNIQUE KEY `index_2` (`polyid`),
		UNIQUE KEY `index_3` (`vcfid`),
		KEY `index_4` USING BTREE (`genbo_id`)
		)		
		ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; InnoDB free: 185344 kB; InnoDB free:';
	};
	$dbh->do($sql2);

	
	###### Table Validations ######
	my $sql3 = qq{    
		CREATE TABLE $Schemas.validations
		(`variation_id` int(11) NOT NULL,
 		`project_name` varchar(45) NOT NULL,
		`project_id` int(11) NOT NULL,
		`user_name` varchar(45) NOT NULL,
		`validation` int(11) NOT NULL,
		`creation_date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		`sample_name` varchar(45) NOT NULL,
		`vcf_line` varchar(1000) NOT NULL,
		`modification_date` timestamp NOT NULL default '0000-00-00 00:00:00',
		`sam_lines` blob NOT NULL,
		`validation_id` int(11) NOT NULL auto_increment,
		`method` varchar(45) NOT NULL,
		`validation_sanger` int(11) NOT NULL,
		PRIMARY KEY  USING BTREE (`validation_id`),
		UNIQUE KEY `index_2` (`variation_id`,`project_name`,`user_name`,`sample_name`),
		CONSTRAINT `FK_validations_1` FOREIGN KEY (`variation_id`) REFERENCES `variations` (`variation_id`) ON DELETE CASCADE
		)		
		ENGINE=InnoDB  DEFAULT CHARSET=latin1 COMMENT='InnoDB free: 206848 kB; InnoDB free: 185344 kB; InnoDB free:';
	};
	$dbh->do($sql3);

=mod
		CONSTRAINT `FK_validations_1` FOREIGN KEY (`variation_id`) REFERENCES `variations` (`variation_id`) ON DELETE CASCADE
	
=cut
}

1;
