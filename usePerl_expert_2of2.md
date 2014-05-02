% Perl 바로쓰기 심화 2/2
% 김현승
% 2014-04-29

### Daemon의 작성

----

#### Daemon 의 특징

* 시스템에 남아서 계속 작동
* 외부에서 컨트롤이 가능해야 함
* 상태를 확인할 수 있어야 함
* 종료시에 여러가지 후처리를 해야함

----

#### Signal 처리

* Signal은 프로세스에게 보내는 메세지
* OS 또는 사용자 또는 다른 프로세스가 Signal을 보낸다.
* 프로세스는 기본적으로 각 메세지에 대한 대응을 함
* IPC(Inter-Process Communication)의 하나

----

#### Signal 의 종류

* INT
    * Ctrl-C 에 해당. 사용자에 의한 종료.
    * 기본동작 : 종료
* TERM
    * 종료메세지. 시스템에 의한 종료.
    * 기본동작 : 종료
* STOP
    * 프로세스 일시정지
    * 기본동작 : 일시정지
* CONT
    * 일시정지된 프로세스를 계속 실행
    * 기본동작 : 계속실행

----

#### Signal 의 종류

* ALRM
    * 알람 메세지. 프로그램내에서 발생시킴.
    * 기본동작 : 종료
* USR1,USR2
    * 사용자 메세지 1, 2
    * 기본동작 : 종료
* HUP
    * 소속된 터미널의 종료.
    * 기본동작 : 종료

----

#### Signal 오버라이딩

* Signal 에 대한 대응을 바꾸면,
    * 종료전에 후처리를 할 수 있다.
    * 종료를 취소할 수 있다.
    * 작동 타이밍을 알려줄 수 있다.

---

#### nohup

```bash
$ nohup 명령어 &
appending output to nohup.out
$
```

* nohup 과 & 로 명령을 백그라운드 상태로 실행하면,
* 현재 터미널이 종료될때 발생하는 HUP 메세지가 무시되고
* 결과적으로 Daemon이 된다.

----

#### Signal 의 전송 방법

```bash
$ kill 시그널 프로세스아이디
```

---

#### kill 

```bash
$ kill -STOP 44000

$ kill -CONT 44000

$ kill -TERM 44000

$ kill -USR1 44000

$ kill -0 44000
```

* Signal 0 은 해당 PID를 가진 프로세스가 있는지 확인
* 종료상태가 0 이면 해당 프로세스가 존재함(if에서 판별)
    * Perl의 'kill 0, $pid'는 존재할때 1을 리턴.

---

#### Daemon 컨트롤을 위한 샘플코드

* PID 를 알아야 Signal을 보내므로 pid파일이 필요함
* 프로그램이 종료할때 pid파일을 삭제하도록 함

---

##### pid 파일의 생성 및 삭제

```perl
system("echo $$ > $0.pid");

...

unlink("$0.pid");
```

* $$ 는 현재 PID를 담고 있는 내장변수
* $0 은 현재 스크립트파일의 이름을 담고 있는 내장변수

----

#### 시그널 처리

```perl
my $until = 1;

$SIG{INT} = sub{print "INT\n"; $until = 0; };
$SIG{TERM} = sub{print "TERM\n"; $until = 0; };
$SIG{USR1} = sub{print "USR1 : Hello World!\n"; };
$SIG{USR2} = sub{
	print "USR2 : Reset!!\n"; 
	$count = 0;
};

while($until){
	...
}
```

* $until을 0으로 만들면 루프의 종료조건이 됨

---

### bash를 활용한 Daemon 컨트롤

---

#### start.sh

```bash
#!/bin/sh
if [ -e 'signal.pl.pid' ]
then
	kill -0 `cat signal.pl.pid`
	if [ "$?" -eq "0" ]
	then
		echo 'Already Running...';
		exit
	fi
fi
nohup perl signal.pl 2> /dev/null &
```

---

#### stop.sh

