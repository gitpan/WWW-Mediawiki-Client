#!/usr/bin/perl -w

use Test::More tests=> 22;
use Test::Differences;

BEGIN {
    use_ok('WWW::Mediawiki::Client');
}

# Fields
my ($HtmlData, $WikiData, $mvs);

# test the constructor first
ok($mvs = WWW::Mediawiki::Client->new(site_url => 'http://localhost/'), 
        'Can instanciate a WWW::Mediawiki::Client object');

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
mkdir '/tmp/mvstest' 
        or die "Could not make test dir.  Check the permissions on /tmp.";

chdir '/tmp/mvstest';


#TODO: {
#    local $TODO = "Can't test update without webserver.";
#    ok($mvs->do_update('paris.wiki'), 'Test update');
#    ok($mvs->do_up('paris.wiki'), 'Test calling update as up');
#}

#TODO: {
#    local $TODO = "Can't test commit without webserver.";
#    ok($mvs->do_update('paris.wiki'), 'Test update');
#    ok($mvs->do_up('paris.wiki'), 'Test calling update as up');
#}

# Test the filename method
is($mvs->_filename_to_url('San_Francisco.wiki', 'wiki/wiki.phtml?action=edit&title='),
        'http://localhost/wiki/wiki.phtml?action=edit&title=San+Francisco',
        'Can we convert the filename to the URL?');
$mvs->space_substitute('_');
is($mvs->_filename_to_url('San_Francisco.wiki', 'wiki/wiki.phtml?action=edit&title='),
        'http://localhost/wiki/wiki.phtml?action=edit&title=San_Francisco',
        'Can we convert the filename to the URL?');

# Can we harvest the Wiki data from the HTML page?
eq_or_diff($mvs->_get_wiki_text($HtmlData), $WikiData, 
        'get_wiki_text returns the correct text');

# Test the conflict detection and separation
eq_or_diff( $mvs->_merge('Paris.wiki', $RefData, $ServerData, $LocalData), 
        $MergedData,
        'does a merge of our test files produce the expected result?');

# Test the login method
undef $mvs;
$mvs = WWW::Mediawiki::Client->new();
$mvs->site_url('http://localhost');
$mvs->username('TestUser');
$mvs->password('testme');
my $res = $mvs->do_login;
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
undef $mvs;
$mvs = WWW::Mediawiki::Client->new();
ok($mvs = $mvs->load_state, 'can run load_state');
is($mvs->password, 'bar', 'retrieved correct password');
is($mvs->username, 'foo', 'retrieved correct username');
is($mvs->output_level, 2, 'retrieved correct output_level');
is($mvs->site_url, 'http://www.somewiki.org', 'retrieved correct site_url');
#cleanup
unlink $conf_file;

# Test saving configuration
undef $mvs;
$mvs = WWW::Mediawiki::Client->new();
$mvs->username('fred');
$mvs->password('3117p4sS');
$mvs->output_level(1);
$mvs->site_url('http://www.someotherwiki.org');
ok($mvs->save_state, 'can run save_state');
undef $mvs;
$mvs = WWW::Mediawiki::Client->new();
$mvs = $mvs->load_state;
is($mvs->password, '3117p4sS', 'retrieved correct password');
is($mvs->username, 'fred', 'retrieved correct username');
is($mvs->output_level, 1, 'retrieved correct output_level');
is($mvs->site_url, 'http://www.someotherwiki.org', 'retrieved correct site_url');
unlink $conf_file;


# clean up
END {
    unlink $conf_file;
    unlink '.mediawiki_cookies.dat';
    chdir;
    rmdir '/tmp/mvstest' or die "Hey... can't delete the test dir.";
}

1;

__END__

