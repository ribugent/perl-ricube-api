package Ricube::Api;

use strict;
use warnings;

use 5.008_005;
our $VERSION = '0.01';

use LWP::UserAgent;
use JSON::MaybeXS qw/decode_json/;
use Encode qw/encode_utf8 decode_utf8/;
use URI;

our $URL = 'https://api.ricube.net';

# New method
sub new {
	my ($this, %pars) = @_;

	my $self = bless {map { exists $pars{$_} ? ($_ => $pars{$_}) : () } qw/client_id client_secret access_token/}, $this;

	$self->{ua} //= LWP::UserAgent->new();
	$self->{ua}->default_header('Authorization' => "Bearer $self->{access_token}");

	return $self;
}

# Exchange token
sub oauth2Token {
	my ($self, $code, $redirectUrl) = @_;
	my $uri = URI->new("$URL/oauth2/token");
	$uri->query_form(code => $code, redirect_uri => $redirectUrl);

	my $r = $self->{ua}->get($uri);
	return if (!$r->is_success);
	return decode_utf8($r->decoded_content(charset => 'none'));
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
	return shift->_oauth2Request(put => 'tags/' . shift, shift, 'none');
}

# Delete tag
sub deleteTag {
	return shift->_oauth2Request(delete => 'tags/' . shift, undef, 'none');
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
	return shift->_oauth2Request(post => 'links/' . shift . '/tags', shift, 'none');
}

# Delete tag of link
sub deleteLinkTag {
	return shift->_oauth2Request(delete => 'links/' . shift . '/tags/' . shift, 'none');
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
	my ($self, $method, $path, $body, $responseType) = @_;
	$responseType //= 'json';
	my $r = $self->{ua}->$method("$URL/1/$path", $body ? (Content => encode_utf8($body)) : ());

	my $content = $r->decoded_content(charset => 'none');

	if ($responseType eq 'json') {
		return decode_json($content);
	} elsif ($responseType eq 'text') {
		return decode_utf8($content);
	} elsif ($responseType eq 'none') {
		return !$responseType && $r->is_success();
	}

	die("Missing responseType");
}

# TODO:
# - get redirect url

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
