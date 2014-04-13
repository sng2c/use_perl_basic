# Perl 바로쓰기 기초

## 설치된 Perl의 버전

Perl을 바로 쓰기 위해서는 버전을 정확히 확인하고, Core 모듈중 어떤것이 사용가능한지 파악해야 한다.

최근 리눅스들은 5.18 버전등도 사용하지만, 우리 회사의 서버들은 거의 5.8 버전대가 대다수일 것이다.

그래서 5.8 버전에 호환되게 스크립트를 작성하는 것이 중요하다.

### 버전과 위치 확인하기
```
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

### Core모듈 확인 방법

* [perl 5.8.8](http://perldoc.perl.org/5.8.8/index.html)
* Core 모듈은 배포 버전에 기본적으로 들어있는 모듈들이다.
* Site 모듈은 직접 make로 빌드하여 설치하거나, cpan/cpanm 등을 이용하여 설치한다. 
    * [MetaCPAN](https://metacpan.org/)


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
* **G**
    * [Getopt::Long](http://perldoc.perl.org/5.8.8/Getopt/Long.html) : 프로그램이 실행될 때 넣는 커맨드라인 명령들을 편리하게 정의할 수 있게 해준다.
* **I**
    * [IO::Select](http://perldoc.perl.org/5.8.8/IO/Select.html)   : 2개 이상의 입출력을 동시에 모니터링할때 사용한다.
* **M**
    * [MIME::Base64](http://perldoc.perl.org/5.8.8/MIME/Base64.html) : Base64 인코딩/디코딩 모듈
* **T**
    * [Term::ANSIColor](http://perldoc.perl.org/5.8.8/Term/ANSIColor.html) : 터미널에 컬러값을 출력해준다.

## 파이프

* IPC(Inter Process Communication) 의 한 방법인 파이프 통신은,
* 한 프로그램의 출력을 다른 프로그램의 입력으로 연결함으로써
* 작은 여러개의 프로그램을 조합하여 출력결과를 가공하는데 사용된다.

### 파이프로 스트림 받기

* 파이프( `|` ) 로 데이터를 받는다는 것은 표준입력을 읽는다는 것이다.
* 그래서 STDIN 을 읽어서 처리하면 된다.
* <파일핸들> 은 줄단위의 데이터가 입력되면, \n을 포함한 문자열이 리턴된다. 단, EOF(End Of File)가 감지되면 undef를 리턴한다.

----

_stdin.pl_
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

_Output : 키보드 입력_

```
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

_Output : 파이프 입력_

```
$ echo "hello there" | perl stdin.pl
>> hello there
$
```

* 파이프로 연결되면, 선행하는 명령이 종료될 때, EOF를 감지하게 되어 루프를 종료하게 된다.

### 파이프로 스트림 내보내기

* 파이프로 스트림을 내보내는 것은 STDOUT으로 출력한다는 의미이다. 그래서 print 또는 print STDOUT 을 이용한다.
* STDERR을 이용해도 화면에 출력할 수 있다.
* 보통 스크립트는 파일에 바로 쓰는 것보다는 STDOUT으로 출력하도록 만드는 것이 간편하다.

----

_stdout.pl_

```perl
#!/usr/bin/env perl
use strict;

print "Hello STDOUT\n";

print STDOUT "Hello STDOUT\n";

print STDERR "Hello STDERR\n"
```

----

_Output : 화면출력_

```
$ perl stdout.pl
Hello STDOUT
Hello STDOUT
Hello STDERR
$ 
```

* 화면상에는 셋 다 출력 된다.

---

_Output : 출력 리디렉션 1_
```
$ perl stdout.pl > output.txt
Hello STDERR

$ cat output.txt
Hello STDOUT
Hello STDOUT
```

* `>` 로 출력을 파일로 돌려보면 STDERR로 출력한 것만 여전히 화면으로 나온다.


--- 

_Output : 출력 리디렉션 2_
```
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

_Output : 출력 리디렉션 3_

```
$ perl stdout.pl 2>&1 > output.txt
$ cat output.txt
Hello STDOUT
Hello STDOUT
Hello STDERR
$ 
```

* `2>&1` 과 같이 하면 STDERR 출력이 STDOUT으로 취급된다.

### 한줄로 코딩하기

* 서버 작업에서는 한번 쓰고 버리는 스크립트를 작성하는 경우가 자주 있다.
* 파이프로 받은 값을 임시로 처리하는 경우에 자주 사용하게 된다.
* 스크립트 파일을 만들지 않고 한줄에 스크립트를 짜보자. 이를 원-라이너(One-liner) 라고 부르기도 한다.
* Bash에 의해서 $var 등이 해석되지 않게 `'`(작은따옴표)로 감싸자.

