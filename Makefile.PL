use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'WWW::Mediawiki::Client',
    VERSION_FROM    => 'lib/WWW/Mediawiki/Client.pm',
    EXE_FILES       => ['bin/wix'],
    PREREQ_PM       => { 'Test::Differences' => 0 },
);

