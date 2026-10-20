-- drop table history_log;

CREATE TABLE history_log (
	id serial PRIMARY KEY,
	ctime timestamp not null default now(),
	user_id integer not null,
	sudo_id integer default null,
	object_table text not null,
	object_id integer not null,
	log text not null
);