----

_글자 출력_

```
$ perl -e ' print "Hello World\n" '
Hello World
```

----

_파이프 입력값처리_

```
$ ls -l | perl -e 'while($line = <STDIN>){ print $line; }'
total 8
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 sng2c  staff  2840  4 12 16:07 usePerl_basic.md
```

----

```
$ ls -l | perl -e 'while(<>){ print $_; }'
total 8
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 sng2c  staff  2840  4 12 16:07 usePerl_basic.md
```

* while(<>)은 while( $_ = <STDIN> ) 의 축약형이다.

----

```
$ ls -l | perl -ne 'print $_;'
total 8
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 sng2c  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 sng2c  staff  2840  4 12 16:07 usePerl_basic.md
```

* -ne 옵션을 사용하면 while(<>){ ... } 을 자동으로 감싸준다.

----


## 입출력결과 다듬기

* 가독성을 높이기 위해서 스크립팅을 통해 입력결과를 가공하여 출력해보자 

### 특정 글자 바꾸기

_replace.pl_

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

_Output_

```
$ ls -l .. | perl replace.pl
total 16
drwxr-xr-x  3 내꺼  staff   102  4 13 01:25 split
drwxr-xr-x  3 내꺼  staff   102  4 12 22:30 stdin
drwxr-xr-x  3 내꺼  staff   102  4 12 22:30 stdout
-rw-r--r--@ 1 내꺼  staff  4956  4 13 01:14 usePerl_basic.md
$
```

### 원하는 필드만 보기

* `ps -ef` 나 `ls -l` 등의 출력결과가 테이블 형태인 프로그램을 실행하고 원하는 필드만 정리해야할 경우가 자주 있다.
* 필드간에는 WhiteSpace 즉, 공백이 채워져 있으므로, 공백을 기준으로 자른다.

----

_split.pl_

```perl
#!/usr/bin/env perl
use strict;

while( my $line = <STDIN> ){
    chomp($line);
    my @cols = split(/\s+/, $line);

    print "$cols[0] $cols[1] $cols[2]\n";
}
```
>
> perl 에는 $scalar, @array, %hash 의 3가지 기본 자료형이 있다.
> * $cols[0] $cols[1] $cols[2] ... 와 같이 @cols는 $cols[인덱스] 의 형태로 사용한다.
> * 마지막 인덱스는 (@cols-1) 으로 얻을수 있다.
>

_마지막 인자 출력해보기_
```perl
    my $last = $cols[ @cols-1 ];
    print "$cols[0] $cols[1] $last\n"; # 복잡한 연산자가 "" 안에 들어가게 하지 말자
```

----

_Output_

```
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

_One Line_

```
$ ls -l .. | perl -ane 'print "$F[0] $F[1] $F[2]\n"'
total 16 
drwxr-xr-x 3 sng2c
drwxr-xr-x 3 sng2c
drwxr-xr-x 3 sng2c
-rw-r--r--@ 1 sng2c
```

* -ane 를 이용하면 각 줄을 @F에 공백을 기준으로 잘라서 담아둔다.

### 원하는 곳 색상넣기

* Perl의 Term::ANSIColor 모듈을 이용하여 컬러풀한 출력을 만들 수 있다. 가독성을 높여 생산성을 올릴 수 있다.
* 참고 : http://perldoc.perl.org/5.8.8/Term/ANSIColor.html

#### 컬러출력

_color_print.pl_

```perl
#!/usr/bin/env perl
use strict;
use Term::ANSIColor;

print color('yellow') . "노란색\n" . color('reset');

print color('red') . "빨간색\n" . color('reset');

print color('blink blue') . "파란색깜빡\n" . color('reset');
```

* color() 은 color값을 지정하는 ANSI컨트롤 문자를 리턴한다.
* 원하는 색을 모두 표현하고 나면, color('reset') 으로 색을 초기화하도록 해야한다.
* color() 의 지정값 
    * 초기화 : clear, reset
    * 스타일 : dark, bold, underline, underscore, blink, reverse, concealed 
    * 글자색 : black, red, green, yellow, blue, magenta
    * 배경색 : on_black, on_red, on_green, on_yellow, on_blue, on_magenta, on_cyan, on_white

----

#### 컬러로의 치환

* 입력으로 들어온 값의 일부를 찾아서 컬러로 변경한다.

_color_replace.pl_

```
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

