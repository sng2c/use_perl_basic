% Perl 바로쓰기 심화
% 김현승
% 2014-04-28

---

## Perl 의존성

* Perl의 버전 
* Local, Remote 어느 쪽을 기준으로 할 것인가?

----

### 로컬환경을 서버에 맞추기

* 서버측은 5.8.8을 유지
    * 5.8.6 이고 한글을 직접 다루어야 한다면,
    * 서버환경 변경을 고려.
* 로컬환경을 5.8.x로 변경

----

#### perlbrew

* [http://perlbrew.pl/](http://perlbrew.pl/)
* 시스템에 있는 기존 perl은 건드리지 않는다.
* 홈디렉토리에 설치되며 다른 계정에는 영향을 주지 않는다.
* root 권한이 필요없다.
* 여러버전을 동시에 설치가 가능하다.

----

##### perlbrew 설치 

```bash
$ curl -L http://install.perlbrew.pl | bash
## Download the latest perlbrew
## Installing perlbrew
perlbrew is installed: ~/perl5/perlbrew/bin/perlbrew
perlbrew root (~/perl5/perlbrew) is initialized.

Append the following piece of code to the end of your ~/.bash_profile and start a
new shell, perlbrew should be up and fully functional from there:

 source ~/perl5/perlbrew/etc/bashrc

Simply run `perlbrew` for usage details.

Happy brewing!
## Installing patchperl
## Done.
$
```

----


##### perlbrew 설치 (2)


```
source ~/perl5/perlbrew/etc/bashrc
```

* ~/.bash_profile 에 추가 

----


##### perlbrew 설치 (3)


```
$ perlbrew install-cpanm
```

* cpanm 설치 

----

##### perl의 설치

###### 버전의 선택

```bash
$ perlbrew available --all
  perl-5.6.0
  ...
  perl-5.8.8
  perl-5.8.9
  perl-5.9.0
  perl-5.9.1
  perl-5.9.2
  perl-5.9.3
  perl-5.9.4
  perl-5.9.5
  perl-5.10.0
  perl-5.10.1
  ...
```

* 5.8.8에 맞추기로 했으니 5.8.8로

----

###### 설치 시작

```bash
$ perlbrew --force install perl-5.8.8
...
```
* OSX 에서는 locale 관련 test를 실패하더라도 무시하게 --force 추가

----

다른 터미널을 열어서

```bash
$ tail -f ~/perl5/perlbrew/build.perl-5.8.8.log
```

----

###### 설치된 버전의 목록

```bash
$ perlbrew list
  perl-5.8.8
$
```

----

###### 현재 터미널에서만 사용

```bash
$ perlbrew use perl-5.8.9
$ which perl
/Users/sng2c/perl5/perlbrew/perls/perl-5.8.9/bin/perl
```

###### 사용취소

```bash
$ perlbrew off
$ which perl
/usr/bin/perl
```
----

###### 명령 한번에만 사용

```bash
$ perl -e 'print "Hello from $]\n"'
 Hello from 5.016002

$ perlbrew exec --with perl-5.8.9 perl -e 'print "Hello from $]\n"'
 perl-5.8.9
 ==========
 Hello from 5.008009
```

---- 

###### 모든 버전에서 테스트

```bash
$ perlbrew exec perl -e 'print "Hello from $]\n"'
 perl-5.18.2
 ==========
 Hello from 5.018002
 
 perl-5.8.9
 ==========
 Hello from 5.008009
 
 ...
```
----

###### 계속 사용

```bash
$ perlbrew switch perl-5.8.9
```

###### 사용 취소

```bash
$ perlbrew switch-off
```

----

##### 요약

```bash
$ curl -L http://install.perlbrew.pl | bash
$ cat 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bash_profile
$ source ~/perl5/perlbrew/etc/bashrc
$ perlbrew install-cpanm
$ perlbrew install perl-5.8.8
```

----


##### 설치완료

* 이제 로컬에도 5.8.9가 설치되었으니
* 로컬에서 잘 작동하면 서버에서도 잘 될 것입니다.
* "#!/usr/bin/env perl" 을 사용합시다.

----


### 서버환경을 로컬에 맞추기

* 로컬이 5.16.2 일때
* 서버도 5.16.x 버전으로 변경

----

#### perlbrew의 설치

```bash
$ export PERLBREW_ROOT=/daum/program/perl5
$ curl -L http://install.perlbrew.pl | bash
```

* perlbrew의 root 디렉토리를 /daum/program/perl5 로 지정


----


```bash
echo 'source /daum/program/perl5/perlbrew/etc/bashrc' >> ~/.bash_profile
```

* .bash_profile에 추가


----


```bash
$ perlbrew install-cpanm
```

* cpanm 설치 


----


#### perl 설치

```bash
$ perlbrew install perl-5.18.2
...
$ perlbrew switch perl-5.18.2 
```

----

#### perl 설치본 복사

```bash
$ tar czvf perl5.tar.gz /daum/program/perl5

...

$ cp perl5.tar.gz /daum/program
$ tar xzvf /daum/program/perl5.tar.gz
```

* /daum/program/perl5 를 통채로 압축하여 배포

----

```bash
$ echo 'source /daum/program/perl5/perlbrew/etc/bashrc' >> ~/.bash_profile
```

* ~/.bash_profile 에 source 추가

----

## Module 의존성

----

### CPAN

* Comprehensive Perl Archive Network
* cpan 대화형 명령어
* 1995년부터 유지되어온 패키지 시스템 (내년에 20년;;)
* 소스코드는 물론이고 소스코드가 아닌 것들(자주쓰는 설정파일등)도 저장하여 공개
* [http://www.cpan.org/](http://www.cpan.org/)
* [http://www.metacpan.org/](http://www.metacpan.org/)

----

### 샘플 스크립트

test.pl

```perl
#!/usr/bin/env perl
use LWP::Simple;
print get('http://www.daum.net');
```

* LWP::Simple 모듈을 하나 사용하고 있다.

----

### cpanm

```bash
$ cpanm LWP::Simple
...
$ perl test.pl
```

* LWP::Simple과 그 의존 모듈들을 설치한다.

----

#### cpanm 장점

* perlbrew에서도 공통으로 쓸 수 있도록 지원
* 별도의 환경설정이 필요없음
* 자동화에 편리한 사용법
* 모듈의 원격/로컬 경로, git주소 등의 설치를 지원

----

#### cpanm 단점

* 실행 시스템을 변경시킴
* 네트워크가 막히면 설치가 어려워짐

----

### PAR

* JAR의 차용 (from Java)
* 하나의 파일안에 모든 의존 모듈을 집어넣음
* 실행 시스템을 변경하지 않음
* 단독 어플리케이션처럼 배포

----

#### 설치 

##### Local

```bash
$ cpanm PAR::Packer
```

----

#### 패키징

##### Local

```bash
$ pp -B -o test test.pl
```

##### Remote

```bash
$ ./test
```

----

#### PAR 장점 

* 단일 파일로 실행가능함
* tk에 대한 지원이 있어서 GUI어플리케이션에 적합

----

#### PAR 단점 

* 놓치는 모듈이나 의존 라이브러리는 직접 추가해줘야함.
* 매번 빌드해서 내보내야하는 번거러움.
* 파일의 크기가 큼
* 배포 대상 시스템에 맞춰서 미리 빌드 필요.

----

### Carton

* Bundle의 차용 (from Ruby)
* 의존하는 모듈의 소스를 vendor디렉토리에 포함
* 각 환경에서 모듈을 새로이 설치

----

#### 설치

##### Local

```bash
$ cpanm Carton
``` 

----

#### 패키징

##### Local

###### 의존성 해결

```bash
$ cat cpanfile
requires 'DBI';

$ carton install
```

----

###### 패키징

```bash
$ carton bundle
```

----

#### 작동

##### Remote

###### 의존성 해결

```bash
$ ./vendor/bin/carton install --cached
...
```

----

###### 실행

```bash
$ ./vendor/bin/carton exec perl test.pl
...
```

----

#### Carton 장점 

* 서버별로 모듈 설치를 진행하므로 이식성이 좋음
* 프로젝트 디렉토리 내에 설치하므로 충돌가능성도 없음
* 최근 배포시스템에 적용시키기 좋음

----

#### Carton 단점 

* PAR처럼 한번에 단독으로 실행하기는 어렵다.

----

## 중간정리

* cpanm : 로컬에서 Perl 모듈 설치
* PAR   : Perl이 필요없게 패키징
* carton : 의존모듈을 bundle화 해서 배포

----

## Database


* Perl에는 DBI라고 하는 공통 DB인터페이스가 있다.
* DBD:: 로 시작하는 각 DB별 드라이버를 함께 설치하여 사용한다.

----

### RDBMS

* RDBMS는 주로 SQL을 이용한다.
* SQL을 사용하는 DB들은 DBI 모듈로 추상화 되어있다.

----

#### DBI

##### 설치

```bash
$ cpanm DBI
```
* [https://metacpan.org/pod/DBI](https://metacpan.org/pod/DBI)

----

##### 사용법

###### Connect

```perl
use DBI;
$dbh = DBI->connect($data_source, $username, $auth, \%attr);
```

----

###### Select

```
$sth = $dbh->prepare('select * from TEST where name = ?');
$res = $sth->execute('내이름');
$data = $sth->fetchrow_hashref(); # Hash형태의 데이터
```

* ? 는 PlaceHolder
* execute() 에서 순서대로 바인딩

----

###### Insert

```
$sth = $dbh->prepare('insert into TEST (name) values ( ? )');
$res = $sth->execute('내이름');
```

----

###### Update

```
$sth = $dbh->prepare('update TEST set name = ? where user_id = ? ');
$res = $sth->execute('내이름', 230 );
```

----

###### Delete

```
$sth = $dbh->prepare('delete from TEST where user_id = ? ');
$res = $sth->execute( 230 );
```

----

#### mysql

```
$ cpanm DBD::mysql
```

```
use DBI;
my $dbh = DBI->connect("dbi:mysql:...", $id, $pw);
```

* [https://metacpan.org/pod/DBD::mysql](https://metacpan.org/pod/DBD::mysql)

----

#### oracle

```
$ cpanm DBD::Oracle
```

```
use DBI;
my $dbh = DBI->connect("dbi:Oracle:...", $id, $pw);
```

* [https://metacpan.org/pod/DBD::Oracle](https://metacpan.org/pod/DBD::Oracle)

----

#### postgresql

```
$ cpanm DBD::Pg
```

```
use DBI;
my $dbh = DBI->connect("dbi:Pg:...", $id, $pw);
```

* [https://metacpan.org/pod/DBD::Pg](https://metacpan.org/pod/DBD::Pg)

----

### NOSQL

* DBI는 SQL을 이용하는 DB의 인터페이스이다.
* 보통 NOSQL들은 인터페이스가 통일 되어있지 않다.

----

#### MongoDB

```bash
$ cpanm MongoDB

```

* [https://metacpan.org/pod/MongoDB](https://metacpan.org/pod/MongoDB)

----

#### MongoDB (2)

```perl
use MongoDB;
 
my $client     = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
my $database   = $client->get_database( 'foo' );
my $collection = $database->get_collection( 'bar' );
my $id         = $collection->insert({ some => 'data' });
my $data       = $collection->find_one({ _id => $id });
```

----

#### Redis

```bash
$ cpanm Redis
```

* [https://metacpan.org/pod/Redis](https://metacpan.org/pod/Redis)


----

#### Redis (2)

```perl
my $redis = Redis->new( server => 'localhost:8080',name => 'conn_name');
$redis->get('key');
$redis->set('key' => 'value');
$redis->sort('list', 'DESC');
$redis->sort(qw{list LIMIT 0 5 ALPHA DESC});

$redis->subscribe(
  'topic_1',
  sub { my ($message, $topic, $subscribed_topic) = @_;	
    # 구독처리
  }
);

$redis->publish('topic_1', 'message');
```


----

## 분산처리

* 복수개의 Core와 이기종 시스템들을 Worker로 추상화.
* 분산처리 라이브러리를 이용하면 이를 손쉽게 할 수 있게 된다.

----

### Gearman


```
			----------     ----------     ----------     ----------
			| Client |     | Client |     | Client |     | Client |
			----------     ----------     ----------     ----------
			     \             /              \             /
			      \           /                \           /
			      --------------               --------------
			      | Job Server |               | Job Server |
			      --------------               --------------
			            |                            |
			    ----------------------------------------------
			    |              |              |              |
			----------     ----------     ----------     ----------
			| Worker |     | Worker |     | Worker |     | Worker |
			----------     ----------     ----------     ----------
```

----

#### Gearman::Server

```bash
$ cpanm Gearman::Server

$ gearmand

...

```

* [https://metacpan.org/pod/gearmand](https://metacpan.org/pod/gearmand)

----

#### Gearman

```bash
$ cpanm Gearman

```

----

#### Gearman::Client


client.pl
```perl
use Gearman::Client;
use Storable qw( freeze );
my $client = Gearman::Client->new;
$client->job_servers('127.0.0.1');
my $tasks = $client->new_task_set;
my $handle = $tasks->add_task(sum => freeze([ 1, 2 ]), {
    on_complete => sub { print ${ $_[0] }, "\n" }
});
$tasks->wait;
```

* [https://metacpan.org/pod/Gearman::Client](https://metacpan.org/pod/Gearman::Client)


----

#### Gearman::Worker

worker.pl
```perl
use Gearman::Worker;
use Storable qw( thaw );
use List::Util qw( sum );
my $worker = Gearman::Worker->new;
$worker->job_servers('127.0.0.1');
$worker->register_function(sum => sub { sum @{ thaw($_[0]->arg) } });
$worker->work while 1;
```

* [https://metacpan.org/pod/Gearman::Worker](https://metacpan.org/pod/Gearman::Worker)


----

#### Gearman 특징

* Map과 Reduce를 모두 할 수 있다.
* 미리 Worker의 역할을 정해야 한다.

----

#### 실행

```bash
$ perl worker.pl &
$ perl client.pl
3
$
```

----

### Resque

* [https://metacpan.org/pod/Resque](https://metacpan.org/pod/Resque)


----

#### Client

```perl
use Resque;
 
my $r = Resque->new( redis => '127.0.0.1:6379' );
 
$r->push( my_queue => {
    class => 'AddTask',
    args => [ 1, 2 ]
});
```

* Redis에 접속하고나서 'my_queue' 에 AddTask 작업을 요청한다.

----

#### Task

AddTask.pm

```perl
package AddTask;
 
sub perform {
    my $job = shift;
    my @args = @{$job->args};
    print ($args[0]+$args[1])."\n";
}
 
1;
```

* My::Task 작업.

----

#### Worker

worker.pl

```perl
use Resque;
 
my $w = Resque->new( redis => '127.0.0.1:6379' )->worker;
$w->add_queue('my_queue');
$w->work;
```

* 'my_queue' 에 워커하나 등록

----

#### 실행

```bash
$ perl worker.pl &
$ perl client.pl
3
$
```

----


#### Resque 특징

* Redis 가 JobServer역할을 한다.
* Worker들의 상태등을 Redis에서 확인이 된다.
* 미리 Worker의 Task룰 정하지 않아도 된다.

----


## 정리

* Perl의 설치
* 원하는 버전의 선택
* 모듈의 설치
* 의존모듈을 함께 배포하는 법
* DB
* 분산처리


----

## Q & A

----

## 감사합니다.