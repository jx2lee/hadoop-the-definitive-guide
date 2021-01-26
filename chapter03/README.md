## HDFS 설계 특성

- 매우 큰 file
- streaming 방식의 데이터 접근
    - `한 번 쓰고 여러 번 읽는다`
    - 중요도: **첫 레코드를 읽는 시간 <<<<< 전체 데이터셋을 모두 읽는 시간**
- 범용적 HW

  > 하둡에 맞지 않은 분야 <br>
  `데이터 응답 시간이 짧은 경우` (빠르게 데이터 접근이 필요할 때)<br>
  `대량의 작은 파일` (filesystem 메타데이터를 메모리에서 관리하기 때문에 NameNode 의 메모리 사이즈에 좌우됨)<br>
  `Multiple Writer 및 파일 임의 수정` (저장한 파일에 덧붙여쓰기는 가능하지만 특정 위치 수정하는 것을 허용하지 않고 다중 writer 도 지원하지 않음 - 단 Multiple Writer 의 경우 hadoop 3버전에서는 제공

## HDFS 개념

### HDFS Block

- 통상적인 Block
    - 한 번에 읽고 쓸 수 있는 데이터의 최대량
    - 기본적으로 파일시스템의 블록 크기는 기본적으로 512 Byte
- HDFS Block 크기는 기본적으로 `128 MB`
    - 블록 크기가 큰 이유? **탐색 비용 최소화**
        - 탐색 시간(블록의 시작점 찾는 시간)을 최소화하고 네트워크를 통해 파일을 전송하는데 시간 할애하는 전략
- 단일 디스크를 위한 파일시스템의 경우 블록 크기보다 작은 데이터라도 한 블록 전체를 점유하지만, HDFS 파일은 **블록 크기보다 작은 데이터라도 전체 디스크를 점유하지 않음**
    - ex. 128MB 보다 작은 1MB 파일을 저장하면 1MB의 디스크만 사용
- hdfs 블록 관리 명령어: `hdfs fsck`

    ```bash
    $ hdfs fsck / -files -blocks
    Connecting to namenode via http://singlenode:50070/fsck?ugi=nhn&files=1&blocks=1&path=%2F
    FSCK started by nhn (auth:SIMPLE) from /211.52.174.102 for path / at Wed Jan 13 17:49:39 KST 2021
    / <dir>
    /test <dir>
    /test/input <dir>
    /test/input/file01 22 bytes, 1 block(s):  Under replicated BP-884875881-192.168.0.11-1610032095252:blk_1073741829_1005. Target Replicas is 3 but found 1 live replica(s), 0 decommissioned replica(s), 0 decommissioning replica(s).
    0. BP-884875881-192.168.0.11-1610032095252:blk_1073741829_1005 len=22 Live_repl=1

    /test/input/file02 28 bytes, 1 block(s):  Under replicated BP-884875881-192.168.0.11-1610032095252:blk_1073741830_1006. Target Replicas is 3 but found 1 live replica(s), 0 decommissioned replica(s), 0 decommissioning replica(s).
    0. BP-884875881-192.168.0.11-1610032095252:blk_1073741830_1006 len=28 Live_repl=1

    /test/input/sample.txt 888190 bytes, 1 block(s):  Under replicated BP-884875881-192.168.0.11-1610032095252:blk_1073741834_1010. Target Replicas is 3 but found 1 live replica(s), 0 decommissioned replica(s), 0 decommissioning replica(s).
    0. BP-884875881-192.168.0.11-1610032095252:blk_1073741834_1010 len=888190 Live_repl=1

    /test/output <dir>
    /test/output/t1 <dir>
    /test/output/t1/_SUCCESS 0 bytes, 0 block(s):  OK

    /test/output/t1/part-r-00000 9 bytes, 1 block(s):  Under replicated BP-884875881-192.168.0.11-1610032095252:blk_1073741838_1014. Target Replicas is 3 but found 1 live replica(s), 0 decommissioned replica(s), 0 decommissioning replica(s).
    0. BP-884875881-192.168.0.11-1610032095252:blk_1073741838_1014 len=9 Live_repl=1

    /test/output/t2 <dir>
    /test/output/t2/_SUCCESS 0 bytes, 0 block(s):  OK

    /test/output/t2/part-r-00000 9 bytes, 1 block(s):  Under replicated BP-884875881-192.168.0.11-1610032095252:blk_1073741839_1015. Target Replicas is 3 but found 1 live replica(s), 0 decommissioned replica(s), 0 decommissioning replica(s).
    0. BP-884875881-192.168.0.11-1610032095252:blk_1073741839_1015 len=9 Live_repl=1

    /test/output/t3 <dir>
    /test/output/t3/_SUCCESS 0 bytes, 0 block(s):  OK

    /test/output/t3/part-00000 9 bytes, 1 block(s):  Under replicated BP-884875881-192.168.0.11-1610032095252:blk_1073741840_1016. Target Replicas is 3 but found 1 live replica(s), 0 decommissioned replica(s), 0 decommissioning replica(s).
    0. BP-884875881-192.168.0.11-1610032095252:blk_1073741840_1016 len=9 Live_repl=1

    Status: HEALTHY
     Total size:	888267 B
     Total dirs:	7
     Total files:	9
     Total symlinks:		0
     Total blocks (validated):	6 (avg. block size 148044 B)
     Minimally replicated blocks:	6 (100.0 %)
     Over-replicated blocks:	0 (0.0 %)
     Under-replicated blocks:	6 (100.0 %)
     Mis-replicated blocks:		0 (0.0 %)
     Default replication factor:	3
     Average block replication:	1.0
     Corrupt blocks:		0
     Missing replicas:		12 (66.666664 %)
     Number of data-nodes:		1
     Number of racks:		1
    FSCK ended at Wed Jan 13 17:49:39 KST 2021 in 3 milliseconds

    The filesystem under path '/' is HEALTHY
    ```

  > hadoop 은 filesystem 의 추상화 개념을 가지며, HDFS 는 그 구현체 중 하나라고 한다. 쉽게 풀어 `filesystem 의 다양한 추상화 개념 중 하나가 HDFS 라고 생각하자`

### NameNode & DataNode

- Master - Worker(Slave)
- NameNode
    - 파일시스템의 namespace 관리
    - 메타데이터 저장
    - `조직 대가리`
- DataNode
    - `조직 따까리`
    - client 혹은 NameNode 요청에 따라 블록을 저장하고 탐색 (블록 상태를 NameNode 에 보고)

### Block caching

- 빈번히 접근하는 블록 파일은 `Off-heap block cache` 라는 DataNode 메모리에 캐싱 가능
- 기본적으로 블록은 하나의 DataNode 메모리에만 캐싱하지만 설정을 통해 파일 단위로 설정 가능
    - ex. Join 시 Look-up 테이블 캐싱하는 방법
- Cache pool: Cache 권한이나 자원의 용도를 관리하는 그룹
- Cache directive: Cache 권한을 가진 User

### HDFS Federation

- 각 NameNode 가 namespace 일부를 나누어 관리할 수 있는 기능
    - ex. namenode-1 는 /user 아래 파일을, namenode-2 는 /share 아래 파일을 관리할 수 있게 분리 가능
- Federation 적용시 `namespace volume` 과 `block pool` 관리
    - namespace volume: namespace 의 메타데이터
    - block pool: namespace 에 포함된 전체 블록

![https://i.stack.imgur.com/ugZul.png](https://i.stack.imgur.com/ugZul.png)

HDFS Federation: [https://i.stack.imgur.com/ugZul.png](https://i.stack.imgur.com/ugZul.png)

- Federation 을 적용한 hadoop cluster 접근을 위해서는 파일 경로 미 매핑한 클라이언트 측 마운트 테이블을 이용 (viewFileSystem 과 viewfs://URI)

### HDFS HA(High Availability)

## Java Interface

### hadoop URL 로 hdfs 파일 읽기

hdfs 파일을 읽는 자바 코드는 다음과 같다. 이 코드를 빌드하여 수행하면, `hdfs dfs -cat` 명령어와 같이 hdfs 내 파일 읽기가 가능하다.

```java
//URLcat.class
package com.jx2lee.github.URLcat;

import java.io.InputStream;
import java.net.URL;

import org.apache.hadoop.fs.FsUrlStreamHandlerFactory;
import org.apache.hadoop.io.IOUtils;

public class URLcat {

    static {
        URL.setURLStreamHandlerFactory(new FsUrlStreamHandlerFactory());
    }

    public static void main(String[] args) throws Exception {
        InputStream in = null;
        try {
            in = new URL(args[0]).openStream();
            IOUtils.copyBytes(in, System.out, 4096, false);
        } finally {
            IOUtils.closeStream(in);
        }
    }
}
```

- 명령어 비교

    ```bash
    $ hadoop jar hdfs-1.0-SNAPSHOT.jar com.jx2lee.github.hdfs.URLcat hdfs://133.186.241.218:9000/test/output/t3/part-00000
    1901	317
    $ hdfs dfs -cat /test/output/t3/part-00000
    21/01/20 00:21:23 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
    1901	317
    ```

### hdfs API 로 데이터 읽기

FileSystem API 를 이용해 hdfs 파일을 읽어본다

```java
package com.jx2lee.github.hdfs;

import java.io.InputStream;
import java.net.URI;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IOUtils;

public class FileSystemCat {

    public static void main(String[] args) throws Exception {
        String uri = args[0];
        Configuration conf = new Configuration();
        FileSystem fs = FileSystem.get(URI.create(uri), conf);

        InputStream in = null;
        try {
            in = fs.open(new Path(uri));
            IOUtils.copyBytes(in, System.out, 4096, false);
        } finally {
            IOUtils.closeStream(in);
        }
    }
}
```

```bash
#Run
$ hadoop jar hdfs-1.0-SNAPSHOT.jar com.jx2lee.github.hdfs.FileSystemCat hdfs://singlenode:9000/test/output/t3/part-00000
1901	317
```

- 추가로 java.io.InputStream 말고 `FSDataInputStream` 을 이용하여 파일의 어느 부분도 읽기가 가능

    ```java
    package com.jx2lee.github.hdfs;

    import java.net.URI;

    import org.apache.hadoop.conf.Configuration;
    import org.apache.hadoop.fs.FSDataInputStream; // java.io.InputStream 대신
    import org.apache.hadoop.fs.FileSystem;
    import org.apache.hadoop.fs.Path;
    import org.apache.hadoop.io.IOUtils;

    public class FileSystemCatDouble {

        public static void main(String[] args) throws Exception {
            String uri = args[0];
            Configuration conf = new Configuration();
            FileSystem fs = FileSystem.get(URI.create(uri), conf);

            FSDataInputStream in = null;
            try {
                in = fs.open(new Path(uri));
                IOUtils.copyBytes(in, System.out, 4096, false);
                in.seek(0); // file 의 첫 번째 입력으로 되돌아감, seek 메서드는 상대적으로 비용이 많이 드는 연산이므로 필요할 때만 사용!
                IOUtils.copyBytes(in, System.out, 4096, false);
            } finally {
                IOUtils.closeStream(in);
            }
        }
    }
    ```

  ### 데이터 쓰기

    - FileSystem class 는 파일 생성을 위한 메서드 제공
    - create / append 등 함수 제공

    ```java
    package com.jx2lee.github.hdfs;

    import org.apache.hadoop.conf.Configuration;
    import org.apache.hadoop.fs.FileSystem;
    import org.apache.hadoop.fs.Path;
    import org.apache.hadoop.io.IOUtils;
    import org.apache.hadoop.util.Progressable;

    import java.io.BufferedInputStream;
    import java.io.FileInputStream;
    import java.io.InputStream;
    import java.io.OutputStream;
    import java.net.URI;

    public class FileCopyWithProgress {
        public static void main(String[] args) throws Exception {
            String localSrc = args[0];
            String dst = args[1];

            InputStream in = new BufferedInputStream(new FileInputStream(localSrc));
            Configuration conf = new Configuration();
            FileSystem fs = FileSystem.get(URI.create(dst), conf);
            OutputStream out = fs.create(new Path(dst), new Progressable() {   // progress 메서드를 사용해 진행상황은 알 수 있지만 어떠한 이벤트가 발생하였는지 모른다.
                public void progress() {
                    System.out.print("*");
                }
            });
            IOUtils.copyBytes(in, out, 4096, true);
        }
    }
    ```

    ```bash
    $ hadoop jar hdfs-1.0-SNAPSHOT.jar com.jx2lee.github.hdfs.FileCopyWithProgress test.txt hdfs://singlenode:9000/test/output/t3/test.txt
    **%
    $ hdfs dfs -cat /test/output/t3/test.txt
    1,2,3
    4,5,6
    7,8,9
    ```