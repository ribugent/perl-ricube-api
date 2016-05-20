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
