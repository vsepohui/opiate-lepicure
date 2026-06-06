package Opiate::Controller::User;

use strict;
use warnings;

use Mojo::Base 'Opiate::Controller';

use Opiate::Model::User;


sub profile {
	my $self = shift;
	my $user = $self->user;
	
	my $alias = $user->{alias};
	
	if ($self->req->method eq 'POST') {
		if ($self->param('avatar_upload')) {
			for my $file (@{$self->req->uploads('upload')}) {
				my $size = $file->size;
				my $name = $file->filename;
				
				return $self->error('Файл слишком большой!') if ($size >= 300_000);
				
				my $path = $self->upload_image($user->{alias}, $file);
				
				$user->set_avatar(avatar => $path);
				
				return $self->redirect_to('/' . $alias);
			}
		} elsif (my $info = $self->param('info')) {
			$user->set_info(info => $info);
			return $self->back;
		}
	}
	
	return $self->render();	
}

1;
