use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'WWW::Mediawiki::Client',
    VERSION_FROM    => 'lib/WWW/Mediawiki/Client.pm',
    EXE_FILES       => ['bin/wix'],
    PREREQ_PM       => 
        { 
            'Test::Differences'=> 0,
            'Algorithm::Diff::Apply' => 0.2.0,
            'Getopt::Std'=> 0,
            'Pod::Usage' => 0,
            'File::Spec' => 0,
            'File::Find' => 0,
            'LWP::UserAgent' => 0,
            'HTML::TokeParser' => 0,
            'HTTP::Request' => 0,
            'HTTP::Request::Common' => 0,
            'HTTP::Cookies' => 0,
            'URI::Escape' => 0,
            'Algorithm::Diff' => 0,
            'Algorithm::Diff::Apply' => 0,
            'Carp' => 0,
            'Data::Dumper' => 0,
        },
);

