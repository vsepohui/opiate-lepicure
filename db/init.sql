CREATE TABLE invites (
        id serial PRIMARY KEY,
        ctime date not null default now(),
        name text not null,
        email text not null,
        ask text not null
);

create index idx_invites_email on invites (email);
