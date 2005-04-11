#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Test::More no_plan => 1;
use Catalyst::Test 'TestApp';

use Catalyst::Request;
use Catalyst::Request::Upload;
use HTTP::Headers;
use HTTP::Headers::Util 'split_header_words';
use HTTP::Request::Common;

{
    my $creq;

    my $request = POST( 'http://localhost/dump/request/',
        'Content-Type' => 'multipart/form-data',
        'Content'      => [
            'cookies.t' => [ "$FindBin::Bin/cookies.t" ],
            'headers.t' => [ "$FindBin::Bin/headers.t" ],
            'uploads.t' => [ "$FindBin::Bin/uploads.t" ],
         ]
    );

    ok( my $response = request($request), 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->content_type, 'text/plain', 'Response Content-Type' );
    like( $response->content, qr/^bless\( .* 'Catalyst::Request' \)$/s, 'Content is a serialized Catalyst::Request' );
    
    {
        no strict 'refs';
        ok( eval '$creq = ' . $response->content, 'Unserialize Catalyst::Request' );
    }

    isa_ok( $creq, 'Catalyst::Request' );
    is( $creq->method, 'POST', 'Catalyst::Request method' );
    is( $creq->content_type, 'multipart/form-data', 'Catalyst::Request Content-Type' );
    is( $creq->content_length, $request->content_length, 'Catalyst::Request Content-Length' );

    for my $part ( $request->parts ) {

        my $disposition = $part->header('Content-Disposition');
        my %parameters  = @{ ( split_header_words($disposition) )[0] };

        my $upload = $creq->uploads->{ $parameters{filename} };
        
        isa_ok( $upload, 'Catalyst::Request::Upload' );

        is( $upload->type, $part->content_type, 'Upload Content-Type' );
        is( $upload->size, length( $part->content ), 'Upload Content-Length' );
    }
}