```bash
#!/bin/sh
if [ -e 'signal.pl.pid' ]
then
	echo "Stopped"
	kill -TERM `cat signal.pl.pid`
else
	echo "Not Running"
fi
```

---

#### status.sh

```bash
#!/bin/sh
if [ -e 'signal.pl.pid' ]
then
	kill -0 `cat signal.pl.pid`
	if [ "$?" -eq "0" ]
	then
		echo 'Running...'
	else
		echo 'Not Running'	
	fi
else
	echo 'Not Running'
fi
```

---

#### reset.sh

```bash
#!/bin/sh
if [ -e 'signal.pl.pid' ]
then
	echo "Reset Count"
	kill -USR2 `cat signal.pl.pid`
else
	echo "Not Running."
fi
```

---

### perl을 활용한 Daemon 컨트롤

#### start.pl

```perl
#!/usr/bin/env perl\
if( -e 'signal.pl.pid'){
	if( kill(0,`cat signal.pl.pid`) == 1 ){
		print "Already Running...\n";
		exit;
	}
}
system( "nohup perl signal.pl 2> /dev/null &" );
```

---

#### stop.pl

```perl
#!/usr/bin/env perl
if ( -e 'signal.pl.pid'){
	print "Stopped\n";
	kill TERM => `cat signal.pl.pid`;
}
else{
	print "Not Running.\n";
}
```

---

#### status.pl

```perl
#!/usr/bin/env perl
if( -e 'signal.pl.pid' ){
	if ( kill(0,`cat signal.pl.pid`) == 1 ) {
		print "Running...\n";
	}
	else{
		print "Not Running\n";
	}
}
else{
	print "Not Running\n";
}
```

---

#### reset.pl

```perl
#!/usr/bin/env perl
if( -e 'signal.pl.pid' ){
	print "Reset Count\n";
	kill USR2 => `cat signal.pl.pid`;
}
else{
	print "Not Running.\n";
}
```

---

### init.d 스크립트

* 위에서 작성한 스크립트를 한번에 처리하고
* start, stop, restart, status 등을 
* 자동으로 구현해 주는 perl 모듈을 사용해보자

---

### cpanm 의 설치 

* 이후는 CPAN모듈들을 활용하므로 cpanm을 시스템에 설치한다.

```bash
$ curl -L http://cpanmin.us | sudo perl - App::cpanminus

$ sudo cpanm MODULE::NAME
```

* perlbrew로 설치한 perl을 사용할 때에는 sudo를 쓰지 않는다.

---

#### Daemon::Control

```bash
$ sudo cpanm Daemon::Control
```

