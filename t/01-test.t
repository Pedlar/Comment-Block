use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Comment::Block;
use Test::Block;
use Test::More;

{
    package Test::Block2;

    sub test {
        #/*
            return 0;
        #*/
            return 1;
    }
}

#/*
    ok(0, "Comment was called when it shouldn't of been"); 
#*/

ok(1, "Code outside of comment runs find");

ok(Test::Block::test(), "Namespaces clean");
ok(Test::Block2::test(), "Namespace in multi file Packages not clean");

my $eval_check = eval {
    sub test {
#/*
        return 0;
#*/
        return 1;
    }
    test();
};

my $do_check = do {
    sub test2 {
#/*
        return 0;
#*/
        return 1;
    }
    test2();
};

ok($eval_check, "Eval was 1, not 0");
ok($do_check, "Do block was 1, not 0");
done_testing;
