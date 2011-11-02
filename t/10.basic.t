use Nagios::Recover qw(recover);
use Test::More tests => 22;

sub action_echo {

        my $ret = '';

        open ACTION,"<tmp/action.txt" or return '';
        $ret = <ACTION>;
        close ACTION;

        chomp $ret;
        return $ret;
}


eval {
    recover();
};
ok($@ =~ /Missing service/);

eval {
    recover( service => 'ftp');
};
ok($@ =~ /Missing action/);

my $action= ["echo action1 $$ > tmp/action.txt",
              "echo action2 $$ > tmp/action.txt",
              "echo action3 $$ > tmp/action.txt",
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

my $status = recover(    dir => './tmp', 
        service => 'ftpd',
        action => $action,
);

ok($status->{level} == 1);
ok($status->{service} eq 'ftpd');

$status = recover(
            dir => './tmp', 
         action => $action,
        service => 'ftpd',
);
ok($status->{level} == 2);

$status = recover(
            dir => './tmp', 
         action => $action,
        service => 'ftpd',
);


ok($status->{level} == 3);

for my $expected (1 .. 3) {
    $status = recover(
                dir => './tmp', 
             action => $action,
            service => 'ftpd',
    );
    
    ok($status->{level} == $expected);
    ok(action_echo() eq "action$expected $$");
    ok($status->{executed} eq $action->[$expected-1]);
}

push @{$action},("echo action4 $$");
$status = recover(
                dir => './tmp', 
             action => $action,
            service => 'ftpd',
);
    
ok($status->{level} == 4);
ok($status->{out} eq "action4 $$\n") or warn $status->{out};

# Now we'll test the delays
my $delay = 3;
$status = recover(
                dir => './tmp', 
              delay => $delay,
             action => $action,
            service => 'ftpd',

);
    
ok($status->{level} == 4);

sleep 1;
$status = recover(
                dir => './tmp', 
              delay => $delay,
             action => $action,
            service => 'ftpd',

);
ok($status->{level} == 4);


sleep $delay;
$status = recover(
                dir => './tmp', 
              delay => $delay,
             action => $action,
            service => 'ftpd',

);
ok($status->{level} == 1) or warn $status->{level};
