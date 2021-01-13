# Chapter 2. 맵 리듀스

## 개념

- 데이터 처리를 위한 프로그래밍 모델
    - 다양한 언어로 작성된 맵 리듀스 프로그램 구동 가능
- 병행성을 고려하여 설계
- 맵 리듀스는 맵과 리듀스 단계로 구분
    - 맵: key-value 쌍으로 데이터 구분
    - 리듀스: key-value 데이터의 집계(아래 예제에서는 최고 기온을 구하는 max) 수행
- Combiner 함수
    - 맵의 결과를 처리
    - 컴바이너 함수 출력값이 리듀스 함수의 입력
    - 맵리듀스 프로세스의 최적화를 위함
- Hadoop Streaming
    - 기존 자바로 수행한 맵리듀스를 실행하는 것 외 스크립트 언어(Python, ruby, shell)를 하둡에서 실행하게 하는 Interface
    - 말 그대로 그때그때 데이터를 처리해야할 필요가 있을 때 사용하는 방식

## 실습

### Shell Script

- 기상 데이터를 이용해 프로그램을 작성하고 실습하는 단계
- 데이터 사용은 [https://github.com/trotyl/hadoop-the-definitive-guide/blob/master/chapter02/ncdc.sh](https://github.com/trotyl/hadoop-the-definitive-guide/blob/master/chapter02/ncdc.sh) 참고하여 수정
- 하기 스크립트는 `/src/main/shell` 폴더 내 존재
    1. `get-data.sh` 을 실행하여 데이터 구축
    2. `max_temperature.sh` 실행하여 연도별 온도 최댓값 확인

### Java

- Java 소스는 `/src/main/java/MaxTemperature` 안에 존재
    - MaxTemperature.java
    - MaxTemperatureMapper.java
    - MaxTemperatureReducer.java
- compile 후 실행

```bash
$ hadoop jar mr-intro-1.0-SNAPSHOT.jar com.jx2lee.github.MaxTemperature.MaxTemperature /test/input/sample.txt /test/t5
$ hdfs dfs -cat /test/t5/part-r-00000
21/01/12 10:07:21 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
1901	317
# Use Combiner
$ hadoop jar mr-intro-1.0-SNAPSHOT.jar com.jx2lee.github.MaxTemperature.MaxTemperatureWithCombiner /test/input/sample.txt /test/output/t2
$ hdfs dfs -cat /test/output/t2/part-r-00000
1901	317
```

### Hadoop Streaming - Python

- Python3 버젼으로 수행 시 아래와 같이 map / reducer 파일 수정

```bash
#max_temperature_map.py
#!/usr/bin/env python

import re
import sys

for line in sys.stdin:
  val = line.strip()
  (year, temp, q) = (val[15:19], val[87:92], val[92:93])
  if (temp != "+9999" and re.match("[01459]", q)):
    print("%s\t%s" % (year, temp))

#max_temperature_reduce.py
#!/usr/bin/env python

import sys

#(last_key, max_val) = (None, -sys.maxint)
(last_key, max_val) = (None, float('-inf'))
for line in sys.stdin:
  (key, val) = line.strip().split("\t")
  if last_key and last_key != key:
    print("%s\t%s" % (last_key, max_val))
    (last_key, max_val) = (key, int(val))
  else:
    (last_key, max_val) = (key, max(max_val, int(val)))

if last_key:
  print("%s\t%s" % (last_key, max_val))
```

- 아래 커맨드 수행

    ```bash
    $ hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.10.1.jar -files /Users/nhn/workspace/bigdata/hadoop-book-master/ch02-mr-intro/src/main/python/max_temperature_map.py,/Users/nhn/workspace/bigdata/hadoop-book-master/ch02-mr-intro/src/main/python/max_temperature_reduce.py \
    -input /test/input/sample.txt \
    -output /test/output/t3 \
    -mapper /Users/nhn/workspace/bigdata/hadoop-book-master/ch02-mr-intro/src/main/python/max_temperature_map.py \
    -reducer /Users/nhn/workspace/bigdata/hadoop-book-master/ch02-mr-intro/src/main/python/max_temperature_reduce.py
    $ hdfs dfs -cat /test/output/t3/part-00000
    1901	317
    ```

    - input/output: Path for hdfs `input/output`
    - mapper/reduce: Path for `mapper/reduce` python script

---

made by *jaejun.lee*
