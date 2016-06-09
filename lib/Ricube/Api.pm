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
our $AUTHORIZE_URL = 'https://ricube.net/oauth2/authorize';

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

# Return authorize url
sub authorizeUrl {
	my ($self, $responseType, $redirect_uri) = @_;
	my $uri = URI->new($AUTHORIZE_URL);
	$uri->query_form(
		client_id => $self->{client_id},
		response_type => $responseType,
		redirect_uri => $redirect_uri
	);
	return $uri;
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

1;
__END__

=encoding utf-8

=head1 NAME

Ricube::Api - Simple client to access https://ricube.net api

=head1 SYNOPSIS

  use Ricube::Api;

  # Get an access token
  my $api = Ricube::Api->new(client_id => 'xxxxx');
  $api->redirect_uri('access_token', 'http://foo.bar/ricube_callback');
  # After authorize you will be redirected to the specified url plus access token, in this case will be: http://foo.bar/ricube_callback#token=xxxxx

  # Get a code and exchange by an access token
  my $api = Ricube::Api->new(client_id => 'xxxxx');
  $api->redirect_uri('code', 'http://foo.bar/ricube_callback');
  # After authorize you will be redirected to the specified url plus the code, in this case will be: http://foo.bar/ricube_callback?code=xxxxx
  my $h = $api->oauth2Token($code, 'http://foo.bar/ricube_callback')
  # $h = { token => 'xxxxx' }

  # Make authenticated calls
  my $api = Ricube::Api->new(access_token => 'xxxxx');

  $api->me();
  $api->tags();
  $api->tag(1;
  $api->createTag('tag_name');
  $api->updateTag(1256, 'new_tag_name');
  $api->deleteTag(1256);
  $api->createLink('https://ricube.com/about');
  $api->link(213545341);
  $api->createLinkTag(213545341, 1257);
  $api->deleteLinkTag(213545341, 1257);;
  $api->search(q => ..., start => ..., rows => ..., tag => ...) = @_;


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
