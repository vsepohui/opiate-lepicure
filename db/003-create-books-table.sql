-- drop table books;
-- drop table book_lists;

CREATE TABLE books (
	id serial PRIMARY KEY,
	ctime timestamp not null default now(),
	user_id integer not null,
	name text not null,
	year text not null,
	alias text not null,
	visit_count integer default 0
);

create index idx_books_user_id on books (user_id);
create index idx_books_user_id_alias on books (user_id, alias);

CREATE TABLE book_lists (
	id serial PRIMARY KEY,
	ctime timestamp not null default now(),
	book_id integer not null,
	title text not null,
	text text not null,
	comment text default null,
	visit_count integer default 0
);

create index idx_book_lists_books_id on book_lists (book_id, id);