* [https://metacpan.org/pod/Daemon::Control](https://metacpan.org/pod/Daemon::Control)

---

#### signalctl.pl

```perl
#!/usr/bin/env perl 
use Daemon::Control;
Daemon::Control->new({
        name        => "Signal Sample Control",
        program     => "perl signal.pl",
        pid_file    => "./signal.pl.pid",
        stderr_file => "./signal.pl.err",
        stdout_file => "./signal.pl.out",
})->run;
```

---

#### signalctl.pl

```bash
$ perl signalctl.pl
Syntax: signalctl.pl [start|stop|restart|reload|status|show_warnings|get_init_file|help]

$ perl signalctl.pl start
Signal Sample Control                                         [Started]

$ perl signalctl.pl stop
Signal Sample Control                                         [Stopped]
```

* pid파일을 직접 만들 필요도 없다.

---

#### signalctl.pl 커맨드 추가

```perl
sub Daemon::Control::do_reset{
    my ( $self ) = @_;
    $self->read_pid;
    if ( $self->pid && $self->pid_running  ) {
        kill USR2 => $self->pid;
        $self->pretty_print( "Reset" );
        return 0;
    }
}
```

```bash
$ perl signalctl.pl reset
Signal Sample Control                                           [Reset]
```

* Daemon::Control::do_* 로 함수를 정의하면 커맨드를 추가할 수 있다.
* $self->read_pid, $self->pid, $self->pid_running 를 활용한다.
* $self->pretty_print( "Reset" ); 로 컬러풀한 메세지를 출력한다.

---

### AnyEvent

```bash
$ sudo cpanm AnyEvent
```

* [https://metacpan.org/pod/AE](https://metacpan.org/pod/AE)

---

#### AnyEvent?

* Event Driven 라이브러리
* Signal, 파일핸들(소켓), 차일드프로세스, 타이머등에 반응
* HTTPD 등 편리한 유틸리티가 많아서 다채로운 작동을 시킬수 있음
* libev 는 node.js 에 사용됨

---

#### AnyEvent 버전 signal.pl 

```perl
use AnyEvent;

my $cv = AE::cv;

...이벤트 핸들러 정의...

$cv->recv;
```

* AE::cv 는 이벤트 루퍼
* $cv->recv; 에서 코드가 블럭되고,
* 그 위에서 정의한 이벤트 핸들러들이 작동한다.

---

#### AnyEvent 버전 signal.pl 

```perl
my $w1 = AE::signal INT=>sub{print "INT\n"; $cv->send; };
my $w2 = AE::signal TERM=> sub{print "TERM\n"; $cv->send; };
my $w3 = AE::signal USR1=> sub{print "USR1 : Hello World!\n"; };
my $w4 = AE::signal USR2=> sub{
	print "USR2 : Reset!!\n"; 
	$count = 0;
};
```

* 루프를 벗어나게 하는 명령인 $cv->send 를 호출

---


#### AnyEvent 버전 signal.pl 

```perl
my $w5 = AE::timer 0, 1, sub{
	$count++;
	print "WORK $count\n";
};
```

* sleep 이 아닌, 진정한 timer 를 사용

---

#### 파일의 변경감지

```bash
cpanm AnyEvent::Filesys::Notify
```

* [https://metacpan.org/pod/AnyEvent::Filesys::Notify](https://metacpan.org/pod/AnyEvent::Filesys::Notify)
* perl v5.10 이상에서만 작동

---

file_change.pl

```perl
my $notifier = AnyEvent::Filesys::Notify->new(
    dirs     => [ 'files' ],
    cb       => sub {
        my (@events) = @_;
        print "File Changed\n";
		print Dumper @events;
    },
);
```

---

#### CronJob

```bash
cpanm AnyEvent::Cron
```

* [https://metacpan.org/pod/AnyEvent::Cron](https://metacpan.org/pod/AnyEvent::Cron)
* perl v5.12 이상에서만 작동

---

cron.pl

```perl
my $cron = AnyEvent::Cron->new;

$cron->add('1 seconds' => sub{
    $count++;
    print "Cron $count\n";
} );

$cron->add('5 seconds' => sub{ print "Cron 5 seconds!!\n"; } );

$cron->add('* * * * *' => sub{ print "Cron 1 minutes!!\n"; } );

$cron->run;
```

* '* * * * *' 스타일 외에도 다양한 형태로 설정

---

#### HTTP 로 상태표시

```bash
$ sudo cpanm AnyEvent::HTTPD
```

* [https://metacpan.org/pod/AnyEvent::HTTPD](https://metacpan.org/pod/AnyEvent::HTTPD)

---

cron_httpd.pl

```perl
my $httpd = AnyEvent::HTTPD->new (port => 9090);
$httpd->reg_cb(
    '/' => sub{
        my ($httpd, $req) = @_; 

        $req->respond(
            {   
                content=> ['text/plain',"Current Count is $count."]
            }   
        );  
    },  
);
$httpd->run;    
```

* [http://localhost:9090](http://localhost:9090)
* URL 매핑으로 간단히 HTTP서버를 구현

---

#### AnyEvent 요약
 
* 손쉽게 시스템의 여러가지 자원들을 이용
* EDD는 한눈에 흐름이 들어와서 유지보수에 용이
* Perl로 EDD를 구현할 때는 AnyEvent가 정석
* 모니터링이나 배치작업을 상주시킬때 유용함.
    * AnyEvent::Gearman 으로 분산처리도 손쉽게
    * [AnyEvent 기반 모듈들](https://metacpan.org/search?q=AnyEvent%3A%3A)

---

#### Daemon 요약
 
* Signal 처리를 통해 종료를 처리 한다.
* Daemon::Control을 이용해서 프로세스를 관리한다.
* AnyEvent를 활용하면
    * 파일의 변경을 실시간으로 처리할 수 있다.
    * 타이머나 cron을 일관된 방법으로 처리할 수 있다.
    * HTTP로 상태를 보여주거나, 컨트롤 할 수 있다.

---

### 배포관리

* 원격 서버에 배포되는 대상으로써의 Perl
* 원격 서버로 배포하는 도구로써의 Perl

---

#### Capistrano

* ROR로 작성된 웹서비스의 배포를 위해 고안된 Capistrano
* Capistrano의 Web 인터페이스 버전인 Webistrano를 많이 사용
* Task 단위의 원격 실행 코드로 구성
* Deploy, Rollback의 기본 구성을 뼈대로 커스터마이징 하여 사용

---

##### Task

* 각 Task의 역할을 정확히 이해하기 위해서는 
* capistrano가 만들어 내는 디렉토리 구조를 살펴봐야 한다.

```
ROOT 
├── shared
│   ├── log
│   └── local
├── (current) ──────────> deploy #3
│
└── release 
    │
    ├── deploy #1 
    │   ├── (log) ──────> ROOT/shared/log
    │   └── (local) ────> ROOT/shared/local
    │
    ├── deploy #2
    │   ├── (log) ──────> ROOT/shared/log
    │   └── (local) ────> ROOT/shared/local  
    │
    └── deploy #3
        ├── (log) ──────> ROOT/shared/log
        └── (local) ────> ROOT/shared/local
```

--- 

###### deploy.update

```
ROOT 
└── release 
    │
    └── deploy #3
        └── src
```

1. release 내에 디렉토리를 추가
1. 그안에 프로젝트 소스를 체크아웃

---

###### deploy.symlink

```
ROOT 
├── shared
│   └── log
│
├── (current) ──────────> deploy #3
│
└── release 
    │
    └── deploy #3
        ├── (log) ─────> ROOT/shared/log
        └── src
```

1. 새 소스디렉토리로 향하는 current 심볼릭 링크 생성
1. 로그디렉토리 심볼릭 링크도 생성
1. 기타 공통파일들도 같은 방법으로 심볼릭 생성

---

###### deploy.check

```
ROOT 
├── shared
│   └── log
│
├── (current) ──────────> deploy #3
│
└── release 
    │
    └── deploy #3
        ├── (log)
        ├── [libs] <───── Gem / Maven / Carton... 
        └── src
```

1. current 내에서 의존 라이브러리 설치

---

###### deploy.rollback

```
ROOT 
├── shared
│   └── log
│
├── (current) ──────────> deploy #2
│
└── release 
    ├── deploy #1
    ├── deploy #2
    └── deploy #3

```

1. 이전에 배포된 디렉토리로 current 심볼릭 링크 업데이트

---

###### Capstrano 요약

* 심볼릭링크로 Deploy 관리
* 일련의 Deploy 과정은 다음과 같이 구성된다.
    * :stop -> :update -> :symlink -> :check -> :start

---

##### Perl+Carton 용 Recipe

###### task :start

```ruby
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}/workspace && sh #{start_script}", :pty=>false
  end
```

* :start 에서는 웹서버 또는 Daemon스크립트를 실행해야 한다.
* 이 예제에서는 current내의 \#{start_script} 를 실행하고 있다.

---

###### task :stop

```ruby
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}/workspace && sh #{stop_script}", :pty=>false
  end
```

* :stop 에서는 웹서버 또는 Daemon스크립트를 중지시켜야 한다.
* 이 예제에서는 current내의 \#{stop_script} 를 실행하고 있다.

---

###### task :restart

```ruby
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.stop
    deploy.start
  end
```

* 당연히 stop 후 start 를 한다.

---

###### task :check

```ruby
  task :check, :roles => :app, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/local"
    run "mkdir -p #{shared_path}/log/worker_log"
    run "rm -f #{current_path}/workspace/log ; ln -s #{shared_path}/log #{current_path}/workspace/log"
    run "rm -f #{current_path}/workspace/local ; ln -s #{shared_path}/local #{current_path}/workspace/local"
    run "cd #{current_path}/workspace && carton install --cached --deployment", :pty=>false
  end
```

* :check 에서는 의존 라이브러리들을 업데이트 해야한다.
* 이 예제에서는 carton이 사용하는 local과 log 디렉토리를 shared에 생성하고
* current 내에 다시 심볼릭 링크를 연결하고 있다.
* 그 뒤에 carton install 을 실행하여, 결과적으로 shared 에 설치된 것을 재사용한다.

---

###### before deploy:start/stop

```ruby
  before "deploy:start" do
    deploy.check
  end

  before "deploy:stop" do
    deploy.check
  end
```

* before 키워드를 이용하여 start와 stop직전에 의존 모듈들을 다시 업데이트 하고 있다.
* 엄밀히는 필요없지만, 중복해서 한번씩 더 하고 있다.

---

###### after : "deploy:symlink"

```ruby
  after "deploy:symlink" do
    run "rm -f #{current_path}/workspace/local ; ln -s #{shared_path}/local #{current_path}/workspace/local"
  end
```

* deploy에 필요한 심볼릭 링크가 생성된 후 
* current내의 local 심볼릭 링크를 삭제하고
* 다시 shared의 local로 새로 심볼릭 링크를 걸어주고 있다.
* check에서 한번 더 중복해서 하고 있는 작업이다.

---

##### Capistrano 요약

* Capistrano 는 심볼릭 링크 기반의 배포관리 툴이다.
* 특정한 형태로 디렉토리를 만들고 관리한다.
* 여러 서버에 같은 쉘스크립트 명령을 실행하는 방식으로 작동한다.
* 쉘스크립팅에 대한 지식이 필요하다.

---

#### (R)?ex 에 대하여

* [https://www.rexify.org/](https://www.rexify.org/)
* (R)?ex 는 Remote Execute 의 의미
* Perl로 작성된 서버관리 도구
* 복수개의 서버로 같은 명령을 실행
* Package 설치와 Service 관리에 특화

---

##### 설치 

```bash
$ curl -L get.rexify.org | perl - --sudo -n Rex
```

---

##### Rexfile

```perl
user "sng2c";
private_key "/Users/sng2c/.ssh/id_rsa"; # passphrase-less key
public_key "/Users/sng2c/.ssh/id_rsa.pub";
key_auth;

logging to_file => "rex.log";

group myserver => "mabook.com";

desc "Get the uptime of all server";
task "uptime", group => "myserver", sub {
	my $output = run "uptime";
	say $output;
};

```

---

##### 실행

```bash
$ rex -T       # 태스크 목록보기

$ rex uptime
```

---

##### Rexfile

```perl

my $fh = file_read "/Users/sng2c/sudo_password";
sudo_password $fh->read_all;
$fh->close;

desc "Install Redis Server";
task "setup_redis", group => "myserver", sub{
	sudo sub{
		install package=>'redis-server';
	};
};

desc "Remove Redis Server";
task "remove_redis", group => "myserver", sub{
	sudo sub{
		remove package=>'redis-server';
	};
};
```

---

##### 실행

```bash
$ rex -T       # 태스크 목록보기

$ rex setup_redis
```

---

##### perl 원격 설치 자동화

* [http://digit.daumcorp.com/sng2nara/RexSetupPerl](http://digit.daumcorp.com/sng2nara/RexSetupPerl)

---

#### Q & A

---

#### 감사합니다.
