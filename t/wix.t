#!/usr/bin/perl -w

use Test::More tests=> 22;
use Test::Differences;

BEGIN {
    use_ok('WWW::Mediawiki::Client');
}

# Fields
my ($HtmlData, $WikiData, $wix);

# test the constructor first
ok($wix = WWW::Mediawiki::Client->new(site_url => 'http://localhost/'), 'Can instanciate a WWW::Mediawiki::Client object');

# load the test data
undef $/;
ok(open(IN, "t/files/paris.html"), 'Can open our test HTML');
$HtmlData = <IN>;
ok(open(IN, "t/files/paris.wiki"), 'Can open our test Wiki file');
$WikiData = <IN>;
ok(open(IN, "t/files/reference.wiki"), 'Can open the reference Wiki file');
$RefData= <IN>;
ok(open(IN, "t/files/local.wiki"), 'Can open the local Wiki file');
$LocalData= <IN>;
ok(open(IN, "t/files/server.wiki"), 'Can open the server Wiki file');
$ServerData= <IN>;
ok(open(IN, "t/files/merged.wiki"), 'Can open our merged Wiki file');
$MergedData= <IN>;
close IN;
$/= "\n";
chomp ($RefData, $ServerData, $LocalData, $MergedData);

# make a test repository
mkdir '/tmp/wixtest' 
        or die "Could not make test dir.  Check the permissions on /tmp.";

chdir '/tmp/wixtest';


#TODO: {
#    local $TODO = "Can't test update without webserver.";
#    ok($wix->do_update('paris.wiki'), 'Test update');
#    ok($wix->do_up('paris.wiki'), 'Test calling update as up');
#}

#TODO: {
#    local $TODO = "Can't test commit without webserver.";
#    ok($wix->do_update('paris.wiki'), 'Test update');
#    ok($wix->do_up('paris.wiki'), 'Test calling update as up');
#}

# Test the filename method
is($wix->_filename_to_url('San_Francisco.wiki', 'wiki/wiki.phtml?action=edit&title='),
        'http://localhost/wiki/wiki.phtml?action=edit&title=San+Francisco',
        'Can we convert the filename to the URL?');
$wix->space_substitute('_');
is($wix->_filename_to_url('San_Francisco.wiki', 'wiki/wiki.phtml?action=edit&title='),
        'http://localhost/wiki/wiki.phtml?action=edit&title=San_Francisco',
        'Can we convert the filename to the URL?');

# Can we harvest the Wiki data from the HTML page?
eq_or_diff($wix->_get_wiki_text($HtmlData), $WikiData, 
        'get_wiki_text returns the correct text');

# Test the conflict detection and separation
eq_or_diff( $wix->_merge('Paris.wiki', $RefData, $ServerData, $LocalData), 
        $MergedData,
        'does a merge of our test files produce the expected result?');

# Test the login method
undef $wix;
$wix = WWW::Mediawiki::Client->new();
$wix->site_url('http://localhost');
$wix->username('TestUser');
$wix->password('testme');
my $res = $wix->do_login;
use Data::Dumper;

# Test loading a configuration
my $conf_file = WWW::Mediawiki::Client::CONFIG_FILE;
open OUT, ">$conf_file" or die "Could not open conf file";
print OUT q{ $VAR1 = {
    site_url        => 'http://www.somewiki.org',
    output_level    => 2,
    username        => 'foo',
    password        => 'bar',
}
};
close OUT;
undef $wix;
$wix = WWW::Mediawiki::Client->new();
ok($wix = $wix->load_state, 'can run load_state');
is($wix->password, 'bar', 'retrieved correct password');
is($wix->username, 'foo', 'retrieved correct username');
is($wix->output_level, 2, 'retrieved correct output_level');
is($wix->site_url, 'http://www.somewiki.org', 'retrieved correct site_url');
#cleanup
unlink $conf_file;

# Test saving configuration
undef $wix;
$wix = WWW::Mediawiki::Client->new();
$wix->username('fred');
$wix->password('3117p4sS');
$wix->output_level(1);
$wix->site_url('http://www.someotherwiki.org');
ok($wix->save_state, 'can run save_state');
undef $wix;
$wix = WWW::Mediawiki::Client->new();
$wix = $wix->load_state;
is($wix->password, '3117p4sS', 'retrieved correct password');
is($wix->username, 'fred', 'retrieved correct username');
is($wix->output_level, 1, 'retrieved correct output_level');
is($wix->site_url, 'http://www.someotherwiki.org', 'retrieved correct site_url');
unlink $conf_file;


# clean up
END {
    unlink $conf_file;
    unlink '.wix_cookies.dat';
    chdir;
    rmdir '/tmp/wixtest' or die "Hey... can't delete the test dir.";
}

1;

__END__