_Output_

```
$ ls -l | perl color_replace.pl

... 칼라풀 출력 결과 ...

```

----

_One Line_

```
$ ls -l | perl -MTerm::ANSIColor -ne '$bold=color("bold green");$reset=color("reset");$_ =~ s/(\d+)/$bold$1$reset/g; print $_'

... 칼라풀 출력 결과 ...

```

## 다른명령 실행하기


### 출력내용을 캡쳐할 필요가 없을 때

```perl
system( 'ls -l' );
```

### 출력내용을 캡쳐할 때

```perl
my $output = `ls -l`; # `(backtick) 으로 감싼다.
```

### 다른 프로그램을 실행하며 종료할 때

```perl
exec('ls -l');
```

## 파일다루기

### 파일 테스트

* 참고 : http://perldoc.perl.org/5.8.8/functions/-X.html

_File Attr_

```perl

my $path = 'path';

if( -e $path ){
    print "$path exists";    
}

if( -d $path ){
    print "$path is dir";
}

if( -s $path > 0 ){
    print "size of $path is ".(-s $path);    
}
```

### 파일 읽기

_read_file.pl_

```perl
#!/usr/bin/env perl
use strict;
open FILE, '<', 'data.txt';

while( my $line = <FILE> ){
    chomp($line);
    
    # 한줄씩 처리
    print ">> $line\n";
}
close(FILE);
```

----

_read_file2.pl_

```perl
#!/usr/bin/env perl
use strict;
open FILE, '<', 'data.txt';
my @lines = <FILE>; # 메모리 걱정이 없다면 간편하게~
close(FILE);


foreach my $line (@lines){
    chomp($line);

    # 한줄씩 처리
    print ">> $line\n";
}
```

----

>
> * Perl의 함수는 문맥에 따라 함수의 리턴값이 달라질 수 있다.
>     * 함수내에서 wantarray()를 이용하여 
>     * 힘수가 불린곳이 Scalar 문맥에 있는지 Array 문맥에 있는지 알수 있다.
>     * $line = <FILE> 은 좌변이 Scalar 이므로 `한줄씩` 읽어 리턴하고,
>     * @line = <FILE> 은 좌변이 Array 이므로 `끝까지` 읽어 배열로 리턴한다.
>

### 파일 쓰기

_write_file.pl_

```perl
#!/usr/bin/env perl
use strict;
open FILE, '>', 'output.txt';
print FILE "Hello File!!\n";
close(FILE);
```

----

_Output_

```
$ perl write_file.pl
$ cat output.txt
Hello File!!
$ 
```

----

_write_file2.pl_

```perl
#!/usr/bin/env perl
use strict;
open FILE, '>>', 'output.txt'; # APPEND 모드
print FILE "Hello File Again!!\n";
close(FILE);
```

----

_Output_

```
$ perl write_file.pl
$ perl write_file2.pl
$ cat output.txt
Hello File!!
Hello File Again!!
$ 
```

### 파일의 삭제

```perl

unlink($file);
```

### 파일의 이동 또는 이름변경

```perl

rename($before_path , $after_path);
```


## 설정파일 다루기

_config_install.sh_

```bash
mkdir -p lib/Config
curl 'http://api.metacpan.org/source/SALVA/Config-Properties-1.76/lib/Config/Properties.pm' > lib/Config/Properties.pm

mkdir -p lib/JSON/PP
curl 'http://api.metacpan.org/source/MAKAMAKA/JSON-PP-2.27203/lib/JSON/PP.pm' > lib/JSON/PP.pm
curl 'http://api.metacpan.org/source/MAKAMAKA/JSON-PP-2.27203/lib/JSON/PP/Boolean.pm' > lib/JSON/PP/Boolean.pm

```

* Perl의 모듈은 XS 모듈과 PurePerl 모듈이 있다.
* PurePerl 모듈은 단순히 복사하는 것만으로도 사용이 가능한다.

### .properties

* 참고 : https://metacpan.org/pod/Config::Properties

----

_props.properties_

```
my.test.name=KHS
my.test.message=Hello
```

----

_props.pl_

```perl
#!/usr/bin/env perl
use strict;
use lib './lib';
use Config::Properties;
use Data::Dumper;

