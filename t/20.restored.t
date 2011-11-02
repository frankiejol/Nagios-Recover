use Nagios::Recover qw(recover fixed);
use Test::More tests => 9;

sub action_echo {

        my $ret = '';

        open ACTION,"<tmp/action.txt" or return '';
        $ret = <ACTION>;
        close ACTION;

        chomp $ret;
        return $ret;
}

#######################################################################

eval {
    recover();
};
ok($@ =~ /Missing service/);

eval {
    recover( service => 'ftp');
};
ok($@ =~ /Missing action/);

my $action= ["echo action0 $$ > tmp/action.txt",
              "echo action1 $$ > tmp/action.txt",
              "echo action2 $$ > tmp/action.txt",
            ];

if ( ! -d 'tmp'){
    mkdir "tmp" or die "I can't mkdir tmp ";
} else {
    unlink "tmp/ftpd.status" or die "I cant' clean status"
        if -e "tmp/ftpd.status";

    unlink "tmp/action.txt"  or die "I can't remove action.txt"
        if -e "tmp/action.txt";
}

ok(! -e "tmp/fptd.status");
ok(! -e "tmp/action.txt");

my $status = recover(    
            dir => './tmp', 
         action => $action,
        service => 'ftpd',
);

ok($status->{level} == 1);
ok($status->{service} eq 'ftpd');

$status = fixed(
            dir => './tmp', 
         action => $action,
        service => 'ftpd',
);
ok($status->{level} == 0);

$status = recover(    
            dir => './tmp', 
         action => $action,
        service => 'ftpd',
);

ok($status->{level} == 1);
ok($status->{service} eq 'ftpd');

