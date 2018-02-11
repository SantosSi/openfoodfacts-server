#!/usr/bin/perl

use Modern::Perl '2012';
use utf8;

use CGI::Carp qw(fatalsToBrowser);

use ProductOpener::Config qw/:all/;
use ProductOpener::Store qw/:all/;
use ProductOpener::Index qw/:all/;
use ProductOpener::Display qw/:all/;
use ProductOpener::Tags qw/:all/;
use ProductOpener::Users qw/:all/;
use ProductOpener::Images qw/:all/;
use ProductOpener::Products qw/:all/;

use CGI qw/:cgi :form escapeHTML/;
use URI::Escape::XS;
use Storable qw/dclone/;
use Encode;
use JSON::PP;
use Log::Any qw($log);

ProductOpener::Display::init();

my $type = param('type') || 'add';
my $action = param('action') || 'display';

my $code = normalize_code(param('code'));
my $imgid = param('imgid');
my $angle = param('angle');
my $id = param('id');
my ($x1,$y1,$x2,$y2) = (param('x1'),param('y1'),param('x2'),param('y2'));
my $normalize = param('normalize');
my $white_magic = param('white_magic');

$log->debug("product_image_crop.pl - start", { code => $code, imgid => $imgid, x1 => $x1, y1 => $y1, x2 => $x2, y2 => $y2 }) if $log->is_debug();

if (not defined $code) {
	
	exit(0);
}

my $product_ref = process_image_crop($code, $id, $imgid, $angle, $normalize, $white_magic, $x1, $y1, $x2, $y2);

my $data =  encode_json({ status => 'status ok',
		image => {
				display_url=> "$id." . $product_ref->{images}{$id}{rev} . ".$display_size.jpg",
		},
		imagefield=>$id,
});

$log->debug("product_image_crop.pl - JSON data output", { data => $data }) if $log->is_debug();

print header( -type => 'application/json', -charset => 'utf-8' ) . $data;


exit(0);

