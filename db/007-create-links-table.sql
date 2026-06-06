-- drop table links;


CREATE TABLE links (
	id serial PRIMARY KEY,
	ctime timestamp not null default now(),
	user_id integer not null,
	url text not null,
	description text not null
);

create index idx_links_user_id_id on links (user_id, id);
