% Perl 바로쓰기 2/2
% 김현승
% 2014-04-15

## Perl 바로쓰기 2/2

* 파일다루기
* 설정파일 다루기
* HTTP통신 
* CGI수정
* Crontab
* Screen과의 협업

----

### 파일다루기

* 파일을 읽고 쓰고 체크하는 것은 쉘스크립팅에서 중요한 부분이다. 

----

#### 파일 테스트

* 참고 : http://perldoc.perl.org/5.8.8/functions/-X.html

File 존재여부

```perl
#!/usr/bin/env perl
use strict;
my $path = 'path';

if( -e $path ){
    print "$path exists";    
}
```

----


디렉토리 여부

```perl
#!/usr/bin/env perl
use strict;
my $path = 'path';

if( -d $path ){
    print "$path is dir";
}
```

----

파일 사이즈

```perl
#!/usr/bin/env perl
use strict;
my $path = 'path';

if( -s $path > 0 ){
    print "size of $path is ".(-s $path);    
}
```

----


#### 파일 읽기

read_file.pl

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

read_file2.pl

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


* Perl의 함수는 문맥에 따라 함수의 리턴값이 달라질 수 있다.
    * 함수내에서 wantarray()를 이용하여 
    * 함수가 불린곳이 Scalar 문맥에 있는지 Array 문맥에 있는지 알수 있다.
        * $line = <FILE> 은 좌변이 Scalar 이므로 `한줄씩` 읽어 리턴하고,
        * @line = <FILE> 은 좌변이 Array 이므로 `끝까지` 읽어 배열로 리턴한다.

----

#### 파일 쓰기

write_file.pl

```perl
#!/usr/bin/env perl
use strict;
open FILE, '>', 'output.txt';
print FILE "Hello File!!\n";
close(FILE);
```

----

Output

```bash
$ perl write_file.pl
$ cat output.txt
Hello File!!
$ 
```

----

write_file2.pl

```perl
#!/usr/bin/env perl
use strict;
open FILE, '>>', 'output.txt'; # APPEND 모드
print FILE "Hello File Again!!\n";
close(FILE);
```

----

Output

```bash
$ perl write_file.pl
$ perl write_file2.pl
$ cat output.txt
Hello File!!
Hello File Again!!
$ 
```

----

#### 파일의 삭제

```perl
unlink($file);
```

----

#### 파일의 이동 또는 이름변경

```perl
rename($before_path , $after_path);
```


----

### 설정파일

----

#### PurePerl 모듈의 설치 Bash 스크립트

config_install.sh

```bash
#!/bin/sh

mkdir -p lib/Config
curl 'http://api.metacpan.org/source/SALVA/Config-Properties-1.76/lib/Config/Properties.pm' > lib/Config/Properties.pm

mkdir -p lib/JSON/PP
curl 'http://api.metacpan.org/source/MAKAMAKA/JSON-PP-2.27203/lib/JSON/PP.pm' > lib/JSON/PP.pm
curl 'http://api.metacpan.org/source/MAKAMAKA/JSON-PP-2.27203/lib/JSON/PP/Boolean.pm' > lib/JSON/PP/Boolean.pm

```

* Perl의 모듈은 XS 모듈과 PurePerl 모듈이 있다.
* PurePerl 모듈은 단순히 복사하는 것만으로도 사용이 가능한다.

----

#### .properties

* 참고 : https://metacpan.org/pod/Config::Properties

----

props.properties

```
my.test.name=KHS
my.test.message=Hello
```

----

props.pl

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
```

----

```perl
#write
my $props2 = Config::Properties->new();
$props2->setProperty('my.test.nick', 'sng2c');

open my $fh, '>' , 'props2.properties';
$props2->store($fh);
close($fh);
```

* use lib './lib';
    * lib 디렉토리를 라이브러리 패스로 지정한다. Config::Properties 모듈이 그 안에 있다.


----

#### .json

json.json

```json
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

json.pl

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
```

----

```perl
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

----

### 디렉토리 탐색

----

#### 디렉토리내의 파일 목록

dir.pl

```perl
#!/usr/bin/env perl
use strict;

my @files = glob '../*';

foreach my $file (@files){
    print $file . "\n";
}
```

----

#### 디렉토리 하위 탐색

dir_tree.pl

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

----

#### 디렉토리 하위 탐색 2
    
```bash
$ find ../.. | perl -ne ' print $_; '
```

* 유사하지만 find 는 숨김파일까지도 찾아낸다.
* 굳이 자료구조 탐색이 필요할까?

----

### HTTP

----

#### curl 과의 협업

GET 쿼리
```bash
$ curl -s 'http://stock.daum.net/item/main.daum?code=035720' | perl xxxx.pl

$ wget -q -O - 'http://stock.daum.net/item/main.daum?code=035720' | perl xxxx.pl
```

POST 쿼리
```bash
$ curl --data "param1=value1&param2=value2" 'http://POST_RECEIVE_URL'
```

