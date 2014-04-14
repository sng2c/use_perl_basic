% Perl 바로쓰기 1/2
% 김현승
% 2014-04-14

## Perl 바로쓰기 1/2

* perl 버전의 확인
* Core 모듈들
* 파이프의 사용
* 입출력 가공하기
* 다른 프로그램 실행하기

----

### perl의 기초는 

[2시간 반만에 펄 익히기](http://qntm.org/files/perl/perl_kr.html)

----

### 버전과 위치
```bash
$ perl -v

This is perl, v5.8.8 built for i386-linux-thread-multi

Copyright 1987-2006, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.

$ which perl
/usr/bin/perl

$
```

----

### Core모듈 확인 방법

* [perl 5.8.8](http://perldoc.perl.org/5.8.8/index.html)
* Core 모듈은 배포 버전에 기본적으로 들어있는 모듈들이다.
* Site 모듈은 직접 make로 빌드하여 설치하거나, cpan/cpanm 등을 이용하여 설치한다. 
    * [MetaCPAN](https://metacpan.org/)

----

#### 유용한 코어모듈들
* **C**
    * [Carp](http://perldoc.perl.org/5.8.8/Carp.html) : 예외를 던졌을때 Stack Trace를 볼수 있다.
    * [CGI](http://perldoc.perl.org/5.8.8/CGI.html)  : 기본적인 CGI 모듈
    * [Cwd](http://perldoc.perl.org/5.8.8/Cwd.html)  : 현재디렉토리의 경로나 특정 파일의 절대 경로등을 얻을 수 있다.
* **D**
    * [Data::Dumper](http://perldoc.perl.org/5.8.8/Data/Dumper.html) : 데이터를 덤프해서 볼때 유용하다.
    * [Digest::MD5](http://perldoc.perl.org/5.8.8/Digest/MD5.html)  : MD5 해시를 만들어 낸다.
* **E**
    * [Encode](http://perldoc.perl.org/5.8.8/Encode.html) : 문자열 인코딩을 변경시켜준다.

----

* **G**
    * [Getopt::Long](http://perldoc.perl.org/5.8.8/Getopt/Long.html) : 프로그램이 실행될 때 넣는 커맨드라인 명령들을 편리하게 정의할 수 있게 해준다.
* **I**
    * [IO::Select](http://perldoc.perl.org/5.8.8/IO/Select.html)   : 2개 이상의 입출력을 동시에 모니터링할때 사용한다.
* **M**
    * [MIME::Base64](http://perldoc.perl.org/5.8.8/MIME/Base64.html) : Base64 인코딩/디코딩 모듈
* **T**
    * [Term::ANSIColor](http://perldoc.perl.org/5.8.8/Term/ANSIColor.html) : 터미널에 컬러값을 출력해준다.

----

### 파이프

* IPC(Inter Process Communication)의 방법중 하나
* 프로그램의 출력을 다른 프로그램의 입력으로 연결함으로써
* 작은 여러개의 프로그램을 조합하여 출력결과를 가공하는데 사용

----

#### 파이프로 스트림 받기

* 파이프( `|` ) 로 데이터를 받는다는 것은 표준입력을 읽는다는 것이다.
* 그래서 STDIN 을 읽어서 처리하면 된다.
* <파일핸들> 은 줄단위의 데이터가 입력되면, \n을 포함한 문자열이 리턴된다. 단, EOF(End Of File)가 감지되면 undef를 리턴한다.

----

stdin.pl
```perl
#!/usr/bin/env perl
use strict;

my $line;
while( $line = <STDIN> ) # 줄단위의 데이터가 들어올 때까지 Block 된다.
{
    chomp($line);
    print ">> $line\n";
}
```

----

Output : 키보드 입력

```bash
$ perl stdin.pl
(대기중... 아래글을 입력)
HELLO
>> HELLO
^D
$ 
```

* 표준입력이 PIPE로 주어지지 않는다면, Ctrl+D를 입력하기 전까지는 루프를 무한정 돌게 된다.
* Ctrl+D는 EOF를 의미한다. 
* Windows에서는 Ctrl+Z 이다.

----

Output : 파이프 입력

```bash
$ echo "hello there" | perl stdin.pl
>> hello there
$
```

* 파이프로 연결되면, 선행하는 명령이 종료될 때, EOF를 감지하게 되어 루프를 종료하게 된다.

----

#### 파이프로 스트림 내보내기

* 파이프로 스트림을 내보내는 것은 STDOUT으로 출력한다는 의미이다. 그래서 print 또는 print STDOUT 을 이용한다.
* STDERR을 이용해도 화면에 출력할 수 있다.
* 보통 스크립트는 파일에 바로 쓰는 것보다는 STDOUT으로 출력하도록 만드는 것이 간편하다.

----

stdout.pl

```perl
#!/usr/bin/env perl
use strict;

print "Hello STDOUT\n";

print STDOUT "Hello STDOUT\n";

print STDERR "Hello STDERR\n"
```

----

Output : 화면출력

```bash
$ perl stdout.pl
Hello STDOUT
Hello STDOUT
Hello STDERR
$ 
```

* 화면상에는 셋 다 출력 된다.

---

Output : 출력 리디렉션 1

```bash
$ perl stdout.pl > output.txt
Hello STDERR

$ cat output.txt
Hello STDOUT
Hello STDOUT
```

* `>` 로 출력을 파일로 돌려보면 STDERR로 출력한 것만 여전히 화면으로 나온다.


--- 

Output : 출력 리디렉션 2

```bash
$ perl stdout.pl 1>output.txt 2>error.txt

$ cat output.txt
Hello STDOUT
Hello STDOUT

$ cat error.txt
Hello STDERR
```

* `1>` 은 STDOUT,
* `2>` 은 STDERR 을 의미하고 각각 다른 파일로 보낼수 있다. 

---

Output : 출력 리디렉션 3

```bash
$ perl stdout.pl 2>&1 > output.txt
$ cat output.txt
Hello STDOUT
Hello STDOUT
Hello STDERR
$ 
```

* `2>&1` 과 같이 하면 STDERR 출력이 STDOUT으로 취급된다.

----

#### 한줄로 코딩하기

* 서버 작업에서는 한번 쓰고 버리는 스크립트를 작성하는 경우가 자주 있다.
* 파이프로 받은 값을 임시로 처리하는 경우에 자주 사용하게 된다.
* 스크립트 파일을 만들지 않고 한줄에 스크립트를 짜보자. 이를 원-라이너(One-liner) 라고 부르기도 한다.
* Bash에 의해서 $var 등이 해석되지 않게 `'`(작은따옴표)로 감싸자.

----

글자 출력

```bash
$ perl -e ' print "Hello World\n" '
Hello World
```

----

파이프 입력값처리

```bash
$ ls -l | perl -e 'while($line = <STDIN>){ print $line; }'
total 8
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 sng2c  staff  2840  4 12 16:07 usePerl_basic.md
```

----

```bash
$ ls -l | perl -e 'while(<>){ print $_; }'
total 8
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 sng2c  staff  2840  4 12 16:07 usePerl_basic.md
```

* while(<>)은 while( $_ = <STDIN> ) 의 축약형이다.

----

```bash
$ ls -l | perl -ne 'print $_;'
total 8
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 sng2c  staff  2840  4 12 16:07 usePerl_basic.md
```

* -ne 옵션을 사용하면 while(<>){ ... } 을 자동으로 감싸준다.

----


### 입출력결과 다듬기

* 가독성을 높이기 위해서 스크립팅을 통해 입력결과를 가공하여 출력해보자 

----

#### 특정 글자 바꾸기

replace.pl

```perl
#!/usr/bin/env perl
use strict;

while( my $line = <STDIN> ){
    chomp($line);
    $line =~ s/sng2c/내꺼/g;
    print $line . "\n";
}
```

* $line =~ s/패턴/대체문자열/g; : `$line` 에서 `패턴`을 찾아 `대체문자열`로 `모두(g)` `바꿔침( =~ s/// )`.
    * 패턴
        * 그냥 문자열 "sng2c"
    * 대체문자열
        * "내꺼"

----

Output

```bash
$ ls -l .. | perl replace.pl
total 16
drwxr-xr-x  3 내꺼  staff   102  4 13 01:25 split
drwxr-xr-x  3 내꺼  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 내꺼  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 내꺼  staff  4956  4 13 01:14 usePerl_basic.md
$
```

----

#### 원하는 필드만 보기

* `ps -ef` 나 `ls -l` 등의 출력결과가 테이블 형태인 프로그램을 실행하고 원하는 필드만 정리해야할 경우가 자주 있다.
* 필드간에는 WhiteSpace 즉, 공백이 채워져 있으므로, 공백을 기준으로 자른다.

----

split.pl

```perl
#!/usr/bin/env perl
use strict;

while( my $line = <STDIN> ){
    chomp($line);
    my @cols = split(/\s+/, $line);

    print "$cols[0] $cols[1] $cols[2]\n";
}
```

* perl 에는 $scalar, @array, %hash 의 3가지 기본 자료형이 있다.
* $cols[0] $cols[1] $cols[2] ... 와 같이 @cols는 $cols[인덱스] 의 형태로 사용한다.
* 마지막 인덱스는 (@cols-1) 으로 얻을수 있다.

----

마지막 인자 출력해보기
```perl
    my $last = $cols[ @cols-1 ];
    print "$cols[0] $cols[1] $last\n"; # 복잡한 연산자가 "" 안에 들어가게 하지 말자
```

----

Output

```bash
$ ls -l ..
total 16
drwxr-xr-x  3 sng2c  staff   102  4 13 01:25 split
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 sng2c  staff  4956  4 13 01:14 usePerl_basic.md

$ ls -l .. | perl split.pl 
total 16 
drwxr-xr-x 3 sng2c
drwxr-xr-x 3 sng2c
drwxr-xr-x 3 sng2c
-rw-r--r--@ 1 sng2c
```

----

One Line

```bash
$ ls -l .. | perl -ane 'print "$F[0] $F[1] $F[2]\n"'
total 16 
drwxr-xr-x 3 sng2c
drwxr-xr-x 3 sng2c
drwxr-xr-x 3 sng2c
-rw-r--r--@ 1 sng2c
```

* -ane 를 이용하면 각 줄을 @F에 공백을 기준으로 잘라서 담아둔다.

----

#### 원하는 곳 색상넣기

* Perl의 Term::ANSIColor 모듈을 이용하여 컬러풀한 출력을 만들 수 있다. 가독성을 높여 생산성을 올릴 수 있다.
* 참고 : [http://perldoc.perl.org/5.8.8/Term/ANSIColor.html](http://perldoc.perl.org/5.8.8/Term/ANSIColor.html)

----

##### 컬러출력

color_print.pl

```perl
#!/usr/bin/env perl
use strict;
use Term::ANSIColor;

print color('yellow') . "노란색\n" . color('reset');

print color('red') . "빨간색\n" . color('reset');

print color('blink blue') . "파란색깜빡\n" . color('reset');
```

* 원하는 색을 모두 표현하고 나면, color('reset') 으로 색을 초기화하도록 해야한다.
* color() 의 지정값 
    * 초기화 : clear, reset
    * 스타일 : dark, bold, underline, underscore, blink, reverse, concealed 
    * 글자색 : black, red, green, yellow, blue, magenta
    * 배경색 : on_black, on_red, on_green, on_yellow, on_blue, on_magenta, on_cyan, on_white

----

##### 컬러로의 치환

* 입력으로 들어온 값의 일부를 찾아서 컬러로 변경한다.

----

color_replace.pl

```perl
#!/usr/bin/env perl
use strict;
use Term::ANSIColor;

my $bold = color('bold green'); # 미리 저장
my $reset = color('reset');

while( my $line = <STDIN> ){
    chomp($line);
    $line =~ s/(\d+)/$bold$1$reset/g;
    print "$line\n";
}
```

* $line =~ s/패턴/대체문자열/g; : `$line` 에서 `패턴`을 찾아 `대체문자열`로 `모두(g)` `바꿔침( =~ s/// )`.
    * 패턴
        * (\d+) : 숫자의 연속, 매칭 그룹
    * 대체문자열
        * $bold 
        * $1    : 1번 매칭 그룹
        * $reset

---

Output

```bash
$ ls -l | perl color_replace.pl

... 칼라풀 출력 결과 ...

```

----

One Line

```bash
$ ls -l | perl -MTerm::ANSIColor -ne '$bold=color("bold green");$reset=color("reset");$_ =~ s/(\d+)/$bold$1$reset/g; print $_'

... 칼라풀 출력 결과 ...

```

### 다른 명령 실행하기

----

#### 출력내용을 캡쳐할 필요가 없을 때

```perl
#!/usr/bin/env perl
use strict;
system( 'ls -l' );
```

----

#### 출력내용을 캡쳐할 때

```perl
#!/usr/bin/env perl
use strict;
my $output = `ls -l`; # `(backtick) 으로 감싼다.
print $output."\n";
```

----

#### 다른 프로그램을 실행하며 종료할 때

```perl
#!/usr/bin/env perl
use strict;
exec('ls -l');
die "exec FAIL!!!";
```

----


### 정리

* perl 버전의 확인
* Core 모듈들
* 파이프의 사용
* 입출력 가공하기


----

###  Q & A

----

###  감사합니다
