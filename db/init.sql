CREATE TABLE invites (
        id serial PRIMARY KEY,
        ctime date not null default now(),
        name text not null,
        email text not null,
        ask text not null
);

create index idx_invites_email on invites (email);


CREATE TABLE users (
        id serial PRIMARY KEY,
        ctime date not null default now(),
        name text not null,
        email text not null,
        password text not null,
        is_musicman boolean not null default false,
        is_admin boolean not null default false,
        is_male boolean default null,
        birthdate date default null
);

create index idx_users_email on users (email);