#read
my $props = Config::Properties->new(file=>'props.properties');
my %all = $props->properties; # 전체 
print Dumper \%all;

my $name = $props->getProperty('my.test.name'); # 'KHS'
my $message = $props->getProperty('my.test.message'); # 'Hello'
print $name."\n";
print $message."\n";

#write
my $props2 = Config::Properties->new();
$props2->setProperty('my.test.nick', 'sng2c');

open my $fh, '>' , 'props2.properties';
$props2->store($fh);
close($fh);
```

* use lib './lib';
    * lib 디렉토리를 라이브러리 패스로 지정한다. Config::Properties 모듈이 그 안에 있다.

### .json

_json.json_

```
{
    "my" : {
        "test" : {
            "name" : "KHS",
            "message" : "Hello"
        }
    }
}
```

----

_json.pl_

```perl
#!/usr/bin/env perl
use strict;
use lib './lib';
use JSON::PP;

#read 
open( my $fh, '<', 'json.json' );
my @json_lines = <$fh>;
my $json = join('', @json_lines);

my $obj = decode_json( $json );
print $obj->{my}->{test}->{name} . "\n"; # "KHS"
print $obj->{my}->{test}->{message} . "\n"; # "Hello"

#write
my $obj2 = { my => { test => { nick => 'sng2c' } } };
open( my $fh2, '>', 'out.json');
print $fh2 encode_json( $obj2 );
close($fh2);
```

* encode_json, decode_json 에 사용되는 변수는 모두 Scalar인데,
* 내부에 배열의 참조(Reference)가 들어있다.
* 그래서 $obj{my} 와 같이 쓰지 않고,
* $obj->{my} 와 같이 한번 더 거쳐서 사용하는 듯한 문법을 이용하여 구분한다.


## 디렉토리 탐색

### 디렉토리내의 파일 목록

_dir.pl_

```perl
#!/usr/bin/env perl
use strict;

my @files = glob '../*';

foreach my $file (@files){
    print $file . "\n";
}
```

### 디렉토리 하위 탐색

_dir_tree.pl_

```perl
#!/usr/bin/env perl
use strict;

my $path = '../../*';
my @files = glob $path;

my @stack;
push(@stack,@files);
while( my $f = shift(@stack) ){
    if( -d $f ){
        my @files = glob "$f/*";
        push(@stack,@files);
    }   

    print $f."\n"; # 이 부분에서 각 파일을 처리한다.
}
```

* 너비 우선 탐색으로 지정한 path하위의 모든 파일을 찾는다.

### 디렉토리 하위 탐색 2
    
```
$ find ../.. | perl -ne ' print $_; '
```

* 유사하지만 find 는 숨김파일까지도 찾아낸다.
* 굳이 자료구조 탐색이 필요할까?

## HTTP

### curl 과의 협업

```
$ curl -s 'http://stock.daum.net/item/main.daum?code=035720' | perl xxxx.pl
```

```perl
my $file = `curl -s 'http://stock.daum.net/item/main.daum?code=035720'`;
```

### HTTP 라이브러리의 사용

* HTTP/HTTPS 모듈은 Core 라이브러리가 아니다.
* 심화과정에서 펄모듈을 시스템에 설치하고 관리하는 방법에 대해서 다룬다.
* HTTP 클라이언트 모듈
    * LWP::UserAgent - Full-spec HTTP클라이언트
    * WWW::Mechanize - LWP::UserAgent에 자동화를 위한 속성을 추가한 HTTP클라이언트
    * WWW::Scripter - WWW::Mechanize에 자바스크립트 작동 추가.
    * HTTP::Tiny - 간편한 HTTP클라이언트

## WEB

### CGI 수정하기
CGI를 맞닥뜨리게 되면 어떤 순서로 보아야 할지 알아본다. 

#### CGI의 주요 구성

* perl의 CGI는 보통 아래와 같이 되어있다.

```perl
#!/usr/bin/env perl
use strict;

# 표준입력 및 환경변수에서 요청내용을 파싱하는 부분
use CGI;
my $q = CGI->new();
  # 또는
my $q = new CGI();

# 쿼리내용을 받아오는 부분
my $name = $q->param('name');

# HTTP 헤더를 출력하는 부분
print "Content-type: text/html; charset=UTF-8\n\n";
  # 또는