* 쉘스크립팅을 하면서 HTTP쿼리를 일일이 조립하는 것은 시간낭비인 경우가 많다.
* curl 명령등의 전용 프로그램을 이용하여 결과 처리에만 집중한다.

---

```perl
#!/usr/bin/env perl
use strict;
my $html = `curl -s 'http://stock.daum.net/item/main.daum?code=035720'`;

...
```

* 물론 perl 소스코드에서도 curl을 이용하면 간편하다.

----

#### HTTP 라이브러리의 사용

* 심화과정에서 펄모듈을 시스템에 설치하고 관리하는 방법에 대해서 다룬다.
* HTTP/HTTPS 모듈은 Core 라이브러리가 아니다.
* HTTP 클라이언트 모듈
    * LWP::UserAgent - Full-spec HTTP클라이언트
    * WWW::Mechanize - LWP::UserAgent에 자동화를 위한 속성을 추가한 HTTP클라이언트
    * WWW::Scripter - WWW::Mechanize에 자바스크립트 작동 추가.
    * HTTP::Tiny - 간편한 HTTP클라이언트

----

### WEB

----

#### CGI 수정하기

CGI를 맞닥뜨리게 되면 어떤 순서로 보아야 할지 알아본다. 

----

##### CGI의 주요 구성

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
```

----

```perl
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

----

* 주의할 점
    * 요청내용의 파싱은 CGI 모듈을 사용하지 않을 수도 있다.
    * HTTP헤더의 출력은 다른 모든 출력에 우선해야한다.
    * 웹서버에게 실행권한이 있어야 한다. 보통 755 또는 775

----

##### 예제 CGI

cgi.pl

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

simplehttpd.py

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

#### CGI 이외의 WEB 1

CGI외에도 Perl에는 다양한 특징을 가진 웹 프레임웍등이 있다. 하지만 Core모듈은 아니다.

* FastCGI
* AnyEvent::HTTPD
* Catalyst

----

#### CGI 이외의 WEB 2

CGI외에도 Perl에는 다양한 특징을 가진 웹 프레임웍등이 있다. 하지만 Core모듈은 아니다.

* Dancer
* PSGI/Plack
* Mojolicious

----

### 예약된 작업

----

#### crontab 1

```crontab
* * * * * cd /daum/log; perl send_log.pl 2>&1 > /dev/null
```

* 바로 절대경로로 실행하기 보다는, 디렉토리로 이동 후 작업을 하도록 한다.
* `분 시 일 월 요일` 순서대로 패턴을 입력한다.

----

#### crontab 2

```crontab
* * * * * cd /daum/log; perl send_log.pl 2>&1 > /dev/null
```

* 장점
    * 사용하기 쉽다.
* 단점
    * 세팅여부를 확인하기가 어렵다.
    * 분 단위로 작동하고, 기존에 실행된 작업이 아직 진행중이더라도 추가로 실행된다.

----

#### 자체타이머의 구현

my_timer.pl

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
```

----

```perl
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

----

#### 백그라운드 작업시 screen과의 협업

* 로그아웃을 하더라도 계속해서 할 필요가 있는 작업들은 screen 명령과 함께 쓰자.
* screen은 작업을 유지한채로 언제든 나중에 다시 연결할 수 있는 가상 쉘이다.

----

New Screen

```
sng2c_mbp:cron sng2c$ screen -R

bash-3.2$ perl my_timer.pl
...
^ad     
[detached]
sng2c_mbp:cron sng2c$ 
```

* screen 내에서 ^a과 d 를 차례대로 누르게 되면 detach를 한다.
* 하던 작업을 놔둔채로 원래의 쉘로 돌아가게 된다.
* 활성화된 session이 하나 뿐이면 자동으로 attach 된다.

----

List Sessions

```
sng2c_mbp:cron sng2c$ screen -list
There are screens on:
    74853.ttys000.sng2c_mbp (Detached)
    78216.ttys000.sng2c_mbp (Detached)
2 Sockets in /var/folders/77/73wygnmn7pnc4r5lz2zsrvr80000gn/T/.screen.

sng2c_mbp:cron sng2c$ 
```

* screen -list 를 사용하면 현재 활성화된 모든 session들이 나타난다.
* 이중에 하나를 골라서 -R 옵션으로 attach 할 수 있다.

----

Attach and Exit Screen

```
sng2c_mbp:cron sng2c$ screen -R 74853
...
^c
bash-3.2$ exit
[screen is terminating]
```

* screen -R 을 사용하면 작업중이던 session에 다시 연결된다.
* 세션이름의 앞쪽의 일부만 입력해도 된다.
* 하던 작업을 중지하고 exit를 입력하면 해당 session이 종료된다.

----

Run

```
$ screen -dmS NEW_NAME 'perl my_timer.pl';
```

* -dmS 를 이용하면, 바로 detached 상태로 들어가고, my_timer.pl이 종료되면 알아서 해당 스크린도 사라진다.

----

### 정리

* 파일다루기
* 설정파일 다루기
* HTTP통신 
* CGI수정
* Crontab
* Screen과의 협업

----

###  Q & A

----

###  감사합니다
