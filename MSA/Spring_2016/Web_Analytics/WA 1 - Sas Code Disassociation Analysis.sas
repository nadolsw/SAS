*\\Disassociation Analysis SAS CODE utility node; 


%let values='SVG', 'CKING', 'MMDA';
%let in=&EM_IMPORT_TRANSACTION;
%let out=&EM_EXPORT_TRANSACTION;

PROC SQL;
	create table v56767c as
	   select distinct %em_target from &in;

	create table r57304x as
	   select distinct %em_id as %em_id, a.%em_target, '~'||a.%em_target as notvalue
	   from &in, v56767c as a;
	
	create table &out as
	   select b.%em_id, coalesce(a.%em_target, b.notvalue) as %em_target
	   from &in as a right join r57304x as b
           on a.%em_id=b.%em_id and
                a.%em_target=b.%em_target
           where a.%em_target ~= '' or b.%em_target in (&values);

quit;

PROC datasets library=work nolist;
  delete r57304x v56767c;
quit;