print $q->header(-charset=>'UTF-8');

# HTTP BODY를 출력하는 부분
print "<html>...</html>";
  # 또는
print <<HTML;
<html>
    <body>
        ... $name ...
    </body>
</html>
HTML

```

* 주의할 점
    * 요청내용의 파싱은 CGI 모듈을 사용하지 않을 수도 있다.
    * HTTP헤더의 출력은 다른 모든 출력에 우선해야한다.
    * 웹서버에게 실행권한이 있어야 한다. 보통 755 또는 775

#### 예제 CGI

_cgi.pl_

```perl
#!/usr/bin/env perl
use strict;

use CGI;

my $q = CGI->new;
my $name = $q->param('name');
my $message = $q->param('message');

print "Content-Type: text/html\n\n";

print <<HTML; # HTML 까지 그대로 출력하기
<html>
    <body>
        $name, $message.
    </body>
</html>
HTML

```

----

_simplehttpd.py_

```python
#!/usr/bin/env python
 
import BaseHTTPServer
import CGIHTTPServer
import cgitb; cgitb.enable()  ## This line enables CGI error reporting
 
server = BaseHTTPServer.HTTPServer
handler = CGIHTTPServer.CGIHTTPRequestHandler
server_address = ("", 8000)
handler.cgi_directories = ["/"]
 
httpd = server(server_address, handler)
httpd.serve_forever()
```

* 파이썬이 설치되어 있을 경우에는 간편히 위의 스크립트를 이용할 수 있다.
* cgi test를 위한 간단한 CGI 서버 스크립트.
* 테스트할 cgi와 같은 디렉토리에서 실행시키고 나서 http://localhost:8000/cgi.pl 을 확인한다.
* 500 에러가 나면 스크립트의 오류

----

### CGI 이외의 WEB

CGI외에도 Perl에는 다양한 특징을 가진 웹 프레임웍등이 있다. 하지만 Core모듈은 아니다.

* FastCGI
* AnyEvent::HTTPD
* Catalyst
* Dancer
* PSGI/Plack
* Mojolicious

## 예약된 작업

### crontab

```
* * * * * cd /daum/log; perl send_log.pl 2>&1 > /dev/null
```

* 바로 절대경로로 실행하기 보다는, 디렉토리로 이동 후 작업을 하도록 한다.
* `분 시 일 월 요일` 순서대로 패턴을 입력한다.
* 장점
    * 사용하기 쉽다.
* 단점
    * 세팅여부를 확인하기가 어렵다.
    * 분 단위로 작동하고, 기존에 실행된 작업이 아직 진행중이더라도 추가로 실행된다.


### 자체타이머의 구현

_my_timer.pl_

```perl
#!/usr/bin/env perl 
use strict;

my $tick=0;
while(1){

    #   0    1    2     3     4    5     6     7     8
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    $year += 1900;
    $mon  += 1;

    # interval
    if( $tick % 10 == 0 ){ # 10초에 한번
        printf('%02d:%02d:%02d ',$hour,$min,$sec);
        print "per 10\n";
    }   

    # schedule
    if( $sec =~ /3$/ || $sec =~ /6$/ || $sec =~ /9$/ ){
        printf('%02d:%02d:%02d ',$hour,$min,$sec);
        print "3 6 9\n";
    }   

    sleep(1); # 1초쉬고
    $tick++;
}
```

----

```
$ (perl my_timer.pl &)
```

* 위와 같이 하면 현재의 터미널 소유에서 벗어나서 백그라운드로 작동하게 된다.

### 백그라운드 작업시 screen과의 협업

* 로그아웃을 하더라도 계속해서 할 필요가 있는 작업들은 screen 명령과 함께 쓰자.
* screen은 작업을 유지한채로 언제든 나중에 다시 연결할 수 있는 가상 쉘이다.

_New Screen_

```
sng2c_mbp:cron sng2c$ screen -R NEW_NAME

bash-3.2$ perl my_timer.pl
...
^ad     
[detached]
```

----

_Attach Screen_

```
sng2c_mbp:cron sng2c$ screen -R NEW_NAME
...
^c
bash-3.2$ exit
[screen is terminating]
```

----

_Run_

```
$ screen -dmS NEW_NAME 'perl my_timer.pl';
```

* -dmS 를 이용하면, 바로 detached 상태로 들어가고, my_timer.pl이 종료되면 알아서 해당 스크린도 사라진다.

----

