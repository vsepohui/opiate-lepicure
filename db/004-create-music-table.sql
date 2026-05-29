-- drop table music;

CREATE TABLE music (
	id serial PRIMARY KEY,
	ctime timestamp not null default now(),
	user_id integer not null,
	bandcamp_id text not null,
	visit_count integer default 0
);

create index idx_music_user_id on music (user_id);
