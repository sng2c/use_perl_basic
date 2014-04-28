use strict;
my $path = 'subdir/*'; 
my @files = glob $path;            # $path 내의 파일 목록을 얻는다.
my @stack;
push(@stack,@files);               # 스택에 시작디렉토리의 파일경로를 넣는다.
while( my $f = shift(@stack) ){    # 큐처럼 하나씩 꺼낸다. pop() 을 사용하면 깊이 우선이 된다.
    if( -d $f ){                   # 디렉토리이면 그 안의 파일목록을 스택에 넣는다.
        my @files = glob $f."/*";
        push(@stack,@files);
    }
    else{
        print $f."\n";             # 이 부분에서 각 파일을 처리한다.
    }
}
