-- drop table feed;

CREATE TABLE feed (
	id serial PRIMARY KEY,
	ctime timestamp not null default now(),
	user_id integer not null,
	subject text not null,
	message text not null,
	visit_count integer default 0
);

create index idx_feed_user_id on feed (user_id, id);

