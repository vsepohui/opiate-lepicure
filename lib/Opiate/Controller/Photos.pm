package Opiate::Controller::Photos;

use 5.022;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;
use Opiate::Model::Photo;
use Opiate::Magic;

use utf8;

sub owner {
	my $self  = shift;
	my $alias = $self->stash('alias');
	return Opiate::Model::User->get_by_alias(alias => $alias);
}

sub is_allowed {
	my $self = shift;
	return $self->owner->{alias} eq $self->user->{alias};
}

sub photos {
	my $self = shift;
	my $user = $self->user;
	
	my $owner = $self->owner();
	
	my @photos = Opiate::Model::Photo->select(user_id => $owner->{id});
	
	return $self->render(
		owner  => $owner,
		photos => \@photos,
	);
}

sub upload {
	my $self = shift;
	my $user = $self->user;
	
	return $self->error('Ошибка доступа!') unless $self->is_allowed();
	my $owner = $self->owner();
	
	for my $file (@{$self->req->uploads('upload')}) {
		my $size = $file->size;
		my $name = $file->filename;
		
		return $self->error('Файл слишком большой!') if ($size >= 4_000_000);
		
		my $path = $self->upload_image($owner->{alias}, $file);
		
		Opiate::Model::Photo->insert(
			user_id => $owner->{id},
			path    => $path,
		);
	}
	
	return $self->redirect_to('/' . $owner->{alias} . '/photos');
}


1;
