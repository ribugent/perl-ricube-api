package Ricube::Api;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use LWP::UserAgent;
use JSON::MaybeXS qw/decode_json/;
use Encode qw/encode_utf8/;

our $URL = 'https://api.ricube.net';

# New method
sub new {
	my ($this, %pars) = @_;

	my $self = bless {map { exists $pars{$_} ? ($_ => $pars{$_}) : () } qw/client_id client_secret access_token/}, $this;

	$self->{ua} //= LWP::UserAgent->new();
	$self->{ua}->default_header('Authorization' => "Bearer $self->{access_token}");

	return $self;
}

# Get current user
sub me {
	return shift->_oauth2Request(get => 'users/me');
}

# List tags
sub tags {
	return shift->_oauth2Request(get => 'tags');
}

# Tag info
sub tag {
	return shift->_oauth2Request(get => 'tags/' . shift);
}

# Create tag
sub createTag {
	return shift->_oauth2Request(post => 'tags/', shift);
}

# Update tag
sub updateTag {
	return shift->_oauth2Request(put => 'tags/' . shift, shift);
}

# Delete tag
sub deleteTag {
	return shift->_oauth2Request(delete => 'tags/' . shift);
}

# Link info
sub link {
	return shift->_oauth2Request(get => 'links/' . shift);
}

# Create link
sub createLink {
	return shift->_oauth2Request(post => 'links', shift);
}

# Add tag to link
sub createLinkTag {
	return shift->_oauth2Request(post => 'links/' . shift . '/tags', shift);
}

# Delete tag of link
sub createLinkTag {
	return shift->_oauth2Request(delete => 'links/' . shift . '/tags/' . shift);
}

# Search engine
sub search {
	my ($self, @pars) = @_;
	my $path = URI->new('links/search');
	$path->query_form(@pars);
	return shift->_oauth2Request(get => $path);
}

# Generic request to protected resouseces
sub _oauth2Request {
	my ($self, $method, $path, $body) = @_;

	my $r = $self->{ua}->$method("$URL/1/$path", $body ? (Content => encode_utf8($body)) : ());

	my $json;
	if ($r->content) {
		$json = decode_json($r->decoded_content(charset => 'none'));
	}

	die($json) if (!$r->is_success());
	return $json || 1;
}

# TODO:
# - get redirect url
# - exchange token method
# - Implement not GET methods
# - Not all requests return json

1;
__END__

=encoding utf-8

=head1 NAME

Ricube::Api - Simple client to access https://ricube.net api

=head1 SYNOPSIS

  use Ricube::Api;

=head1 DESCRIPTION

Ricube::Api is

=head1 AUTHOR

Gerard Ribugent Navarro E<lt>ribugent@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2016- Gerard Ribugent Navarro

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as gpl_2 itself.

=head1 SEE ALSO

=cut
