
package MSPfunc;

$VERSION = "0.06";

use Global;
use MSPfuncparse;
use MSPea;
@ISA = qw(MSPfuncparse MSPea );

if (defined $::toolbus) {
    if (! eval {require "BI_TB.pm"}) {
        die "module BI_TB not found\n";
    }
    unshift @ISA, qw( BI_TB );
} else {
    if (! eval {require "MSPfunccore.pm"}) {
        die "module MSPfunccore not found\n";
    }
    unshift @ISA, qw( MSPfunccore );
}

if (defined $::id) {
    $ID = $::id;
} else {
    $ID = '';
}
my $mypc = "_pc${ID}";
my $mystack = "_P${ID}stack";

sub Print {
    my $self = shift;
    my @i = @_;
    my $opc;
    my $f;
    my $p;
    my $t;
    my $s;
    my $r;

    $opc = shift @i;
#    print "$opc(" . join(", ", @i) . ")";
    if ($opc eq 'FUNCTION') {
	$f = shift @i;
	$s = pop @i;
	$t = pop @i;
	if ($t ne "") {
	    $t = ":$t";
	}
	$p = join(', ', @i);
	return "function $f($p)$t $s";
    } elsif ($opc eq 'CALL') {
	$f = shift @i;
#	$p = shift @i;
	$p = join(', ', @i);
	return "$f($p)";
    } elsif ($opc eq 'CALLR') {
	$r = shift @i;
	$f = shift @i;
#	$p = shift @i;
	$p = join(', ', @i);
	return "$r = $f($p)";
    } elsif ($opc eq 'FUNCRETURN') {
	$r = shift @i;
	return "return $r";
    } elsif ($opc eq 'SETFUNCRETURN') {
	$r = shift @i;
	$s = shift @i;
	return "setreturn $r $s";
    } elsif ($opc eq 'GETFUNCRETURN') {
	$r = shift @i;
	$s = shift @i;
	return "getreturn $r $s";
    } elsif ($opc eq 'ADDTYPEPAR') {
	$r = shift @i;
	$s = shift @i;
	$t = join(',', @i);
	return "addpar $r $s $t";
    } elsif ($opc eq 'BINDPAR') {
	$r = shift @i;
	$s = shift @i;
	$t = join(',', @i);
	return "bindpar $r $s $t";
    } elsif ($opc eq 'BINDPARSTR') {
	$r = shift @i;
	$s = shift @i;
	$t = shift @i;
	return "bindparstr $r $s $t";
    } else {
	return $self->SUPER::Print($opc, @i);
    }
}

sub EvalBasic {
    my $self = shift;
    my $b;
    my @i;
    my $r;

    if ($self->Exec('MEMBER', "${mypc}.basic", 'call')) {
	$self->Exec('SETREF', "_P${ID}eval", "${mypc}.basic.call.func");
	$self->Exec('PUSH', $mystack, $mypc);
	$self->Exec('BINDPARSTR', $mystack, "_P${ID}eval", "${mypc}.basic.call.args");
	$r = $self->EvalProgram("_P${ID}eval");
	if ($self->evalstop()) {
	    return $r;
	}
	if ($self->Exec('MEMBER', "${mystack}.item.basic.call", 'ret')) {
	    if (! $self->Exec('GETFUNCRETURN', $mystack, "${mystack}.item.basic.call.ret")) {
		$r = 0;
	    }
	}
	$self->Exec('POP', $mystack, $mypc);
	$self->Exec('ASSIGN', "_P${ID}eval", 'null');
	return $r;
    } elsif ($self->Exec('MEMBER', "${mypc}.basic", 'return')) {
	return $self->Exec('SETFUNCRETURN', $mystack, "${mypc}.basic.return");
    } else {
	return $self->SUPER::EvalBasic();
    }
}

sub Exec {
    my $self = shift;
    my @i = @_;
    my $opc;
    my $f;
    my $s;
    my $t;
    my $r;
    my $rd;
    my $p;

    $opc = shift @i;
    if ($opc eq 'FUNCTION') {
	$f = shift @i;
	$s = pop @i;
	$t = pop @i;
	$s = ProperValue($s);
	if ($main::lang eq 'PGLEc') {
	    $r = $self->Exec('COMPILE-PGLEc', "$f", "$s");
	} else {
	    $rd = $self->Exec('VALASSIGN', "$f", "$s", 'str');
	    $r = $self->Exec('COMPILE', "$f");
	}
	$rd = $self->Exec('ADDTYPEPAR', $f, $t, @i);
	return $r;
    } elsif ($opc eq 'CALL') {
	$f = shift @i;
	$rd = $self->Exec('PUSH', $mystack, $mypc);
	$r = $self->Exec('BINDPAR', $mystack, $f, @i);
	if (! $r) {
	    return 0;
	}
	$r = $self->EvalProgram($f);
	$rd = $self->Exec('POP', $mystack, $mypc);
	return $r;
    } elsif ($opc eq 'CALLR') {
	$ret = shift @i;
	$f = shift @i;
	$rd = $self->Exec('PUSH', $mystack, $mypc);
	$r = $self->Exec('BINDPAR', $mystack, $f, @i);
	if (! $r) {
	    return 0;
	}
	$r = $self->EvalProgram($f);
	if (! $r) {
	    return 0;
	}
	$r = $self->Exec('ASSIGN', $ret, "${mystack}.return");
	$rd = $self->Exec('POP', $mystack, $mypc);
	return $r;
    } else {
	unshift @i, $opc;
	return $self->SUPER::Exec(@i);
    }
}
1;
