# NAME

Ricube::Api - Simple client to access https://ricube.net api

# SYNOPSIS

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

# DESCRIPTION

Ricube::Api is

# AUTHOR

Gerard Ribugent Navarro <ribugent@gmail.com>

# COPYRIGHT

Copyright 2016- Gerard Ribugent Navarro

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as gpl\_2 itself.

# SEE ALSO
