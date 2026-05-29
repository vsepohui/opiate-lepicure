-- drop table photo;

CREATE TABLE photo (
	id serial PRIMARY KEY,
	ctime timestamp not null default now(),
	user_id integer not null,
	path text not null,
	visit_count integer default 0
);

create index idx_photo_user_id on photo (user_id);
